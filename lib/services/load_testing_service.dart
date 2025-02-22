import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/trade.dart';
import 'binance_service.dart';
import 'performance_logger.dart';

class LoadTestingService {
  final BinanceService _binanceService;
  final PerformanceLogger _logger;
  final Random _random = Random();
  Timer? _testTimer;
  bool _isRunning = false;
  
  // Test configuration
  final int tradesPerDay;
  final List<String> testSymbols;
  final double maxTradeAmount;
  
  // Performance tracking
  int _completedTrades = 0;
  int _successfulTrades = 0;
  int _failedTrades = 0;
  double _averageResponseTime = 0;
  final List<double> _responseTimes = [];
  
  LoadTestingService({
    required BinanceService binanceService,
    required PerformanceLogger logger,
    this.tradesPerDay = 1000,
    this.testSymbols = const ['BTCUSDT', 'ETHUSDT', 'BNBUSDT'],
    this.maxTradeAmount = 0.1,
  })  : _binanceService = binanceService,
        _logger = logger;

  bool get isRunning => _isRunning;
  int get completedTrades => _completedTrades;
  int get successfulTrades => _successfulTrades;
  int get failedTrades => _failedTrades;
  double get successRate => _completedTrades > 0 ? (_successfulTrades / _completedTrades * 100) : 0;
  double get averageResponseTime => _averageResponseTime;

  Future<void> startLoadTest({
    Duration duration = const Duration(days: 1),
    void Function(String)? onProgress,
  }) async {
    if (_isRunning) return;
    
    _isRunning = true;
    _resetMetrics();
    
    final tradesPerSecond = tradesPerDay / (24 * 60 * 60);
    final interval = Duration(microseconds: (1000000 / tradesPerSecond).round());
    
    debugPrint('Starting load test with ${tradesPerDay} trades per day');
    debugPrint('Trade interval: ${interval.inMilliseconds}ms');
    
    _testTimer = Timer.periodic(interval, (timer) async {
      if (!_isRunning) {
        timer.cancel();
        return;
      }
      
      try {
        final startTime = DateTime.now();
        await _executeRandomTrade();
        final endTime = DateTime.now();
        
        _updateResponseTime(endTime.difference(startTime).inMilliseconds.toDouble());
        
        if (onProgress != null) {
          onProgress(
            'Completed: $_completedTrades trades, '
            'Success rate: ${successRate.toStringAsFixed(2)}%, '
            'Avg response: ${_averageResponseTime.toStringAsFixed(2)}ms',
          );
        }
      } catch (e) {
        debugPrint('Error during load test: $e');
      }
    });
    
    // Stop test after duration
    Future.delayed(duration, () => stopLoadTest());
  }

  void stopLoadTest() {
    _isRunning = false;
    _testTimer?.cancel();
    _generateTestReport();
  }

  Future<void> _executeRandomTrade() async {
    try {
      final symbol = testSymbols[_random.nextInt(testSymbols.length)];
      final amount = (_random.nextDouble() * maxTradeAmount)
          .toStringAsFixed(8)
          .replaceAll(RegExp(r'0*$'), '')
          .replaceAll(RegExp(r'\.$'), '');
      
      final trade = Trade(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        symbol: symbol,
        amount: double.parse(amount),
        type: _random.nextBool() ? TradeType.buy : TradeType.sell,
        price: 0, // Will be set by the market
        timestamp: DateTime.now(),
      );

      final startTime = DateTime.now().millisecondsSinceEpoch;
      
      await _binanceService.executeTrade(trade);
      _successfulTrades++;
      
      final endTime = DateTime.now().millisecondsSinceEpoch;
      await _logger.logApiCall(
        '/api/v3/order',
        'POST',
        success: true,
        responseTime: endTime - startTime,
      );
    } catch (e) {
      _failedTrades++;
      await _logger.logError('LOAD_TEST', e.toString());
    } finally {
      _completedTrades++;
    }
  }

  void _updateResponseTime(double responseTime) {
    _responseTimes.add(responseTime);
    if (_responseTimes.length > 1000) {
      _responseTimes.removeAt(0);
    }
    _averageResponseTime = _responseTimes.reduce((a, b) => a + b) / _responseTimes.length;
  }

  void _resetMetrics() {
    _completedTrades = 0;
    _successfulTrades = 0;
    _failedTrades = 0;
    _averageResponseTime = 0;
    _responseTimes.clear();
  }

  Map<String, dynamic> _generateTestReport() {
    final report = {
      'total_trades': _completedTrades,
      'successful_trades': _successfulTrades,
      'failed_trades': _failedTrades,
      'success_rate': successRate,
      'average_response_time': _averageResponseTime,
      'response_time_percentiles': _calculatePercentiles(),
      'test_duration': _calculateTestDuration(),
      'trades_per_second': _calculateTradesPerSecond(),
    };

    debugPrint('Load Test Report:');
    report.forEach((key, value) {
      debugPrint('$key: $value');
    });

    return report;
  }

  Map<String, double> _calculatePercentiles() {
    if (_responseTimes.isEmpty) return {};
    
    final sorted = List<double>.from(_responseTimes)..sort();
    return {
      'p50': _getPercentile(sorted, 0.5),
      'p90': _getPercentile(sorted, 0.9),
      'p95': _getPercentile(sorted, 0.95),
      'p99': _getPercentile(sorted, 0.99),
    };
  }

  double _getPercentile(List<double> sorted, double percentile) {
    final index = (sorted.length * percentile).round() - 1;
    return sorted[index.clamp(0, sorted.length - 1)];
  }

  String _calculateTestDuration() {
    final seconds = _completedTrades / (tradesPerDay / (24 * 60 * 60));
    final duration = Duration(seconds: seconds.round());
    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m ${duration.inSeconds.remainder(60)}s';
  }

  double _calculateTradesPerSecond() {
    final testDurationSeconds = _completedTrades / (tradesPerDay / (24 * 60 * 60));
    return _completedTrades / testDurationSeconds;
  }

  void dispose() {
    stopLoadTest();
  }
}
