import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto_trading_app/models/market_analysis.dart';

class MarketAnalysisProvider with ChangeNotifier {
  final String _baseUrl = 'http://localhost:5000/api';
  Timer? _analysisTimer;
  Map<String, MarketAnalysis> _analysisResults = {};
  bool _isAnalyzing = false;

  Map<String, MarketAnalysis> get analysisResults => _analysisResults;
  bool get isAnalyzing => _isAnalyzing;

  MarketAnalysisProvider() {
    _startPeriodicAnalysis();
  }

  void _startPeriodicAnalysis() {
    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => refreshAnalysis(),
    );
  }

  Future<void> refreshAnalysis() async {
    if (_isAnalyzing) return;
    
    _isAnalyzing = true;
    notifyListeners();

    try {
      // 1. تحليل المؤشرات الفنية
      final technicalAnalysis = await _getTechnicalAnalysis();
      
      // 2. تحليل المشاعر السوقية
      final sentimentAnalysis = await _getSentimentAnalysis();
      
      // 3. التحليل التنبؤي
      final predictiveAnalysis = await _getPredictiveAnalysis();
      
      // دمج النتائج
      for (final pair in ['BTC/USD', 'ETH/USD', 'BNB/USD', 'SOL/USD']) {
        if (technicalAnalysis.containsKey(pair) &&
            sentimentAnalysis.containsKey(pair) &&
            predictiveAnalysis.containsKey(pair)) {
          _analysisResults[pair] = MarketAnalysis(
            pair: pair,
            technical: technicalAnalysis[pair]!,
            sentiment: sentimentAnalysis[pair]!,
            predictive: predictiveAnalysis[pair]!,
            timestamp: DateTime.now(),
          );
        }
      }
    } catch (e) {
      print('Error during market analysis: $e');
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  Future<Map<String, TechnicalAnalysis>> _getTechnicalAnalysis() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/technical-analysis'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Map<String, TechnicalAnalysis>.from(
          data.map((key, value) => MapEntry(
            key,
            TechnicalAnalysis.fromJson(value),
          )),
        );
      }
    } catch (e) {
      print('Error getting technical analysis: $e');
    }
    return {};
  }

  Future<Map<String, SentimentAnalysis>> _getSentimentAnalysis() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/sentiment-analysis'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Map<String, SentimentAnalysis>.from(
          data.map((key, value) => MapEntry(
            key,
            SentimentAnalysis.fromJson(value),
          )),
        );
      }
    } catch (e) {
      print('Error getting sentiment analysis: $e');
    }
    return {};
  }

  Future<Map<String, PredictiveAnalysis>> _getPredictiveAnalysis() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/predictive-analysis'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Map<String, PredictiveAnalysis>.from(
          data.map((key, value) => MapEntry(
            key,
            PredictiveAnalysis.fromJson(value),
          )),
        );
      }
    } catch (e) {
      print('Error getting predictive analysis: $e');
    }
    return {};
  }

  @override
  void dispose() {
    _analysisTimer?.cancel();
    super.dispose();
  }
}
