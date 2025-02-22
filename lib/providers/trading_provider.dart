import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:crypto_trading_app/models/market_data.dart';

class TradingProvider with ChangeNotifier {
  static const _binanceApiUrl = 'https://api.binance.com/api/v3';
  static const _binanceWsUrl = 'wss://stream.binance.com:9443/ws';
  
  bool _isDemo = true;
  double _demoBalance = 10000.0; // رصيد افتراضي 10,000 دولار
  Map<String, WebSocketChannel> _priceStreams = {};
  Map<String, MarketData> _marketData = {};
  bool _isAutomatedTrading = false;
  List<Map<String, dynamic>> _activeTrades = [];
  String _currentPair = 'BTCUSDT';
  Map<String, dynamic> _tradingStats = {
    'totalTrades': 0,
    'successfulTrades': 0,
    'totalProfit': 0.0,
    'winRate': 0.0,
  };

  bool get isDemo => _isDemo;
  double get demoBalance => _demoBalance;
  Map<String, MarketData> get marketData => _marketData;
  bool get isAutomatedTrading => _isAutomatedTrading;
  List<Map<String, dynamic>> get activeTrades => _activeTrades;
  String get currentPair => _currentPair;
  Map<String, dynamic> get tradingStats => _tradingStats;

  // تهيئة المزود
  TradingProvider() {
    _initializeMarketData();
  }

  // تهيئة بيانات السوق
  Future<void> _initializeMarketData() async {
    for (final pair in ['BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'SOLUSDT']) {
      await _connectToMarketStream(pair);
      await _fetchInitialMarketData(pair);
    }
  }

  // الاتصال بالبث المباشر للأسعار
  Future<void> _connectToMarketStream(String symbol) async {
    final channel = WebSocketChannel.connect(
      Uri.parse('$_binanceWsUrl/$symbol@ticker'),
    );

    channel.stream.listen((message) {
      final data = json.decode(message);
      _updateMarketData(symbol, data);
    });

    _priceStreams[symbol] = channel;
  }

  // جلب البيانات الأولية
  Future<void> _fetchInitialMarketData(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse('$_binanceApiUrl/ticker/24hr?symbol=$symbol'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _updateMarketData(symbol, data);
      }
    } catch (e) {
      print('Error fetching market data: $e');
    }
  }

  // تحديث بيانات السوق
  void _updateMarketData(String symbol, Map<String, dynamic> data) {
    _marketData[symbol] = MarketData(
      symbol: symbol,
      price: double.parse(data['lastPrice'] ?? data['c'] ?? '0'),
      high24h: double.parse(data['highPrice'] ?? data['h'] ?? '0'),
      low24h: double.parse(data['lowPrice'] ?? data['l'] ?? '0'),
      volume24h: double.parse(data['volume'] ?? data['v'] ?? '0'),
      priceChange24h: double.parse(data['priceChange'] ?? data['p'] ?? '0'),
      priceChangePercent24h: double.parse(data['priceChangePercent'] ?? data['P'] ?? '0'),
    );
    notifyListeners();
  }

  // تنفيذ صفقة في الحساب التجريبي
  Future<Map<String, dynamic>> executeDemoTrade({
    required String symbol,
    required double amount,
    required double takeProfit,
    required double stopLoss,
  }) async {
    if (!_isDemo) throw Exception('This method is for demo accounts only');
    
    final currentPrice = _marketData[symbol]?.price;
    if (currentPrice == null) throw Exception('No price data available for $symbol');
    
    final tradeAmount = _demoBalance * (amount / 100);
    if (tradeAmount > _demoBalance) throw Exception('Insufficient demo balance');
    
    // محاكاة تنفيذ الصفقة
    final tradeId = DateTime.now().millisecondsSinceEpoch.toString();
    final entryPrice = currentPrice;
    
    // إنشاء مراقب للسعر للتحقق من الوصول إلى التيك بروفيت أو الستوب لوس
    _monitorDemoTrade(
      tradeId: tradeId,
      symbol: symbol,
      entryPrice: entryPrice,
      amount: tradeAmount,
      takeProfit: takeProfit,
      stopLoss: stopLoss,
    );
    
    return {
      'trade_id': tradeId,
      'entry_price': entryPrice,
      'amount': tradeAmount,
      'take_profit_price': entryPrice * (1 + takeProfit / 100),
      'stop_loss_price': entryPrice * (1 - stopLoss / 100),
    };
  }

  // مراقبة الصفقة التجريبية
  void _monitorDemoTrade({
    required String tradeId,
    required String symbol,
    required double entryPrice,
    required double amount,
    required double takeProfit,
    required double stopLoss,
  }) {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentPrice = _marketData[symbol]?.price;
      if (currentPrice == null) return;
      
      final takeProfitPrice = entryPrice * (1 + takeProfit / 100);
      final stopLossPrice = entryPrice * (1 - stopLoss / 100);
      
      if (currentPrice >= takeProfitPrice) {
        // تحقق الربح
        final profit = amount * (takeProfit / 100);
        _demoBalance += profit;
        _onTradeComplete(tradeId, profit);
        timer.cancel();
      } else if (currentPrice <= stopLossPrice) {
        // تحقق الخسارة
        final loss = amount * (stopLoss / 100);
        _demoBalance -= loss;
        _onTradeComplete(tradeId, -loss);
        timer.cancel();
      }
    });
  }

  // معالجة اكتمال الصفقة
  void _onTradeComplete(String tradeId, double profitLoss) {
    notifyListeners();
    // إرسال إشعار للمستخدم
    if (profitLoss > 0) {
      print('Trade $tradeId completed with profit: \$${profitLoss.toStringAsFixed(2)}');
    } else {
      print('Trade $tradeId completed with loss: \$${profitLoss.abs().toStringAsFixed(2)}');
    }
  }

  // تحديث رصيد الحساب التجريبي
  Future<void> updateDemoBalance(double newBalance) async {
    _demoBalance = newBalance;
    notifyListeners();
  }

  // تبديل نوع الحساب
  void toggleAccountType(bool isDemo) {
    _isDemo = isDemo;
    notifyListeners();
  }

  // تهيئة التداول
  Future<void> initializeTrading(String pair) async {
    _currentPair = pair;
    await _connectToMarketStream(pair);
    await _fetchInitialMarketData(pair);
    notifyListeners();
  }

  // تغيير زوج التداول
  Future<void> changeTradingPair(String newPair) async {
    if (_currentPair != newPair) {
      _currentPair = newPair;
      await _connectToMarketStream(newPair);
      await _fetchInitialMarketData(newPair);
      notifyListeners();
    }
  }

  // تبديل وضع التداول الآلي
  void toggleAutomatedTrading() {
    _isAutomatedTrading = !_isAutomatedTrading;
    notifyListeners();
  }

  // إغلاق صفقة
  void closeTrade(int index) {
    if (index >= 0 && index < _activeTrades.length) {
      _activeTrades.removeAt(index);
      notifyListeners();
    }
  }

  // تنفيذ صفقة يدوية
  Future<void> executeManualTrade(String pair, String type, double amount, double price) async {
    if (!_isDemo && amount > _demoBalance) {
      throw Exception('رصيد غير كافي');
    }

    final trade = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'pair': pair,
      'type': type,
      'amount': amount,
      'entryPrice': price,
      'status': 'active',
      'timestamp': DateTime.now().toIso8601String(),
    };

    _activeTrades.add(trade);
    notifyListeners();
  }

  // الحصول على إعدادات الحساب
  Future<Map<String, dynamic>> getAccountSettings() async {
    return {
      'apiKey': '********',
      'secretKey': '********',
      'isDemo': _isDemo,
      'demoBalance': _demoBalance,
      'maxLossPerTrade': 2.0,
      'maxDailyTrades': 10,
    };
  }

  // تحديث إعدادات المنصة
  Future<void> updateExchangeSettings(Map<String, dynamic> settings) async {
    _isDemo = settings['isDemo'] ?? _isDemo;
    _demoBalance = settings['demoBalance'] ?? _demoBalance;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final stream in _priceStreams.values) {
      stream.sink.close();
    }
    super.dispose();
  }
}
