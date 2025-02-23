import 'dart:convert';

class BotSettings {
  final String id;
  final String symbol;
  final double minimumConfidence;
  final Duration interval;
  final bool isActive;

  BotSettings({
    required this.id,
    required this.symbol,
    this.minimumConfidence = 0.7,
    this.interval = const Duration(minutes: 5),
    this.isActive = false,
  });

  factory BotSettings.fromJson(String jsonStr) {
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    return BotSettings(
      id: data['id'] as String,
      symbol: data['symbol'] as String,
      minimumConfidence: (data['minimumConfidence'] as num).toDouble(),
      interval: Duration(minutes: data['intervalMinutes'] as int),
      isActive: data['isActive'] as bool,
    );
  }

  String toJson() {
    return json.encode({
      'id': id,
      'symbol': symbol,
      'minimumConfidence': minimumConfidence,
      'intervalMinutes': interval.inMinutes,
      'isActive': isActive,
    });
  }

  BotSettings copyWith({
    String? id,
    String? symbol,
    double? minimumConfidence,
    Duration? interval,
    bool? isActive,
  }) {
    return BotSettings(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      minimumConfidence: minimumConfidence ?? this.minimumConfidence,
      interval: interval ?? this.interval,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'BotSettings{id: $id, symbol: $symbol, minimumConfidence: $minimumConfidence, isActive: $isActive}';
  }
}
