import 'dart:convert';
import '../models/trade_type.dart';

class BotSettings {
  final String id;
  final String name;
  final String symbol;
  final double minimumConfidence;
  final double quantity;
  final double? stopLoss;
  final double? takeProfit;
  final Duration interval;
  bool isActive;

  BotSettings({
    required this.id,
    required this.name,
    required this.symbol,
    this.minimumConfidence = 0.7,
    this.quantity = 0.1,
    this.stopLoss,
    this.takeProfit,
    this.interval = const Duration(minutes: 5),
    this.isActive = false,
  });

  factory BotSettings.fromJson(String jsonStr) {
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    return BotSettings(
      id: data['id'] as String,
      name: data['name'] as String,
      symbol: data['symbol'] as String,
      minimumConfidence: (data['minimumConfidence'] as num).toDouble(),
      quantity: (data['quantity'] as num).toDouble(),
      stopLoss: data['stopLoss'] != null ? (data['stopLoss'] as num).toDouble() : null,
      takeProfit: data['takeProfit'] != null ? (data['takeProfit'] as num).toDouble() : null,
      interval: Duration(minutes: data['intervalMinutes'] as int),
      isActive: data['isActive'] as bool,
    );
  }

  String toJson() {
    return json.encode({
      'id': id,
      'name': name,
      'symbol': symbol,
      'minimumConfidence': minimumConfidence,
      'quantity': quantity,
      'stopLoss': stopLoss,
      'takeProfit': takeProfit,
      'intervalMinutes': interval.inMinutes,
      'isActive': isActive,
    });
  }

  BotSettings copyWith({
    String? name,
    String? symbol,
    double? minimumConfidence,
    double? quantity,
    double? stopLoss,
    double? takeProfit,
    Duration? interval,
    bool? isActive,
  }) {
    return BotSettings(
      id: id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      minimumConfidence: minimumConfidence ?? this.minimumConfidence,
      quantity: quantity ?? this.quantity,
      stopLoss: stopLoss ?? this.stopLoss,
      takeProfit: takeProfit ?? this.takeProfit,
      interval: interval ?? this.interval,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'BotSettings{id: $id, name: $name, symbol: $symbol, minimumConfidence: $minimumConfidence, isActive: $isActive}';
  }
}
