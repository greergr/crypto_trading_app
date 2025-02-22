class MarketData {
  final String symbol;
  final double price;
  final double high24h;
  final double low24h;
  final double volume24h;
  final double priceChange24h;
  final double priceChangePercent24h;

  MarketData({
    required this.symbol,
    required this.price,
    required this.high24h,
    required this.low24h,
    required this.volume24h,
    required this.priceChange24h,
    required this.priceChangePercent24h,
  });

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'price': price,
      'high24h': high24h,
      'low24h': low24h,
      'volume24h': volume24h,
      'priceChange24h': priceChange24h,
      'priceChangePercent24h': priceChangePercent24h,
    };
  }

  factory MarketData.fromJson(Map<String, dynamic> json) {
    return MarketData(
      symbol: json['symbol'],
      price: json['price'],
      high24h: json['high24h'],
      low24h: json['low24h'],
      volume24h: json['volume24h'],
      priceChange24h: json['priceChange24h'],
      priceChangePercent24h: json['priceChangePercent24h'],
    );
  }
}
