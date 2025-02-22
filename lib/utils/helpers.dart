import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../utils/constants.dart';

class TradingHelpers {
  static final _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static String formatBalance(double balance) {
    return _currencyFormat.format(balance);
  }

  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(2)}%';
  }

  static List<double> normalizeData(List<double> data) {
    if (data.isEmpty) return [];
    
    final min = data.reduce(math.min);
    final max = data.reduce(math.max);
    final range = max - min;
    
    if (range == 0) return List.filled(data.length, 0.5);
    
    return data.map((value) => (value - min) / range).toList();
  }

  static double calculateRSI(List<double> prices, int period) {
    if (prices.length < period + 1) {
      throw ArgumentError('Not enough price data for RSI calculation');
    }

    double sumGain = 0;
    double sumLoss = 0;

    for (int i = 1; i <= period; i++) {
      final change = prices[i] - prices[i - 1];
      if (change >= 0) {
        sumGain += change;
      } else {
        sumLoss -= change;
      }
    }

    double avgGain = sumGain / period;
    double avgLoss = sumLoss / period;

    for (int i = period + 1; i < prices.length; i++) {
      final change = prices[i] - prices[i - 1];
      if (change >= 0) {
        avgGain = (avgGain * (period - 1) + change) / period;
        avgLoss = (avgLoss * (period - 1)) / period;
      } else {
        avgGain = (avgGain * (period - 1)) / period;
        avgLoss = (avgLoss * (period - 1) - change) / period;
      }
    }

    if (avgLoss == 0) return 100;
    final rs = avgGain / avgLoss;
    return 100 - (100 / (1 + rs));
  }

  static Map<String, double> calculateMACD({
    required List<double> prices,
    required int fastPeriod,
    required int slowPeriod,
    required int signalPeriod,
  }) {
    if (prices.length < slowPeriod + signalPeriod) {
      throw ArgumentError('Not enough price data for MACD calculation');
    }

    final fastEMA = _calculateEMA(prices, fastPeriod);
    final slowEMA = _calculateEMA(prices, slowPeriod);
    final macdLine = fastEMA - slowEMA;

    final signalLine = _calculateEMA(
      List.generate(prices.length, (i) => macdLine),
      signalPeriod,
    );

    final histogram = macdLine - signalLine;

    return {
      'macd': macdLine,
      'signal': signalLine,
      'histogram': histogram,
    };
  }

  static Map<String, double> calculateBollingerBands(
    List<double> prices,
    int period,
    double stdDev,
  ) {
    if (prices.length < period) {
      throw ArgumentError('Not enough price data for Bollinger Bands calculation');
    }

    final sma = _calculateSMA(prices.sublist(prices.length - period), period);
    final deviation = _calculateStandardDeviation(prices, sma, period);

    return {
      'middle': sma,
      'upper': sma + (deviation * stdDev),
      'lower': sma - (deviation * stdDev),
    };
  }

  static double _calculateSMA(List<double> prices, int period) {
    return prices.reduce((a, b) => a + b) / period;
  }

  static double _calculateEMA(List<double> prices, int period) {
    if (prices.length < period) {
      throw ArgumentError('Not enough price data for EMA calculation');
    }

    double multiplier = 2 / (period + 1);
    double ema = prices.sublist(0, period).reduce((a, b) => a + b) / period;

    for (int i = period; i < prices.length; i++) {
      ema = (prices[i] - ema) * multiplier + ema;
    }

    return ema;
  }

  static double _calculateStandardDeviation(
    List<double> prices,
    double mean,
    int period,
  ) {
    final variance = prices
        .sublist(prices.length - period)
        .map((price) => math.pow(price - mean, 2))
        .reduce((a, b) => a + b) / period;
    return math.sqrt(variance);
  }

  static double calculateVolatility(List<double> prices, [int period = 14]) {
    if (prices.length < period) return 0.0;
    
    final returns = List.generate(
      prices.length - 1,
      (i) => (prices[i + 1] - prices[i]) / prices[i],
    );
    
    final mean = returns.reduce((a, b) => a + b) / returns.length;
    
    final variance = returns.fold<double>(
      0,
      (sum, value) => sum + math.pow(value - mean, 2),
    ) / returns.length;
    
    return math.sqrt(variance);
  }
}
