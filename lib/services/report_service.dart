import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/trading_bot.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ReportService {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');
  final DateFormat _timeFormatter = DateFormat('HH:mm:ss');

  // إنشاء تقرير يومي
  Future<String> generateDailyReport(TradingBot bot) async {
    final today = _dateFormatter.format(DateTime.now());
    final todayTrades = bot.trades.where(
      (trade) => _dateFormatter.format(trade.timestamp) == today
    ).toList();

    double dailyProfit = 0;
    int successfulTrades = 0;
    
    for (var trade in todayTrades) {
      dailyProfit += trade.profit;
      if (trade.profit > 0) successfulTrades++;
    }

    final report = {
      'date': today,
      'bot_id': bot.id,
      'pair': bot.pair,
      'total_trades': todayTrades.length,
      'successful_trades': successfulTrades,
      'failed_trades': todayTrades.length - successfulTrades,
      'success_rate': todayTrades.isEmpty ? 0 : 
        (successfulTrades / todayTrades.length * 100).toStringAsFixed(2) + '%',
      'daily_profit': dailyProfit.toStringAsFixed(2) + '%',
      'current_balance': bot.accountBalance.toStringAsFixed(2),
      'trades': todayTrades.map((t) => t.toJson()).toList(),
    };

    await _saveDailyReport(bot.id, report);
    return json.encode(report);
  }

  // إنشاء تقرير أسبوعي
  Future<String> generateWeeklyReport(TradingBot bot) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    final weeklyStats = List.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));
      final dateStr = _dateFormatter.format(date);
      
      final dayTrades = bot.trades.where(
        (trade) => _dateFormatter.format(trade.timestamp) == dateStr
      ).toList();

      double dayProfit = 0;
      int successfulTrades = 0;
      
      for (var trade in dayTrades) {
        dayProfit += trade.profit;
        if (trade.profit > 0) successfulTrades++;
      }

      return {
        'date': dateStr,
        'trades_count': dayTrades.length,
        'successful_trades': successfulTrades,
        'profit': dayProfit.toStringAsFixed(2) + '%',
      };
    });

    final report = {
      'bot_id': bot.id,
      'pair': bot.pair,
      'week_start': _dateFormatter.format(startOfWeek),
      'week_end': _dateFormatter.format(startOfWeek.add(Duration(days: 6))),
      'daily_stats': weeklyStats,
      'total_trades': bot.trades.length,
      'weekly_profit': bot.currentProfit.toStringAsFixed(2) + '%',
      'max_loss_streak': bot.riskManager.currentLossStreak,
      'current_balance': bot.accountBalance.toStringAsFixed(2),
    };

    await _saveWeeklyReport(bot.id, report);
    return json.encode(report);
  }

  // إنشاء تقرير أداء
  Future<String> generatePerformanceReport(TradingBot bot) async {
    final trades = bot.trades;
    
    // تحليل الأداء حسب وقت اليوم
    final hourlyPerformance = Map<int, Map<String, dynamic>>();
    
    for (var trade in trades) {
      final hour = trade.timestamp.hour;
      hourlyPerformance.putIfAbsent(hour, () => {
        'total_trades': 0,
        'successful_trades': 0,
        'total_profit': 0.0,
      });
      
      hourlyPerformance[hour]!['total_trades']++;
      if (trade.profit > 0) {
        hourlyPerformance[hour]!['successful_trades']++;
      }
      hourlyPerformance[hour]!['total_profit'] += trade.profit;
    }

    // تحليل أفضل وأسوأ الأوقات للتداول
    final bestHours = hourlyPerformance.entries
      .where((e) => e.value['total_trades'] >= 5)
      .toList()
      ..sort((a, b) => (b.value['total_profit'] as double)
          .compareTo(a.value['total_profit'] as double));

    final report = {
      'bot_id': bot.id,
      'pair': bot.pair,
      'total_trades_analyzed': trades.length,
      'overall_success_rate': trades.isEmpty ? 0 :
        (trades.where((t) => t.profit > 0).length / trades.length * 100)
          .toStringAsFixed(2) + '%',
      'average_profit_per_trade': trades.isEmpty ? 0 :
        (trades.fold(0.0, (sum, trade) => sum + trade.profit) / trades.length)
          .toStringAsFixed(2) + '%',
      'best_trading_hours': bestHours.take(3).map((e) => {
        'hour': '${e.key}:00',
        'success_rate': 
          (e.value['successful_trades'] / e.value['total_trades'] * 100)
            .toStringAsFixed(2) + '%',
        'average_profit':
          (e.value['total_profit'] / e.value['total_trades'])
            .toStringAsFixed(2) + '%',
      }).toList(),
      'hourly_performance': hourlyPerformance,
    };

    await _savePerformanceReport(bot.id, report);
    return json.encode(report);
  }

  // حفظ التقرير اليومي
  Future<void> _saveDailyReport(String botId, Map<String, dynamic> report) async {
    final dir = await _getReportDirectory();
    final date = _dateFormatter.format(DateTime.now());
    final file = File('${dir.path}/daily_report_${botId}_$date.json');
    await file.writeAsString(json.encode(report));
  }

  // حفظ التقرير الأسبوعي
  Future<void> _saveWeeklyReport(String botId, Map<String, dynamic> report) async {
    final dir = await _getReportDirectory();
    final weekStart = report['week_start'];
    final file = File('${dir.path}/weekly_report_${botId}_$weekStart.json');
    await file.writeAsString(json.encode(report));
  }

  // حفظ تقرير الأداء
  Future<void> _savePerformanceReport(
    String botId,
    Map<String, dynamic> report,
  ) async {
    final dir = await _getReportDirectory();
    final date = _dateFormatter.format(DateTime.now());
    final file = File('${dir.path}/performance_report_${botId}_$date.json');
    await file.writeAsString(json.encode(report));
  }

  // الحصول على مجلد التقارير
  Future<Directory> _getReportDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${appDir.path}/reports');
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }
    return reportsDir;
  }

  // استرجاع التقارير اليومية
  Future<List<Map<String, dynamic>>> getDailyReports(
    String botId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final dir = await _getReportDirectory();
    final reports = <Map<String, dynamic>>[];
    
    await for (final file in dir.list()) {
      if (file.path.contains('daily_report_$botId')) {
        final content = await File(file.path).readAsString();
        final report = json.decode(content);
        
        final reportDate = DateTime.parse(report['date']);
        if (startDate != null && reportDate.isBefore(startDate)) continue;
        if (endDate != null && reportDate.isAfter(endDate)) continue;
        
        reports.add(report);
      }
    }
    
    return reports;
  }

  // استرجاع التقارير الأسبوعية
  Future<List<Map<String, dynamic>>> getWeeklyReports(String botId) async {
    final dir = await _getReportDirectory();
    final reports = <Map<String, dynamic>>[];
    
    await for (final file in dir.list()) {
      if (file.path.contains('weekly_report_$botId')) {
        final content = await File(file.path).readAsString();
        reports.add(json.decode(content));
      }
    }
    
    return reports;
  }
}
