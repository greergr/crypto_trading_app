import 'dart:async';
import '../services/binance_service.dart';
import '../services/market_analyzer.dart';

enum BotType { thousandPoints, tenEyes }

enum BotStatus { idle, running, paused, error }

class TradingBot {
  final String id;
  final String name;
  final BotType type;
  final String tradingPair;
  final double tradeAmount;
  final double stopLoss;
  final double takeProfit;
  final int maxDailyTrades;
  final double maxWeeklyLoss;
  final bool isActive;
  final MarketAnalyzer marketAnalyzer;
  final BinanceService binanceService;
  
  BotStatus status = BotStatus.idle;
  int dailyTradeCount = 0;
  double weeklyPnL = 0.0;

  TradingBot({
    required this.id,
    required this.name,
    required this.type,
    required this.tradingPair,
    required this.tradeAmount,
    required this.stopLoss,
    required this.takeProfit,
    required this.maxDailyTrades,
    required this.maxWeeklyLoss,
    this.isActive = false,
    required this.marketAnalyzer,
    required this.binanceService,
  });

  TradingBot copyWith({
    String? id,
    String? name,
    BotType? type,
    String? tradingPair,
    double? tradeAmount,
    double? stopLoss,
    double? takeProfit,
    int? maxDailyTrades,
    double? maxWeeklyLoss,
    bool? isActive,
    MarketAnalyzer? marketAnalyzer,
    BinanceService? binanceService,
  }) {
    return TradingBot(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      tradingPair: tradingPair ?? this.tradingPair,
      tradeAmount: tradeAmount ?? this.tradeAmount,
      stopLoss: stopLoss ?? this.stopLoss,
      takeProfit: takeProfit ?? this.takeProfit,
      maxDailyTrades: maxDailyTrades ?? this.maxDailyTrades,
      maxWeeklyLoss: maxWeeklyLoss ?? this.maxWeeklyLoss,
      isActive: isActive ?? this.isActive,
      marketAnalyzer: marketAnalyzer ?? this.marketAnalyzer,
      binanceService: binanceService ?? this.binanceService,
    )
      ..status = status
      ..dailyTradeCount = dailyTradeCount
      ..weeklyPnL = weeklyPnL;
  }

  Future<void> start() async {
    if (status == BotStatus.running) return;
    
    try {
      status = BotStatus.running;
      _startAnalysis();
    } catch (e) {
      status = BotStatus.error;
      print('خطأ في بدء الروبوت: $e');
      rethrow;
    }
  }

  void _startAnalysis() {
    Timer.periodic(
      Duration(minutes: type == BotType.thousandPoints ? 5 : 15),
      (_) => _analyzeAndTrade(),
    );
  }

  Future<void> _analyzeAndTrade() async {
    if (status != BotStatus.running) return;
    if (dailyTradeCount >= maxDailyTrades) return;
    if (weeklyPnL <= -maxWeeklyLoss) return;

    try {
      final analysis = await marketAnalyzer.analyzeMarket(tradingPair);
      
      if (analysis.recommendation == 'Strong Buy') {
        await _executeTrade(TradeDirection.long);
      } else if (analysis.recommendation == 'Strong Sell') {
        await _executeTrade(TradeDirection.short);
      }
    } catch (e) {
      print('خطأ في تحليل السوق: $e');
      status = BotStatus.error;
    }
  }

  Future<void> _executeTrade(TradeDirection direction) async {
    try {
      final trade = await binanceService.placeTrade(
        pair: tradingPair,
        amount: tradeAmount,
        direction: direction,
        takeProfit: takeProfit,
        stopLoss: stopLoss,
      );
      
      dailyTradeCount++;
      // تحديث الأرباح/الخسائر الأسبوعية سيتم عند إغلاق الصفقة
    } catch (e) {
      print('خطأ في تنفيذ الصفقة: $e');
      throw Exception('فشل تنفيذ الصفقة: $e');
    }
  }

  void pause() {
    if (status != BotStatus.running) return;
    status = BotStatus.paused;
  }

  void resume() {
    if (status != BotStatus.paused) return;
    status = BotStatus.running;
    _startAnalysis();
  }

  void stop() {
    status = BotStatus.idle;
    _closeAllPositions();
  }

  Future<void> _closeAllPositions() async {
    try {
      await binanceService.closeAllPositions(tradingPair);
    } catch (e) {
      print('خطأ في إغلاق الصفقات: $e');
    }
  }

  void resetDailyStats() {
    dailyTradeCount = 0;
  }

  void resetWeeklyStats() {
    weeklyPnL = 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'tradingPair': tradingPair,
      'tradeAmount': tradeAmount,
      'stopLoss': stopLoss,
      'takeProfit': takeProfit,
      'maxDailyTrades': maxDailyTrades,
      'maxWeeklyLoss': maxWeeklyLoss,
      'isActive': isActive,
      'status': status.toString(),
      'dailyTradeCount': dailyTradeCount,
      'weeklyPnL': weeklyPnL,
    };
  }

  factory TradingBot.fromJson(
    Map<String, dynamic> json, {
    required MarketAnalyzer marketAnalyzer,
    required BinanceService binanceService,
  }) {
    return TradingBot(
      id: json['id'] as String,
      name: json['name'] as String,
      type: BotType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => BotType.thousandPoints,
      ),
      tradingPair: json['tradingPair'] as String,
      tradeAmount: json['tradeAmount'] as double,
      stopLoss: json['stopLoss'] as double,
      takeProfit: json['takeProfit'] as double,
      maxDailyTrades: json['maxDailyTrades'] as int,
      maxWeeklyLoss: json['maxWeeklyLoss'] as double,
      isActive: json['isActive'] as bool? ?? false,
      marketAnalyzer: marketAnalyzer,
      binanceService: binanceService,
    )
      ..status = BotStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => BotStatus.idle,
      )
      ..dailyTradeCount = json['dailyTradeCount'] as int? ?? 0
      ..weeklyPnL = json['weeklyPnL'] as double? ?? 0.0;
  }
}
