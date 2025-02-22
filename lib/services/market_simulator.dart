import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/market_analysis.dart';
import 'binance_service.dart';
import 'performance_logger.dart';

class MarketSimulator {
  final BinanceService _binanceService;
  final PerformanceLogger _logger;
  final Random _random = Random();
  
  // Market simulation parameters
  final double _volatilityFactor = 0.02; // 2% base volatility
  final double _trendStrength = 0.3; // 30% trend influence
  final double _newsImpact = 0.05; // 5% news impact
  
  // Cached market data
  Map<String, double> _lastPrices = {};
  Map<String, double> _trends = {};
  Timer? _updateTimer;
  
  MarketSimulator({
    required BinanceService binanceService,
    required PerformanceLogger logger,
  })  : _binanceService = binanceService,
        _logger = logger {
    _startUpdates();
  }

  void _startUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateMarketData(),
    );
  }

  Future<void> _updateMarketData() async {
    try {
      if (!_binanceService.isTestnet) return;

      for (final symbol in _lastPrices.keys) {
        final currentPrice = _lastPrices[symbol] ?? 0;
        final trend = _trends[symbol] ?? 0;
        
        // Update trend
        _trends[symbol] = _calculateNewTrend(trend);
        
        // Calculate new price
        final newPrice = _calculateNewPrice(
          currentPrice,
          trend,
          _volatilityFactor,
        );
        
        _lastPrices[symbol] = newPrice;
      }
    } catch (e) {
      await _logger.logError('MARKET_SIMULATION', e.toString());
    }
  }

  double _calculateNewTrend(double currentTrend) {
    // Trend tends to mean revert
    final meanReversion = -currentTrend * 0.1;
    final randomWalk = (_random.nextDouble() - 0.5) * 0.02;
    return (currentTrend + meanReversion + randomWalk).clamp(-0.1, 0.1);
  }

  double _calculateNewPrice(
    double currentPrice,
    double trend,
    double volatility,
  ) {
    // Base random walk
    final randomFactor = (_random.nextDouble() - 0.5) * 2 * volatility;
    
    // Trend influence
    final trendImpact = trend * _trendStrength;
    
    // News impact (random events)
    final newsImpact = _random.nextDouble() < 0.05
        ? (_random.nextDouble() - 0.5) * 2 * _newsImpact
        : 0.0;
    
    // Combine all factors
    final priceChange = currentPrice * (randomFactor + trendImpact + newsImpact);
    return max(0, currentPrice + priceChange);
  }

  Future<void> initializeSymbol(String symbol, double initialPrice) async {
    try {
      _lastPrices[symbol] = initialPrice;
      _trends[symbol] = 0.0;
      
      await _logger.logApiCall(
        'initializeSymbol',
        'SIMULATION',
        success: true,
      );
    } catch (e) {
      await _logger.logError('SIMULATION_INIT', e.toString());
    }
  }

  double? getSimulatedPrice(String symbol) {
    return _lastPrices[symbol];
  }

  Map<String, double> getMarketTrends() {
    return Map.unmodifiable(_trends);
  }

  Future<MarketAnalysis> simulateMarketAnalysis(String symbol) async {
    try {
      final currentPrice = _lastPrices[symbol];
      final trend = _trends[symbol] ?? 0;
      
      if (currentPrice == null) {
        throw Exception('Symbol not initialized: $symbol');
      }

      // Simulate technical indicators
      final rsi = _simulateRSI(trend);
      final macd = _simulateMACD(trend);
      final volume = _simulateVolume(currentPrice);
      
      return MarketAnalysis(
        symbol: symbol,
        timestamp: DateTime.now(),
        price: currentPrice,
        volume: volume,
        rsi: rsi,
        macd: macd,
        trend: trend,
        confidence: _calculateConfidence(rsi, macd, trend),
      );
    } catch (e) {
      await _logger.logError('MARKET_ANALYSIS', e.toString());
      rethrow;
    }
  }

  double _simulateRSI(double trend) {
    // RSI tends to follow trend but with more noise
    final base = (trend + 0.5) * 100; // Convert trend to 0-100 scale
    final noise = (_random.nextDouble() - 0.5) * 20;
    return (base + noise).clamp(0, 100);
  }

  double _simulateMACD(double trend) {
    // MACD follows trend closely
    return trend * 100 + (_random.nextDouble() - 0.5) * 10;
  }

  double _simulateVolume(double price) {
    // Volume tends to increase with volatility
    final baseVolume = price * 100;
    final volatilityFactor = 1 + (_random.nextDouble() * _volatilityFactor * 10);
    return baseVolume * volatilityFactor;
  }

  double _calculateConfidence(double rsi, double macd, double trend) {
    // Confidence based on indicator agreement
    final rsiSignal = (rsi - 50) / 50; // -1 to 1
    final macdSignal = macd / 100; // Normalized to -1 to 1
    
    // Calculate agreement between indicators
    final agreement = 1 - (
      (rsiSignal - trend).abs() +
      (macdSignal - trend).abs() +
      (rsiSignal - macdSignal).abs()
    ) / 3;
    
    return (agreement * 100).clamp(0, 100);
  }

  void dispose() {
    _updateTimer?.cancel();
  }
}
