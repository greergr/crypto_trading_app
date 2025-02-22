import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/bot_settings.dart';
import '../models/trade_type.dart';
import 'binance_service.dart';
import 'ai_analyzer.dart';

class BotManager extends ChangeNotifier {
  final BinanceService _binanceService;
  final Map<String, Timer> _botTimers = {};
  final Map<String, BotSettings> _bots = {};
  final AIAnalyzer _aiAnalyzer = AIAnalyzer();

  BotManager(this._binanceService);

  List<BotSettings> get bots => _bots.values.toList();

  Future<void> startBot(
    String botId,
    String symbol, {
    double minimumConfidence = 0.7,
    Duration interval = const Duration(minutes: 5),
  }) async {
    if (_botTimers.containsKey(botId)) {
      return;
    }

    final timer = Timer.periodic(interval, (timer) async {
      try {
        final analysis = await _aiAnalyzer.analyzeMarket(symbol);
        
        if (analysis.confidence >= minimumConfidence) {
          final currentPrice = await _binanceService.getCurrentPrice(symbol);
          
          if (analysis.sentiment == MarketSentiment.bullish) {
            await _binanceService.placeTrade(
              symbol,
              TradeType.buy,
              0.1, // Default quantity
              stopLoss: currentPrice * 0.98, // 2% stop loss
              takeProfit: currentPrice * 1.05, // 5% take profit
            );
          } else if (analysis.sentiment == MarketSentiment.bearish) {
            await _binanceService.placeTrade(
              symbol,
              TradeType.sell,
              0.1, // Default quantity
              stopLoss: currentPrice * 1.02, // 2% stop loss
              takeProfit: currentPrice * 0.95, // 5% take profit
            );
          }
        }
      } catch (e) {
        debugPrint('Error in bot $botId: $e');
        stopBot(botId);
      }
    });

    _botTimers[botId] = timer;
    _bots[botId] = BotSettings(
      id: botId,
      name: 'Bot $botId',
      symbol: symbol,
      minimumConfidence: minimumConfidence,
      interval: interval,
      isActive: true,
    );
    notifyListeners();
  }

  void stopBot(String botId) {
    final timer = _botTimers[botId];
    if (timer != null) {
      timer.cancel();
      _botTimers.remove(botId);
      
      final bot = _bots[botId];
      if (bot != null) {
        _bots[botId] = bot.copyWith(isActive: false);
      }
      
      notifyListeners();
    }
  }

  void updateBotSettings(BotSettings settings) {
    if (_bots.containsKey(settings.id)) {
      stopBot(settings.id);
      if (settings.isActive) {
        startBot(
          settings.id,
          settings.symbol,
          minimumConfidence: settings.minimumConfidence,
          interval: settings.interval,
        );
      } else {
        _bots[settings.id] = settings;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    for (final timer in _botTimers.values) {
      timer.cancel();
    }
    _botTimers.clear();
    super.dispose();
  }
}
