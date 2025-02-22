enum NotificationType {
  trade,   // تنبيهات الصفقات
  risk,    // تحذيرات المخاطر
  system,  // إشعارات النظام
}

class TradingNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final bool isRead;

  TradingNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.data,
    this.isRead = false,
  });

  factory TradingNotification.fromJson(Map<String, dynamic> json) {
    return TradingNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'type': type.toString().split('.').last,
    'timestamp': timestamp.toIso8601String(),
    'data': data,
    'is_read': isRead,
  };

  TradingNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    Map<String, dynamic>? data,
    bool? isRead,
  }) {
    return TradingNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
    );
  }
}
