import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/trading_bot.dart';
import '../models/trading_pair.dart';
import '../models/market_analyzer.dart';
import '../utils/constants.dart';

class BotManager extends ChangeNotifier {
  final List<TradingBot> _bots = [];
  final SharedPreferences _prefs;

  BotManager(this._prefs) {
    _loadBots();
  }

  List<TradingBot> get bots => List.unmodifiable(_bots);
  bool get canCreateBot => _bots.length < AppConstants.maxActiveBots;

  Future<void> _loadBots() async {
    try {
      final botsJson = _prefs.getStringList('bots') ?? [];
      _bots.clear();
      
      for (final botJson in botsJson) {
        final botMap = json.decode(botJson);
        final pair = TradingPair(symbol: botMap['pair']['symbol']);
        final analyzer = MarketAnalyzer(pair);
        
        _bots.add(TradingBot(
          id: botMap['id'],
          pair: pair,
          analyzer: analyzer,
        ));
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading bots: $e');
    }
  }

  Future<void> _saveBots() async {
    try {
      final botsJson = _bots.map((bot) => json.encode(bot.toJson())).toList();
      await _prefs.setStringList('bots', botsJson);
    } catch (e) {
      debugPrint('Error saving bots: $e');
    }
  }

  Future<void> createBot(TradingPair pair) async {
    if (!canCreateBot) {
      throw Exception('Maximum number of bots reached');
    }

    final analyzer = MarketAnalyzer(pair);
    final bot = TradingBot(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      pair: pair,
      analyzer: analyzer,
    );

    _bots.add(bot);
    await _saveBots();
    notifyListeners();
  }

  Future<void> deleteBot(String id) async {
    _bots.removeWhere((bot) => bot.id == id);
    await _saveBots();
    notifyListeners();
  }

  Future<void> startBot(String id) async {
    final bot = _bots.firstWhere((bot) => bot.id == id);
    await bot.start();
    await _saveBots();
    notifyListeners();
  }

  Future<void> stopBot(String id) async {
    final bot = _bots.firstWhere((bot) => bot.id == id);
    await bot.stop();
    await _saveBots();
    notifyListeners();
  }

  double getTotalProfit() {
    return _bots.fold(0.0, (sum, bot) => sum + bot.totalProfit);
  }

  int getTotalTrades() {
    return _bots.fold(0, (sum, bot) => sum + bot.totalTrades);
  }

  double getSuccessRate() {
    final totalTrades = getTotalTrades();
    if (totalTrades == 0) return 0.0;
    
    final successfulTrades = _bots.fold(
      0,
      (sum, bot) => sum + bot.successfulTrades,
    );
    
    return successfulTrades / totalTrades;
  }
}
