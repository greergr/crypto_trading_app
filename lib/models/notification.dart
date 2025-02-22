import 'package:uuid/uuid.dart';

enum NotificationType {
  profitTarget,
  lossLimit,
  tradeClosed,
  botStopped,
  marketAlert,
  systemAlert
}

enum NotificationPriority { high, medium, low }

class TradingNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime timestamp;
  final String? botId;
  final String? tradeId;
  bool isRead;

  TradingNotification({
    String? id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.timestamp,
    this.botId,
    this.tradeId,
    this.isRead = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString(),
      'priority': priority.toString(),
      'timestamp': timestamp.toIso8601String(),
      'botId': botId,
      'tradeId': tradeId,
      'isRead': isRead,
    };
  }

  factory TradingNotification.fromJson(Map<String, dynamic> json) {
    return TradingNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      botId: json['botId'],
      tradeId: json['tradeId'],
      isRead: json['isRead'] ?? false,
    );
  }
}
