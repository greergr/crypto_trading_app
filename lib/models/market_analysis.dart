import 'package:uuid/uuid.dart';
import 'trade_type.dart';

enum MarketSentiment { bullish, bearish, neutral }
enum SignalStrength { strong, moderate, weak }

class MarketAnalysis {
  final String symbol;
  final MarketSentiment sentiment;
  final SignalStrength signalStrength;
  final double confidence;
  final Map<String, double> technicalIndicators;
  final String recommendation;
  final DateTime timestamp;

  MarketAnalysis({
    required this.symbol,
    required this.sentiment,
    required this.signalStrength,
    required this.confidence,
    required this.technicalIndicators,
    required this.recommendation,
    required this.timestamp,
  });

  factory MarketAnalysis.fromJson(Map<String, dynamic> json) {
    return MarketAnalysis(
      symbol: json['symbol'] as String,
      sentiment: MarketSentiment.values.firstWhere(
        (e) => e.name == json['sentiment'],
        orElse: () => MarketSentiment.neutral,
      ),
      signalStrength: SignalStrength.values.firstWhere(
        (e) => e.name == json['signalStrength'],
        orElse: () => SignalStrength.weak,
      ),
      confidence: (json['confidence'] as num).toDouble(),
      technicalIndicators: Map<String, double>.from(
        json['technicalIndicators'] as Map,
      ),
      recommendation: json['recommendation'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'sentiment': sentiment.name,
      'signalStrength': signalStrength.name,
      'confidence': confidence,
      'technicalIndicators': technicalIndicators,
      'recommendation': recommendation,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'MarketAnalysis{symbol: $symbol, sentiment: $sentiment, signalStrength: $signalStrength, confidence: $confidence, recommendation: $recommendation}';
  }
}

class TechnicalAnalysis {
  final Map<String, double> indicators;
  final List<String> supportLevels;
  final List<String> resistanceLevels;
  final double score;
  final String primaryTrend;
  final Map<String, dynamic> patterns;

  TechnicalAnalysis({
    required this.indicators,
    required this.supportLevels,
    required this.resistanceLevels,
    required this.score,
    required this.primaryTrend,
    required this.patterns,
  });

  factory TechnicalAnalysis.fromJson(Map<String, dynamic> json) {
    return TechnicalAnalysis(
      indicators: Map<String, double>.from(json['indicators']),
      supportLevels: List<String>.from(json['support_levels']),
      resistanceLevels: List<String>.from(json['resistance_levels']),
      score: json['score'],
      primaryTrend: json['primary_trend'],
      patterns: json['patterns'],
    );
  }
}

class SentimentAnalysis {
  final double score;
  final List<NewsItem> topNews;
  final Map<String, double> socialMetrics;
  final String marketMood;
  final Map<String, int> keywordFrequency;

  SentimentAnalysis({
    required this.score,
    required this.topNews,
    required this.socialMetrics,
    required this.marketMood,
    required this.keywordFrequency,
  });

  factory SentimentAnalysis.fromJson(Map<String, dynamic> json) {
    return SentimentAnalysis(
      score: json['score'],
      topNews: (json['top_news'] as List)
          .map((news) => NewsItem.fromJson(news))
          .toList(),
      socialMetrics: Map<String, double>.from(json['social_metrics']),
      marketMood: json['market_mood'],
      keywordFrequency: Map<String, int>.from(json['keyword_frequency']),
    );
  }
}

class NewsItem {
  final String title;
  final String source;
  final DateTime timestamp;
  final double sentiment;
  final int impact;

  NewsItem({
    required this.title,
    required this.source,
    required this.timestamp,
    required this.sentiment,
    required this.impact,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'],
      source: json['source'],
      timestamp: DateTime.parse(json['timestamp']),
      sentiment: json['sentiment'],
      impact: json['impact'],
    );
  }
}

class PredictiveAnalysis {
  final double score;
  final Map<String, double> predictions;
  final List<TimeSeriesPoint> historicalData;
  final Map<String, double> confidence;
  final String trend;

  PredictiveAnalysis({
    required this.score,
    required this.predictions,
    required this.historicalData,
    required this.confidence,
    required this.trend,
  });

  factory PredictiveAnalysis.fromJson(Map<String, dynamic> json) {
    return PredictiveAnalysis(
      score: json['score'],
      predictions: Map<String, double>.from(json['predictions']),
      historicalData: (json['historical_data'] as List)
          .map((point) => TimeSeriesPoint.fromJson(point))
          .toList(),
      confidence: Map<String, double>.from(json['confidence']),
      trend: json['trend'],
    );
  }
}

class TimeSeriesPoint {
  final DateTime timestamp;
  final double actual;
  final double predicted;
  final double upperBound;
  final double lowerBound;

  TimeSeriesPoint({
    required this.timestamp,
    required this.actual,
    required this.predicted,
    required this.upperBound,
    required this.lowerBound,
  });

  factory TimeSeriesPoint.fromJson(Map<String, dynamic> json) {
    return TimeSeriesPoint(
      timestamp: DateTime.parse(json['timestamp']),
      actual: json['actual'],
      predicted: json['predicted'],
      upperBound: json['upper_bound'],
      lowerBound: json['lower_bound'],
    );
  }
}
