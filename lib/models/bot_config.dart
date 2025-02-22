import 'package:uuid/uuid.dart';

enum BotStrategy {
  thousandTrades,  // استراتيجية الألف نقطة
  tenTrades       // استراتيجية العشرة عين
}

enum BotState {
  stopped,
  running,
  paused,
  error
}

class BotConfig {
  final String id;
  final String name;
  final String symbol;
  final BotStrategy strategy;
  final double initialCapital;
  double currentBalance;
  int maxDailyTrades;
  double entryPercentage;
  double takeProfitPercentage;
  double stopLossPercentage;
  int maxLossMultiplier;
  int maxLossMultiplierCount;
  double maxWeeklyLossPercentage;
  BotState state;
  DateTime? lastTradeTime;
  int todayTradesCount;
  int consecutiveLosses;
  double weeklyPnL;

  BotConfig({
    String? id,
    required this.name,
    required this.symbol,
    required this.strategy,
    required this.initialCapital,
    this.currentBalance = 0,
    this.state = BotState.stopped,
  }) : id = id ?? const Uuid().v4() {
    // تهيئة الإعدادات بناءً على الاستراتيجية
    if (strategy == BotStrategy.thousandTrades) {
      maxDailyTrades = 1000;
      entryPercentage = 5.88;
      takeProfitPercentage = 0.18;
      stopLossPercentage = 0.09;
      maxLossMultiplier = 2;
      maxLossMultiplierCount = 5;
    } else {
      maxDailyTrades = 10;
      entryPercentage = 5.0;
      takeProfitPercentage = 9.0;
      stopLossPercentage = 4.5;
      maxLossMultiplier = 2;
      maxLossMultiplierCount = 4;
    }

    maxWeeklyLossPercentage = 20.0;
    currentBalance = initialCapital;
    todayTradesCount = 0;
    consecutiveLosses = 0;
    weeklyPnL = 0;
  }

  // نسخة محدثة من التكوين
  BotConfig copyWith({
    String? name,
    String? symbol,
    BotStrategy? strategy,
    double? initialCapital,
    double? currentBalance,
    BotState? state,
    DateTime? lastTradeTime,
    int? todayTradesCount,
    int? consecutiveLosses,
    double? weeklyPnL,
  }) {
    return BotConfig(
      id: id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      strategy: strategy ?? this.strategy,
      initialCapital: initialCapital ?? this.initialCapital,
      currentBalance: currentBalance ?? this.currentBalance,
      state: state ?? this.state,
    )
      ..lastTradeTime = lastTradeTime ?? this.lastTradeTime
      ..todayTradesCount = todayTradesCount ?? this.todayTradesCount
      ..consecutiveLosses = consecutiveLosses ?? this.consecutiveLosses
      ..weeklyPnL = weeklyPnL ?? this.weeklyPnL;
  }

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'strategy': strategy.toString(),
      'initialCapital': initialCapital,
      'currentBalance': currentBalance,
      'state': state.toString(),
      'lastTradeTime': lastTradeTime?.toIso8601String(),
      'todayTradesCount': todayTradesCount,
      'consecutiveLosses': consecutiveLosses,
      'weeklyPnL': weeklyPnL,
    };
  }

  // إنشاء من JSON
  factory BotConfig.fromJson(Map<String, dynamic> json) {
    final bot = BotConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      strategy: BotStrategy.values.firstWhere(
        (e) => e.toString() == json['strategy'],
      ),
      initialCapital: json['initialCapital'] as double,
      currentBalance: json['currentBalance'] as double,
      state: BotState.values.firstWhere(
        (e) => e.toString() == json['state'],
      ),
    );

    if (json['lastTradeTime'] != null) {
      bot.lastTradeTime = DateTime.parse(json['lastTradeTime'] as String);
    }
    
    bot.todayTradesCount = json['todayTradesCount'] as int;
    bot.consecutiveLosses = json['consecutiveLosses'] as int;
    bot.weeklyPnL = json['weeklyPnL'] as double;

    return bot;
  }

  // التحقق من إمكانية التداول
  bool canTrade() {
    if (state != BotState.running) return false;
    if (todayTradesCount >= maxDailyTrades) return false;
    if (weeklyPnL <= -maxWeeklyLossPercentage) return false;
    return true;
  }

  // تحديث إحصائيات التداول
  void updateStats({
    required bool isProfit,
    required double pnlAmount,
  }) {
    if (isProfit) {
      consecutiveLosses = 0;
    } else {
      consecutiveLosses++;
    }

    currentBalance += pnlAmount;
    weeklyPnL += (pnlAmount / initialCapital) * 100;
    todayTradesCount++;
    lastTradeTime = DateTime.now();
  }

  // حساب حجم الصفقة التالية
  double getNextTradeSize() {
    double baseSize = initialCapital * (entryPercentage / 100);
    if (consecutiveLosses == 0) return baseSize;
    
    // مضاعفة حجم الصفقة في حالة الخسارة
    int multiplier = 1;
    for (int i = 0; i < consecutiveLosses && i < maxLossMultiplierCount; i++) {
      multiplier *= maxLossMultiplier;
    }
    
    return baseSize * multiplier;
  }

  // إعادة تعيين الإحصائيات اليومية
  void resetDailyStats() {
    todayTradesCount = 0;
  }

  // إعادة تعيين الإحصائيات الأسبوعية
  void resetWeeklyStats() {
    weeklyPnL = 0;
  }
}
