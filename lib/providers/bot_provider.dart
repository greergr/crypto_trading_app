import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/trading_bot.dart';
import '../models/trading_pair.dart';
import '../models/market_analyzer.dart';
import '../utils/constants.dart';

class BotProvider with ChangeNotifier {
  final List<TradingBot> _bots = [];
  final SharedPreferences _prefs;
  final _uuid = const Uuid();
  final String _baseUrl = 'https://api.binance.com/api/v3';

  BotProvider(this._prefs) {
    _loadBots();
  }

  List<TradingBot> get bots => List.unmodifiable(_bots);

  Future<void> _loadBots() async {
    try {
      final botsJson = _prefs.getStringList('bots') ?? [];
      _bots.clear();
      for (final botJson in botsJson) {
        final botMap = json.decode(botJson);
        final pair = TradingPair.fromJson(botMap['pair']);
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

  Future<void> addBot(TradingPair pair) async {
    if (_bots.length >= AppConstants.maxActiveBots) {
      throw Exception('Maximum number of active bots reached');
    }

    final analyzer = MarketAnalyzer(pair);
    final bot = TradingBot(
      id: _uuid.v4(),
      pair: pair,
      analyzer: analyzer,
    );

    _bots.add(bot);
    await _saveBots();
    notifyListeners();
  }

  Future<void> removeBot(String id) async {
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

  double getOverallWinRate() {
    final totalTrades = getTotalTrades();
    if (totalTrades == 0) return 0.0;
    
    final successfulTrades = _bots.fold(
      0,
      (sum, bot) => sum + bot.successfulTrades,
    );
    
    return successfulTrades / totalTrades;
  }

  Future<Map<String, dynamic>> getMarketData(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/ticker/24hr?symbol=$symbol'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load market data');
      }
    } catch (e) {
      debugPrint('Error fetching market data: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getKlines(
    String symbol,
    String interval,
    int limit,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/klines?symbol=$symbol&interval=$interval&limit=$limit',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => {
          'time': e[0],
          'open': double.parse(e[1]),
          'high': double.parse(e[2]),
          'low': double.parse(e[3]),
          'close': double.parse(e[4]),
          'volume': double.parse(e[5]),
        }).toList();
      } else {
        throw Exception('Failed to load klines data');
      }
    } catch (e) {
      debugPrint('Error fetching klines data: $e');
      rethrow;
    }
  }
}
