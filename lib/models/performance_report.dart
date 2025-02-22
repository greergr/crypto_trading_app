class PerformanceReport {
  final String botId;
  final String pair;
  final DateTime startDate;
  final DateTime endDate;
  final ReportType type;
  final List<DailyPerformance> dailyPerformance;
  final double totalProfit;
  final double maxDrawdown;
  final int totalTrades;
  final int successfulTrades;
  final int failedTrades;
  final double winRate;
  final double averageProfit;
  final double averageLoss;
  final double profitFactor;
  final List<String> significantEvents;

  PerformanceReport({
    required this.botId,
    required this.pair,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.dailyPerformance,
    required this.totalProfit,
    required this.maxDrawdown,
    required this.totalTrades,
    required this.successfulTrades,
    required this.failedTrades,
    required this.winRate,
    required this.averageProfit,
    required this.averageLoss,
    required this.profitFactor,
    required this.significantEvents,
  });

  factory PerformanceReport.fromJson(Map<String, dynamic> json) {
    return PerformanceReport(
      botId: json['botId'],
      pair: json['pair'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      type: ReportType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      dailyPerformance: (json['dailyPerformance'] as List)
          .map((day) => DailyPerformance.fromJson(day))
          .toList(),
      totalProfit: json['totalProfit'],
      maxDrawdown: json['maxDrawdown'],
      totalTrades: json['totalTrades'],
      successfulTrades: json['successfulTrades'],
      failedTrades: json['failedTrades'],
      winRate: json['winRate'],
      averageProfit: json['averageProfit'],
      averageLoss: json['averageLoss'],
      profitFactor: json['profitFactor'],
      significantEvents: List<String>.from(json['significantEvents']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'botId': botId,
      'pair': pair,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'type': type.toString(),
      'dailyPerformance': dailyPerformance.map((day) => day.toJson()).toList(),
      'totalProfit': totalProfit,
      'maxDrawdown': maxDrawdown,
      'totalTrades': totalTrades,
      'successfulTrades': successfulTrades,
      'failedTrades': failedTrades,
      'winRate': winRate,
      'averageProfit': averageProfit,
      'averageLoss': averageLoss,
      'profitFactor': profitFactor,
      'significantEvents': significantEvents,
    };
  }
}

class DailyPerformance {
  final DateTime date;
  final int trades;
  final double profit;
  final double drawdown;
  final List<TradeAlert> alerts;
  final Map<String, double> metrics;

  DailyPerformance({
    required this.date,
    required this.trades,
    required this.profit,
    required this.drawdown,
    required this.alerts,
    required this.metrics,
  });

  factory DailyPerformance.fromJson(Map<String, dynamic> json) {
    return DailyPerformance(
      date: DateTime.parse(json['date']),
      trades: json['trades'],
      profit: json['profit'],
      drawdown: json['drawdown'],
      alerts: (json['alerts'] as List)
          .map((alert) => TradeAlert.fromJson(alert))
          .toList(),
      metrics: Map<String, double>.from(json['metrics']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'trades': trades,
      'profit': profit,
      'drawdown': drawdown,
      'alerts': alerts.map((alert) => alert.toJson()).toList(),
      'metrics': metrics,
    };
  }
}

class TradeAlert {
  final AlertType type;
  final String message;
  final DateTime timestamp;
  final double value;
  final AlertPriority priority;
  final String? tradeId;

  TradeAlert({
    required this.type,
    required this.message,
    required this.timestamp,
    required this.value,
    required this.priority,
    this.tradeId,
  });

  factory TradeAlert.fromJson(Map<String, dynamic> json) {
    return TradeAlert(
      type: AlertType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      value: json['value'],
      priority: AlertPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
      ),
      tradeId: json['tradeId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'value': value,
      'priority': priority.toString(),
      'tradeId': tradeId,
    };
  }
}

enum ReportType {
  weekly,
  monthly
}

enum AlertType {
  profitTarget,
  stopLoss,
  takeProfit,
  drawdown,
  weeklyLoss,
  multiplierIncrease,
  botStopped,
  marketVolatility
}

enum AlertPriority {
  low,
  medium,
  high,
  critical
}
