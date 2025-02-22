import 'package:flutter/foundation.dart';

class AIAnalysis {
  final List<double> priceHistory;
  final List<String> indicators;
  final Map<String, double> predictions;

  AIAnalysis({
    required this.priceHistory,
    required this.indicators,
    required this.predictions,
  });

  double get confidenceScore {
    if (predictions.isEmpty) return 0.0;
    return predictions.values.reduce((a, b) => a + b) / predictions.length;
  }

  String get recommendedAction {
    if (confidenceScore < 0.5) return 'hold';
    final upProbability = predictions['up'] ?? 0.0;
    return upProbability > 0.6 ? 'buy' : 'sell';
  }

  Map<String, dynamic> toJson() {
    return {
      'priceHistory': priceHistory,
      'indicators': indicators,
      'predictions': predictions,
    };
  }

  factory AIAnalysis.fromJson(Map<String, dynamic> json) {
    return AIAnalysis(
      priceHistory: List<double>.from(json['priceHistory']),
      indicators: List<String>.from(json['indicators']),
      predictions: Map<String, double>.from(json['predictions']),
    );
  }
}
