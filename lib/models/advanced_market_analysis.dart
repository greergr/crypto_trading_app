import 'package:flutter/foundation.dart';

enum TrendStrength {
  veryStrong,
  strong,
  moderate,
  weak,
  veryWeak,
}

enum MarketPhase {
  accumulation,    // تجميع
  markup,         // صعود
  distribution,   // توزيع
  markdown,       // هبوط
}

class AdvancedMarketAnalysis {
  final String symbol;
  final DateTime timestamp;
  
  // مؤشرات الاتجاه
  final TrendStrength trendStrength;
  final MarketPhase marketPhase;
  final double adx;  // Average Directional Index
  final double rsi;  // Relative Strength Index
  
  // مؤشرات التذبذب
  final double bollingerUpperBand;
  final double bollingerMiddleBand;
  final double bollingerLowerBand;
  final double bollingerBandWidth;
  
  // مؤشرات الزخم
  final double macd;         // MACD Line
  final double macdSignal;   // MACD Signal Line
  final double macdHistogram;// MACD Histogram
  
  // مؤشرات الحجم
  final double obv;          // On Balance Volume
  final double volumeEma;    // Volume Exponential Moving Average
  final double moneyFlowIndex; // Money Flow Index
  
  // مؤشرات التقلب
  final double atr;          // Average True Range
  final double volatilityIndex;
  
  // مستويات الدعم والمقاومة
  final List<double> supportLevels;
  final List<double> resistanceLevels;
  
  // نقاط الانعكاس المحتملة
  final List<Map<String, dynamic>> pivotPoints;
  
  // مؤشر قوة العملة
  final double currencyStrength;
  
  // تحليل المشاعر
  final double sentimentScore;
  final Map<String, double> sentimentFactors;

  const AdvancedMarketAnalysis({
    required this.symbol,
    required this.timestamp,
    required this.trendStrength,
    required this.marketPhase,
    required this.adx,
    required this.rsi,
    required this.bollingerUpperBand,
    required this.bollingerMiddleBand,
    required this.bollingerLowerBand,
    required this.bollingerBandWidth,
    required this.macd,
    required this.macdSignal,
    required this.macdHistogram,
    required this.obv,
    required this.volumeEma,
    required this.moneyFlowIndex,
    required this.atr,
    required this.volatilityIndex,
    required this.supportLevels,
    required this.resistanceLevels,
    required this.pivotPoints,
    required this.currencyStrength,
    required this.sentimentScore,
    required this.sentimentFactors,
  });

  // تحليل قوة الاتجاه الحالي
  bool get isStrongTrend => adx > 25;
  
  // تحليل التشبع
  bool get isOverbought => rsi > 70;
  bool get isOversold => rsi < 30;
  
  // تحليل تقاطعات المتوسطات
  bool get isMacdBullish => macdHistogram > 0 && macd > macdSignal;
  bool get isMacdBearish => macdHistogram < 0 && macd < macdSignal;
  
  // تحليل البولنجر باند
  bool get isPriceAboveUpperBand => bollingerMiddleBand > bollingerUpperBand;
  bool get isPriceBelowLowerBand => bollingerMiddleBand < bollingerLowerBand;
  
  // تحليل الحجم
  bool get isVolumeIncreasing => volumeEma > 0;
  
  // تحليل التقلب
  bool get isHighVolatility => volatilityIndex > 0.5;
  
  // الحصول على أقرب مستويات الدعم والمقاومة
  double? getNearestSupport(double currentPrice) {
    return supportLevels
        .where((level) => level < currentPrice)
        .reduce((a, b) => (currentPrice - a).abs() < (currentPrice - b).abs() ? a : b);
  }
  
  double? getNearestResistance(double currentPrice) {
    return resistanceLevels
        .where((level) => level > currentPrice)
        .reduce((a, b) => (currentPrice - a).abs() < (currentPrice - b).abs() ? a : b);
  }
  
  // تحليل المشاعر المتقدم
  Map<String, dynamic> getDetailedSentiment() {
    return {
      'overall_score': sentimentScore,
      'factors': sentimentFactors,
      'interpretation': _interpretSentiment(),
    };
  }
  
  String _interpretSentiment() {
    if (sentimentScore > 0.7) return 'إيجابي جداً';
    if (sentimentScore > 0.5) return 'إيجابي';
    if (sentimentScore > 0.3) return 'محايد';
    if (sentimentScore > 0.1) return 'سلبي';
    return 'سلبي جداً';
  }
  
  // تحليل شامل للسوق
  Map<String, dynamic> getComprehensiveAnalysis() {
    return {
      'trend': {
        'strength': trendStrength,
        'phase': marketPhase,
        'is_strong': isStrongTrend,
      },
      'momentum': {
        'rsi': {
          'value': rsi,
          'is_overbought': isOverbought,
          'is_oversold': isOversold,
        },
        'macd': {
          'line': macd,
          'signal': macdSignal,
          'histogram': macdHistogram,
          'is_bullish': isMacdBullish,
          'is_bearish': isMacdBearish,
        },
      },
      'volatility': {
        'atr': atr,
        'index': volatilityIndex,
        'is_high': isHighVolatility,
        'bollinger_bandwidth': bollingerBandWidth,
      },
      'volume': {
        'obv': obv,
        'ema': volumeEma,
        'is_increasing': isVolumeIncreasing,
        'money_flow_index': moneyFlowIndex,
      },
      'levels': {
        'support': supportLevels,
        'resistance': resistanceLevels,
        'pivot_points': pivotPoints,
      },
      'sentiment': getDetailedSentiment(),
    };
  }

  factory AdvancedMarketAnalysis.fromJson(Map<String, dynamic> json) {
    return AdvancedMarketAnalysis(
      symbol: json['symbol'],
      timestamp: DateTime.parse(json['timestamp']),
      trendStrength: TrendStrength.values.firstWhere(
        (e) => e.toString() == 'TrendStrength.${json['trend_strength']}',
      ),
      marketPhase: MarketPhase.values.firstWhere(
        (e) => e.toString() == 'MarketPhase.${json['market_phase']}',
      ),
      adx: json['adx'],
      rsi: json['rsi'],
      bollingerUpperBand: json['bollinger_upper_band'],
      bollingerMiddleBand: json['bollinger_middle_band'],
      bollingerLowerBand: json['bollinger_lower_band'],
      bollingerBandWidth: json['bollinger_band_width'],
      macd: json['macd'],
      macdSignal: json['macd_signal'],
      macdHistogram: json['macd_histogram'],
      obv: json['obv'],
      volumeEma: json['volume_ema'],
      moneyFlowIndex: json['money_flow_index'],
      atr: json['atr'],
      volatilityIndex: json['volatility_index'],
      supportLevels: List<double>.from(json['support_levels']),
      resistanceLevels: List<double>.from(json['resistance_levels']),
      pivotPoints: List<Map<String, dynamic>>.from(json['pivot_points']),
      currencyStrength: json['currency_strength'],
      sentimentScore: json['sentiment_score'],
      sentimentFactors: Map<String, double>.from(json['sentiment_factors']),
    );
  }

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'timestamp': timestamp.toIso8601String(),
    'trend_strength': trendStrength.toString().split('.').last,
    'market_phase': marketPhase.toString().split('.').last,
    'adx': adx,
    'rsi': rsi,
    'bollinger_upper_band': bollingerUpperBand,
    'bollinger_middle_band': bollingerMiddleBand,
    'bollinger_lower_band': bollingerLowerBand,
    'bollinger_band_width': bollingerBandWidth,
    'macd': macd,
    'macd_signal': macdSignal,
    'macd_histogram': macdHistogram,
    'obv': obv,
    'volume_ema': volumeEma,
    'money_flow_index': moneyFlowIndex,
    'atr': atr,
    'volatility_index': volatilityIndex,
    'support_levels': supportLevels,
    'resistance_levels': resistanceLevels,
    'pivot_points': pivotPoints,
    'currency_strength': currencyStrength,
    'sentiment_score': sentimentScore,
    'sentiment_factors': sentimentFactors,
  };
}
