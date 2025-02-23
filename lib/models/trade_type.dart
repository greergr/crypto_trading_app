enum TradeType {
  buy,
  sell
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

class MarketAnalysis {
  final MarketSentiment sentiment;
  final double confidence;

  MarketAnalysis({
    required this.sentiment,
    required this.confidence,
  });
}
