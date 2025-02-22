import 'package:uuid/uuid.dart';

enum TradeType { buy, sell }
enum TradeStatus { open, closed }
enum TradeResult { profit, loss, none }

class Trade {
  final String id;
  final String botId;
  final String tradingPair;
  final TradeType type;
  final double entryPrice;
  final double amount;
  final double takeProfit;
  final double stopLoss;
  final DateTime openTime;
  DateTime? closeTime;
  double? exitPrice;
  TradeStatus status;
  TradeResult result;
  double? profit;
  int lossMultiplier;

  Trade({
    String? id,
    required this.botId,
    required this.tradingPair,
    required this.type,
    required this.entryPrice,
    required this.amount,
    required this.takeProfit,
    required this.stopLoss,
    required this.openTime,
    this.closeTime,
    this.exitPrice,
    this.status = TradeStatus.open,
    this.result = TradeResult.none,
    this.profit,
    this.lossMultiplier = 1,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'botId': botId,
      'tradingPair': tradingPair,
      'type': type.toString(),
      'entryPrice': entryPrice,
      'amount': amount,
      'takeProfit': takeProfit,
      'stopLoss': stopLoss,
      'openTime': openTime.toIso8601String(),
      'closeTime': closeTime?.toIso8601String(),
      'exitPrice': exitPrice,
      'status': status.toString(),
      'result': result.toString(),
      'profit': profit,
      'lossMultiplier': lossMultiplier,
    };
  }

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      id: json['id'],
      botId: json['botId'],
      tradingPair: json['tradingPair'],
      type: TradeType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      entryPrice: json['entryPrice'],
      amount: json['amount'],
      takeProfit: json['takeProfit'],
      stopLoss: json['stopLoss'],
      openTime: DateTime.parse(json['openTime']),
      closeTime: json['closeTime'] != null
          ? DateTime.parse(json['closeTime'])
          : null,
      exitPrice: json['exitPrice'],
      status: TradeStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      result: TradeResult.values.firstWhere(
        (e) => e.toString() == json['result'],
      ),
      profit: json['profit'],
      lossMultiplier: json['lossMultiplier'] ?? 1,
    );
  }
}
