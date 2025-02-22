import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:math' as math;
import '../models/ai_analysis.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  late Interpreter _interpreter;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _interpreter = await Interpreter.fromAsset('assets/models/trading_model.tflite');
      _isInitialized = true;
    } catch (e) {
      throw Exception('فشل في تحميل نموذج الذكاء الاصطناعي: $e');
    }
  }

  Future<AIAnalysis> analyzeTradingData(List<double> prices, List<double> volumes) async {
    if (!_isInitialized) {
      throw Exception('لم يتم تهيئة خدمة الذكاء الاصطناعي');
    }

    try {
      // تحضير البيانات
      final normalizedPrices = _normalize(prices);
      final normalizedVolumes = _normalize(volumes);

      // تحويل البيانات إلى الشكل المطلوب للنموذج
      final input = [normalizedPrices, normalizedVolumes];
      final output = List<double>.filled(3, 0).reshape([1, 3]);

      // تنفيذ التحليل
      _interpreter.run(input, output);

      // تحليل النتائج
      final predictions = output[0] as List<double>;
      final direction = _getPredictedDirection(predictions);
      final confidence = _calculateConfidence(predictions);

      return AIAnalysis(
        predictedDirection: direction,
        confidence: confidence,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw Exception('فشل في تحليل البيانات: $e');
    }
  }

  List<double> _normalize(List<double> data) {
    if (data.isEmpty) return [];

    final max = data.reduce(math.max);
    final min = data.reduce(math.min);
    final range = max - min;

    if (range == 0) return List.filled(data.length, 0.5);

    return data.map((value) => (value - min) / range).toList();
  }

  TradingDirection _getPredictedDirection(List<double> predictions) {
    final maxIndex = predictions.indexOf(predictions.reduce(math.max));
    switch (maxIndex) {
      case 0:
        return TradingDirection.up;
      case 1:
        return TradingDirection.down;
      default:
        return TradingDirection.neutral;
    }
  }

  double _calculateConfidence(List<double> predictions) {
    final maxProb = predictions.reduce(math.max);
    return maxProb * 100; // تحويل إلى نسبة مئوية
  }

  void dispose() {
    if (_isInitialized) {
      _interpreter.close();
      _isInitialized = false;
    }
  }
}
