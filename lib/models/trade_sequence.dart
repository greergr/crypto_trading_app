class TradeSequence {
  final String botId;
  final String pair;
  final double initialAmount;
  final double initialTakeProfit;
  final double initialStopLoss;
  final int maxMultiplications;
  final List<SequenceTrade> trades;
  final DateTime startTime;
  
  TradeSequence({
    required this.botId,
    required this.pair,
    required this.initialAmount,
    required this.initialTakeProfit,
    required this.initialStopLoss,
    required this.maxMultiplications,
    required this.trades,
    required this.startTime,
  });

  int get currentMultiplier => trades.length + 1;
  bool get canMultiply => currentMultiplier <= maxMultiplications;
  
  double get currentAmount => initialAmount * _calculateMultiplier();
  double get currentTakeProfit => initialTakeProfit / _calculateMultiplier();
  double get currentStopLoss => initialStopLoss / _calculateMultiplier();
  
  double _calculateMultiplier() {
    var multiplier = 1.0;
    for (var i = 0; i < trades.length; i++) {
      if (trades[i].result == TradeResult.loss) {
        multiplier *= 2;
      } else {
        break;
      }
    }
    return multiplier;
  }

  TradeSequence addTrade(SequenceTrade trade) {
    return TradeSequence(
      botId: botId,
      pair: pair,
      initialAmount: initialAmount,
      initialTakeProfit: initialTakeProfit,
      initialStopLoss: initialStopLoss,
      maxMultiplications: maxMultiplications,
      trades: [...trades, trade],
      startTime: startTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'botId': botId,
      'pair': pair,
      'initialAmount': initialAmount,
      'initialTakeProfit': initialTakeProfit,
      'initialStopLoss': initialStopLoss,
      'maxMultiplications': maxMultiplications,
      'trades': trades.map((t) => t.toJson()).toList(),
      'startTime': startTime.toIso8601String(),
    };
  }

  factory TradeSequence.fromJson(Map<String, dynamic> json) {
    return TradeSequence(
      botId: json['botId'],
      pair: json['pair'],
      initialAmount: json['initialAmount'],
      initialTakeProfit: json['initialTakeProfit'],
      initialStopLoss: json['initialStopLoss'],
      maxMultiplications: json['maxMultiplications'],
      trades: (json['trades'] as List)
          .map((t) => SequenceTrade.fromJson(t))
          .toList(),
      startTime: DateTime.parse(json['startTime']),
    );
  }
}

enum TradeResult {
  profit,
  loss,
  pending
}

class SequenceTrade {
  final String id;
  final DateTime timestamp;
  final double amount;
  final double takeProfit;
  final double stopLoss;
  final double entryPrice;
  final TradeResult result;
  final double? exitPrice;
  final double? profit;

  SequenceTrade({
    required this.id,
    required this.timestamp,
    required this.amount,
    required this.takeProfit,
    required this.stopLoss,
    required this.entryPrice,
    required this.result,
    this.exitPrice,
    this.profit,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'amount': amount,
      'takeProfit': takeProfit,
      'stopLoss': stopLoss,
      'entryPrice': entryPrice,
      'result': result.toString(),
      'exitPrice': exitPrice,
      'profit': profit,
    };
  }

  factory SequenceTrade.fromJson(Map<String, dynamic> json) {
    return SequenceTrade(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      amount: json['amount'],
      takeProfit: json['takeProfit'],
      stopLoss: json['stopLoss'],
      entryPrice: json['entryPrice'],
      result: TradeResult.values.firstWhere(
        (e) => e.toString() == json['result'],
      ),
      exitPrice: json['exitPrice'],
      profit: json['profit'],
    );
  }
}
