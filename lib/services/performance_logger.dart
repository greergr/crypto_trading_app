import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../models/trade.dart';

class PerformanceLogger extends ChangeNotifier {
  Database? _database;
  Timer? _cleanupTimer;
  final Duration _logRetentionPeriod = const Duration(days: 90);
  
  // Performance metrics
  int _totalTrades = 0;
  int _successfulTrades = 0;
  int _failedTrades = 0;
  int _apiCalls = 0;
  int _apiErrors = 0;
  Map<String, int> _errorCounts = {};
  
  // Getters for metrics
  int get totalTrades => _totalTrades;
  int get successfulTrades => _successfulTrades;
  int get failedTrades => _failedTrades;
  int get apiCalls => _apiCalls;
  int get apiErrors => _apiErrors;
  double get successRate => _totalTrades > 0 ? _successfulTrades / _totalTrades * 100 : 0;
  Map<String, int> get errorCounts => Map.unmodifiable(_errorCounts);

  PerformanceLogger() {
    _initDatabase();
    _startCleanupTimer();
  }

  Future<void> _initDatabase() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final dbPath = path.join(documentsDirectory.path, 'performance_logs.db');
      
      _database = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
            CREATE TABLE trade_logs (
              id TEXT PRIMARY KEY,
              timestamp INTEGER,
              type TEXT,
              symbol TEXT,
              amount REAL,
              price REAL,
              profit_loss REAL,
              success INTEGER,
              error_message TEXT
            )
          ''');
          
          await db.execute('''
            CREATE TABLE api_logs (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              timestamp INTEGER,
              endpoint TEXT,
              method TEXT,
              success INTEGER,
              error_message TEXT,
              response_time INTEGER
            )
          ''');
          
          await db.execute('''
            CREATE TABLE error_logs (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              timestamp INTEGER,
              error_type TEXT,
              message TEXT,
              stack_trace TEXT
            )
          ''');
        },
      );
      
      // Load historical metrics
      await _loadMetrics();
    } catch (e) {
      debugPrint('Error initializing performance logger database: $e');
    }
  }

  Future<void> _loadMetrics() async {
    try {
      final db = _database;
      if (db == null) return;

      // Load trade metrics
      final tradeCounts = await db.rawQuery('''
        SELECT 
          COUNT(*) as total,
          SUM(CASE WHEN success = 1 THEN 1 ELSE 0 END) as successful,
          SUM(CASE WHEN success = 0 THEN 1 ELSE 0 END) as failed
        FROM trade_logs
      ''');
      
      if (tradeCounts.isNotEmpty) {
        _totalTrades = tradeCounts.first['total'] as int;
        _successfulTrades = tradeCounts.first['successful'] as int;
        _failedTrades = tradeCounts.first['failed'] as int;
      }

      // Load API metrics
      final apiCounts = await db.rawQuery('''
        SELECT 
          COUNT(*) as total,
          SUM(CASE WHEN success = 0 THEN 1 ELSE 0 END) as errors
        FROM api_logs
      ''');
      
      if (apiCounts.isNotEmpty) {
        _apiCalls = apiCounts.first['total'] as int;
        _apiErrors = apiCounts.first['errors'] as int;
      }

      // Load error type counts
      final errorTypes = await db.query(
        'error_logs',
        columns: ['error_type'],
        groupBy: 'error_type',
      );
      
      for (final type in errorTypes) {
        final count = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM error_logs WHERE error_type = ?',
          [type['error_type']],
        ));
        if (count != null) {
          _errorCounts[type['error_type'] as String] = count;
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading metrics: $e');
    }
  }

  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(days: 1), (_) => _cleanupOldLogs());
  }

  Future<void> _cleanupOldLogs() async {
    try {
      final db = _database;
      if (db == null) return;

      final cutoffTime = DateTime.now().subtract(_logRetentionPeriod).millisecondsSinceEpoch;
      
      await db.transaction((txn) async {
        await txn.delete(
          'trade_logs',
          where: 'timestamp < ?',
          whereArgs: [cutoffTime],
        );
        
        await txn.delete(
          'api_logs',
          where: 'timestamp < ?',
          whereArgs: [cutoffTime],
        );
        
        await txn.delete(
          'error_logs',
          where: 'timestamp < ?',
          whereArgs: [cutoffTime],
        );
      });
    } catch (e) {
      debugPrint('Error cleaning up old logs: $e');
    }
  }

  Future<void> logTrade(Trade trade, {String? errorMessage}) async {
    try {
      final db = _database;
      if (db == null) return;

      final success = errorMessage == null;
      if (success) {
        _successfulTrades++;
      } else {
        _failedTrades++;
      }
      _totalTrades++;

      await db.insert('trade_logs', {
        'id': trade.id,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'type': trade.type.toString(),
        'symbol': trade.symbol,
        'amount': trade.amount,
        'price': trade.price,
        'profit_loss': trade.profitLoss,
        'success': success ? 1 : 0,
        'error_message': errorMessage,
      });

      notifyListeners();
    } catch (e) {
      debugPrint('Error logging trade: $e');
    }
  }

  Future<void> logApiCall(
    String endpoint,
    String method, {
    bool success = true,
    String? errorMessage,
    int? responseTime,
  }) async {
    try {
      final db = _database;
      if (db == null) return;

      _apiCalls++;
      if (!success) _apiErrors++;

      await db.insert('api_logs', {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'endpoint': endpoint,
        'method': method,
        'success': success ? 1 : 0,
        'error_message': errorMessage,
        'response_time': responseTime,
      });

      notifyListeners();
    } catch (e) {
      debugPrint('Error logging API call: $e');
    }
  }

  Future<void> logError(
    String errorType,
    String message, {
    String? stackTrace,
  }) async {
    try {
      final db = _database;
      if (db == null) return;

      _errorCounts[errorType] = (_errorCounts[errorType] ?? 0) + 1;

      await db.insert('error_logs', {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'error_type': errorType,
        'message': message,
        'stack_trace': stackTrace,
      });

      notifyListeners();
    } catch (e) {
      debugPrint('Error logging error: $e');
    }
  }

  Future<Map<String, dynamic>> getPerformanceReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final db = _database;
      if (db == null) return {};

      final whereClause = _getDateRangeWhereClause(startDate, endDate);
      
      // Get trade statistics
      final tradeStats = await db.rawQuery('''
        SELECT 
          COUNT(*) as total_trades,
          SUM(CASE WHEN success = 1 THEN 1 ELSE 0 END) as successful_trades,
          SUM(CASE WHEN success = 0 THEN 1 ELSE 0 END) as failed_trades,
          AVG(CASE WHEN success = 1 THEN profit_loss ELSE 0 END) as avg_profit,
          MAX(CASE WHEN success = 1 THEN profit_loss ELSE 0 END) as max_profit,
          MIN(CASE WHEN success = 1 THEN profit_loss ELSE 0 END) as max_loss
        FROM trade_logs
        ${whereClause.isNotEmpty ? 'WHERE ${whereClause}' : ''}
      ''');

      // Get API statistics
      final apiStats = await db.rawQuery('''
        SELECT 
          COUNT(*) as total_calls,
          SUM(CASE WHEN success = 0 THEN 1 ELSE 0 END) as errors,
          AVG(response_time) as avg_response_time
        FROM api_logs
        ${whereClause.isNotEmpty ? 'WHERE ${whereClause}' : ''}
      ''');

      // Get most common errors
      final commonErrors = await db.rawQuery('''
        SELECT error_type, COUNT(*) as count
        FROM error_logs
        ${whereClause.isNotEmpty ? 'WHERE ${whereClause}' : ''}
        GROUP BY error_type
        ORDER BY count DESC
        LIMIT 5
      ''');

      return {
        'trade_statistics': tradeStats.first,
        'api_statistics': apiStats.first,
        'common_errors': commonErrors,
        'report_period': {
          'start': startDate?.toIso8601String(),
          'end': endDate?.toIso8601String(),
        },
      };
    } catch (e) {
      debugPrint('Error generating performance report: $e');
      return {};
    }
  }

  String _getDateRangeWhereClause(DateTime? startDate, DateTime? endDate) {
    final conditions = <String>[];
    
    if (startDate != null) {
      conditions.add('timestamp >= ${startDate.millisecondsSinceEpoch}');
    }
    
    if (endDate != null) {
      conditions.add('timestamp <= ${endDate.millisecondsSinceEpoch}');
    }
    
    return conditions.join(' AND ');
  }

  Future<void> exportLogs(String exportPath) async {
    try {
      final db = _database;
      if (db == null) return;

      final report = await getPerformanceReport();
      final trades = await db.query('trade_logs');
      final apiCalls = await db.query('api_logs');
      final errors = await db.query('error_logs');

      final exportData = {
        'report': report,
        'trades': trades,
        'api_calls': apiCalls,
        'errors': errors,
      };

      final jsonData = json.encode(exportData);
      final file = File(exportPath);
      await file.writeAsString(jsonData);
    } catch (e) {
      debugPrint('Error exporting logs: $e');
    }
  }

  void dispose() {
    _cleanupTimer?.cancel();
    _database?.close();
  }
}
