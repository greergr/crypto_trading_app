enum TradeType {
  buy,
  sell;

  @override
  String toString() {
    return name.toUpperCase();
  }
}

enum MarketSentiment {
  bullish,
  bearish,
  neutral
}

enum SignalStrength {
  strong,
  moderate,
  weak
}

enum TradeDirection {
  long,
  short,
  neutral
}
