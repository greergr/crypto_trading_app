class TradingPair {
  final String symbol;

  const TradingPair({required this.symbol});

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
    };
  }

  factory TradingPair.fromJson(Map<String, dynamic> json) {
    return TradingPair(
      symbol: json['symbol'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TradingPair && other.symbol == symbol;
  }

  @override
  int get hashCode => symbol.hashCode;

  @override
  String toString() => symbol;
}
