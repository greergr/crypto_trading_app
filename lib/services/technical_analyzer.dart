import 'package:ta_lib/ta_lib.dart';

class TechnicalAnalysis {
  final double rsi;
  final double macd;
  final double signal;
  final double histogram;
  final List<double> bollingerBands;
  final DateTime timestamp;

  TechnicalAnalysis({
    required this.rsi,
    required this.macd,
    required this.signal,
    required this.histogram,
    required this.bollingerBands,
    required this.timestamp,
  });

  bool get isOverbought => rsi > 70;
  bool get isOversold => rsi < 30;
  bool get isMacdBullish => histogram > 0;
  bool get isMacdBearish => histogram < 0;
}

class TechnicalAnalyzer {
  static final TechnicalAnalyzer _instance = TechnicalAnalyzer._internal();
  factory TechnicalAnalyzer() => _instance;
  TechnicalAnalyzer._internal();

  Future<TechnicalAnalysis> analyze(List<double> prices, List<double> volumes) async {
    try {
      // حساب RSI
      final rsi = await _calculateRSI(prices);

      // حساب MACD
      final macdResult = await _calculateMACD(prices);

      // حساب Bollinger Bands
      final bollingerBands = await _calculateBollingerBands(prices);

      return TechnicalAnalysis(
        rsi: rsi.last,
        macd: macdResult['macd']!.last,
        signal: macdResult['signal']!.last,
        histogram: macdResult['histogram']!.last,
        bollingerBands: [
          bollingerBands['upper']!.last,
          bollingerBands['middle']!.last,
          bollingerBands['lower']!.last,
        ],
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw Exception('فشل في التحليل الفني: $e');
    }
  }

  Future<List<double>> _calculateRSI(List<double> prices) async {
    try {
      return RSI.calculate(
        data: prices,
        period: 14,
      );
    } catch (e) {
      throw Exception('فشل في حساب RSI: $e');
    }
  }

  Future<Map<String, List<double>>> _calculateMACD(List<double> prices) async {
    try {
      final macd = MACD.calculate(
        data: prices,
        fastPeriod: 12,
        slowPeriod: 26,
        signalPeriod: 9,
      );

      return {
        'macd': macd.macd,
        'signal': macd.signal,
        'histogram': macd.histogram,
      };
    } catch (e) {
      throw Exception('فشل في حساب MACD: $e');
    }
  }

  Future<Map<String, List<double>>> _calculateBollingerBands(
    List<double> prices,
  ) async {
    try {
      final bb = BollingerBands.calculate(
        data: prices,
        period: 20,
        standardDeviation: 2,
      );

      return {
        'upper': bb.upper,
        'middle': bb.middle,
        'lower': bb.lower,
      };
    } catch (e) {
      throw Exception('فشل في حساب Bollinger Bands: $e');
    }
  }

  // تحليل الاتجاه باستخدام المتوسطات المتحركة
  Future<bool> isTrendBullish(List<double> prices) async {
    try {
      final sma20 = SMA.calculate(data: prices, period: 20);
      final sma50 = SMA.calculate(data: prices, period: 50);

      return sma20.last > sma50.last;
    } catch (e) {
      throw Exception('فشل في تحليل الاتجاه: $e');
    }
  }

  // التحقق من وجود تقاطع المتوسطات المتحركة
  Future<bool> hasGoldenCross(List<double> prices) async {
    try {
      final sma50 = SMA.calculate(data: prices, period: 50);
      final sma200 = SMA.calculate(data: prices, period: 200);

      // التحقق من التقاطع الذهبي (المتوسط 50 يتجاوز المتوسط 200)
      final previousDay = sma50[sma50.length - 2] < sma200[sma200.length - 2];
      final currentDay = sma50.last > sma200.last;

      return previousDay && currentDay;
    } catch (e) {
      throw Exception('فشل في التحقق من التقاطع الذهبي: $e');
    }
  }

  // التحقق من وجود تقاطع الموت
  Future<bool> hasDeathCross(List<double> prices) async {
    try {
      final sma50 = SMA.calculate(data: prices, period: 50);
      final sma200 = SMA.calculate(data: prices, period: 200);

      // التحقق من تقاطع الموت (المتوسط 50 ينخفض تحت المتوسط 200)
      final previousDay = sma50[sma50.length - 2] > sma200[sma200.length - 2];
      final currentDay = sma50.last < sma200.last;

      return previousDay && currentDay;
    } catch (e) {
      throw Exception('فشل في التحقق من تقاطع الموت: $e');
    }
  }

  // تحليل مستويات الدعم والمقاومة
  Future<Map<String, double>> analyzeSupportResistance(List<double> prices) async {
    try {
      // تحديد مستويات الدعم والمقاومة باستخدام المتوسطات المتحركة
      final sma20 = SMA.calculate(data: prices, period: 20);
      final sma50 = SMA.calculate(data: prices, period: 50);
      final sma200 = SMA.calculate(data: prices, period: 200);

      // حساب مستويات الدعم والمقاومة
      final currentPrice = prices.last;
      final support1 = _findNearestSupport(currentPrice, [sma20.last, sma50.last, sma200.last]);
      final resistance1 = _findNearestResistance(currentPrice, [sma20.last, sma50.last, sma200.last]);

      return {
        'support1': support1,
        'resistance1': resistance1,
      };
    } catch (e) {
      throw Exception('فشل في تحليل مستويات الدعم والمقاومة: $e');
    }
  }

  double _findNearestSupport(double currentPrice, List<double> levels) {
    // ترتيب المستويات التي تقع تحت السعر الحالي
    final supports = levels.where((level) => level < currentPrice).toList()
      ..sort((a, b) => b.compareTo(a));
    
    return supports.isNotEmpty ? supports.first : currentPrice * 0.95;
  }

  double _findNearestResistance(double currentPrice, List<double> levels) {
    // ترتيب المستويات التي تقع فوق السعر الحالي
    final resistances = levels.where((level) => level > currentPrice).toList()
      ..sort();
    
    return resistances.isNotEmpty ? resistances.first : currentPrice * 1.05;
  }
}
