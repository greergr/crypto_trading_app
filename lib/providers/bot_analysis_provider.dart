import 'package:flutter/foundation.dart';
import '../models/trading_bot.dart';
import '../models/ai_analysis.dart';
import 'package:flutter/material.dart';

class BotAnalysisProvider with ChangeNotifier {
  final Map&lt;String, TradingBot> _bots = {};
  final Map&lt;String, AIAnalysis> _analyses = {};
  double _weeklyPnL = 0.0;
  int _totalTrades = 0;
  int _successfulTrades = 0;

  // إدارة البوتات
  void addBot(TradingBot bot) {
    _bots[bot.pair] = bot;
    notifyListeners();
  }

  void removeBot(String pair) {
    _bots.remove(pair);
    notifyListeners();
  }

  void toggleBot(String pair) {
    if (_bots.containsKey(pair)) {
      _bots[pair]!.isActive = !_bots[pair]!.isActive;
      notifyListeners();
    }
  }

  // إدارة المخاطر
  void checkWeeklyLoss() {
    if (_weeklyPnL <= -20.0) {
      // إيقاف جميع البوتات عند تجاوز الخسارة الأسبوعية 20%
      for (var bot in _bots.values) {
        bot.isActive = false;
      }
      notifyListeners();
    }
  }

  // تحديث الإحصائيات
  void updateStats({
    required String pair,
    required double pnl,
    required bool isSuccess,
  }) {
    _weeklyPnL += pnl;
    _totalTrades++;
    if (isSuccess) _successfulTrades++;
    checkWeeklyLoss();
    notifyListeners();
  }

  // تحليل السوق باستخدام الذكاء الاصطناعي
  Future&lt;void> updateMarketAnalysis(String pair) async {
    // هنا سيتم إضافة منطق تحليل السوق باستخدام ML/AI
    // يمكن استخدام مكتبات مثل TensorFlow Lite للتحليل
    final sentiment = MarketSentiment(
      bullishScore: 0.7,
      bearishScore: 0.3,
      keywords: ['positive momentum', 'strong support'],
      timestamp: DateTime.now(),
    );

    final technical = TechnicalAnalysis(
      trendStrength: 0.8,
      trendDirection: 'upward',
      indicators: {
        'RSI': 65.0,
        'MACD': 0.5,
      },
      timestamp: DateTime.now(),
    );

    _analyses[pair] = AIAnalysis(
      pair: pair,
      predictionAccuracy: 0.85,
      sentiment: sentiment,
      technical: technical,
      mlPredictions: {
        'price_direction': 'up',
        'confidence': 0.75,
      },
    );
    notifyListeners();
  }

  // Getters
  Map&lt;String, TradingBot> get bots => _bots;
  Map&lt;String, AIAnalysis> get analyses => _analyses;
  double get weeklyPnL => _weeklyPnL;
  int get totalTrades => _totalTrades;
  int get successfulTrades => _successfulTrades;
  double get successRate => _totalTrades > 0 ? _successfulTrades / _totalTrades * 100 : 0;
}
