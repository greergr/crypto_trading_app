import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

import '../models/trading_pair.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

enum TradingSignal {
  buy,
  sell,
  hold,
}

class MarketAnalyzer {
  final TradingPair pair;
  final List<double> _priceHistory = [];
  Timer? _updateTimer;
  bool _isInitialized = false;

  MarketAnalyzer(this.pair);

  bool get isInitialized => _isInitialized;
  List<double> get priceHistory => List.unmodifiable(_priceHistory);

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // TODO: Fetch historical price data
      _priceHistory.addAll([
        100.0, 101.0, 102.0, 101.5, 102.5,
        103.0, 102.8, 103.5, 104.0, 103.8,
        104.5, 105.0, 104.8, 105.5, 106.0,
      ]);

      _startUpdateTimer();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing market analyzer: $e');
      rethrow;
    }
  }

  void _startUpdateTimer() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(
      const Duration(seconds: AppConstants.priceUpdateInterval),
      (_) => _updatePrice(),
    );
  }

  Future<void> _updatePrice() async {
    try {
      // TODO: Fetch current price from API
      final newPrice = _priceHistory.last + (Random().nextDouble() - 0.5);
      _priceHistory.add(newPrice);

      // Keep only the required history
      if (_priceHistory.length > AppConstants.maxPriceHistoryLength) {
        _priceHistory.removeAt(0);
      }
    } catch (e) {
      debugPrint('Error updating price: $e');
    }
  }

  Future<Map<String, dynamic>> analyze() async {
    if (!_isInitialized) {
      throw StateError('MarketAnalyzer not initialized');
    }

    if (_priceHistory.length < AppConstants.minRequiredPriceHistory) {
      throw StateError('Not enough price history for analysis');
    }

    try {
      // Calculate technical indicators
      final rsi = TradingHelpers.calculateRSI(_priceHistory, AppConstants.rsiPeriod);
      final macd = TradingHelpers.calculateMACD(
        prices: _priceHistory,
        fastPeriod: AppConstants.macdFastPeriod,
        slowPeriod: AppConstants.macdSlowPeriod,
        signalPeriod: AppConstants.macdSignalPeriod,
      );
      final bb = TradingHelpers.calculateBollingerBands(
        _priceHistory,
        AppConstants.bbPeriod,
        AppConstants.bbStdDev,
      );

      // Generate trading signal
      final signal = _generateSignal(rsi, macd, bb);
      final confidence = _calculateConfidence(rsi, macd, bb);

      return {
        'signal': signal,
        'confidence': confidence,
        'indicators': {
          'rsi': rsi,
          'macd': macd,
          'bollinger_bands': bb,
        },
      };
    } catch (e) {
      debugPrint('Error analyzing market: $e');
      rethrow;
    }
  }

  TradingSignal _generateSignal(
    double rsi,
    Map<String, double> macd,
    Map<String, double> bb,
  ) {
    // RSI conditions
    final bool isOversold = rsi < AppConstants.rsiOversoldThreshold;
    final bool isOverbought = rsi > AppConstants.rsiOverboughtThreshold;

    // MACD conditions
    final bool isMacdCrossover = macd['histogram']! > 0 &&
        macd['histogram']! > macd['signal']!;

    // Bollinger Bands conditions
    final currentPrice = _priceHistory.last;
    final bool isPriceBelowLower = currentPrice < bb['lower']!;
    final bool isPriceAboveUpper = currentPrice > bb['upper']!;

    // Generate signal based on combined conditions
    if ((isOversold && isMacdCrossover) || isPriceBelowLower) {
      return TradingSignal.buy;
    } else if ((isOverbought && !isMacdCrossover) || isPriceAboveUpper) {
      return TradingSignal.sell;
    }

    return TradingSignal.hold;
  }

  double _calculateConfidence(
    double rsi,
    Map<String, double> macd,
    Map<String, double> bb,
  ) {
    double confidence = 0.5; // Base confidence

    // RSI contribution
    if (rsi < 30 || rsi > 70) confidence += 0.1;
    if (rsi < 20 || rsi > 80) confidence += 0.1;

    // MACD contribution
    final macdStrength = (macd['histogram']!).abs() / macd['macd']!.abs();
    confidence += macdStrength.clamp(0.0, 0.2);

    // Bollinger Bands contribution
    final currentPrice = _priceHistory.last;
    final bbRange = bb['upper']! - bb['lower']!;
    final pricePosition = (currentPrice - bb['lower']!) / bbRange;
    if (pricePosition < 0.1 || pricePosition > 0.9) confidence += 0.1;

    return confidence.clamp(0.0, 1.0);
  }

  void dispose() {
    _updateTimer?.cancel();
    _priceHistory.clear();
    _isInitialized = false;
  }
}
