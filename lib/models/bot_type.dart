enum BotType {
  thousandTrades,
  tenTrades,
}

class BotParameters {
  final BotType type;
  final int maxDailyTrades;
  final double entryPercentage;
  final double takeProfit;
  final double stopLoss;
  final int maxMultiplications;
  final double maxWeeklyLoss;

  const BotParameters._({
    required this.type,
    required this.maxDailyTrades,
    required this.entryPercentage,
    required this.takeProfit,
    required this.stopLoss,
    required this.maxMultiplications,
    required this.maxWeeklyLoss,
  });

  static const thousandTrades = BotParameters._(
    type: BotType.thousandTrades,
    maxDailyTrades: 1000,
    entryPercentage: 5.88,
    takeProfit: 0.18,
    stopLoss: 0.09,
    maxMultiplications: 5,
    maxWeeklyLoss: 20,
  );

  static const tenTrades = BotParameters._(
    type: BotType.tenTrades,
    maxDailyTrades: 10,
    entryPercentage: 5,
    takeProfit: 9,
    stopLoss: 4.5,
    maxMultiplications: 4,
    maxWeeklyLoss: 20,
  );

  static BotParameters getParameters(BotType type) {
    switch (type) {
      case BotType.thousandTrades:
        return thousandTrades;
      case BotType.tenTrades:
        return tenTrades;
    }
  }

  BotParameters copyWithMultiplier(int multiplier) {
    return BotParameters._(
      type: type,
      maxDailyTrades: maxDailyTrades,
      entryPercentage: entryPercentage,
      // تقليل التيك بروفيت والستوب لوس إلى النصف مع كل مضاعفة
      takeProfit: takeProfit / multiplier,
      stopLoss: stopLoss / multiplier,
      maxMultiplications: maxMultiplications,
      maxWeeklyLoss: maxWeeklyLoss,
    );
  }
}
