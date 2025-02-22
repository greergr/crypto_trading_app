import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications;
  final SharedPreferences _prefs;
  final String _emailApiKey; // Your email service API key
  
  NotificationService(this._prefs)
      : _notifications = FlutterLocalNotificationsPlugin(),
        _emailApiKey = 'YOUR_EMAIL_API_KEY' {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(initSettings);
  }

  Future<void> showNotification({
    required String title,
    required String body,
    required NotificationType type,
    String? payload,
  }) async {
    // Check if notifications are enabled for this type
    final key = 'notifications_${type.toString().split('.').last}';
    final isEnabled = _prefs.getBool(key) ?? true;
    if (!isEnabled) return;

    // Show local notification
    const androidDetails = AndroidNotificationDetails(
      'trading_bot_channel',
      'Trading Bot Notifications',
      channelDescription: 'Notifications from your trading bot',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );

    // Send email if enabled
    if (await _shouldSendEmail(type)) {
      await _sendEmail(title, body);
    }

    // Save notification to history
    await _saveNotification(
      TradingNotification(
        id: DateTime.now().toString(),
        title: title,
        message: body,
        type: type,
        timestamp: DateTime.now(),
        isRead: false,
      ),
    );
  }

  Future<bool> _shouldSendEmail(NotificationType type) async {
    final key = 'email_notifications_${type.toString().split('.').last}';
    return _prefs.getBool(key) ?? false;
  }

  Future<void> _sendEmail(String subject, String body) async {
    try {
      final email = _prefs.getString('notification_email');
      if (email == null) return;

      // Using a hypothetical email service API
      final response = await http.post(
        Uri.parse('https://api.emailservice.com/v1/send'),
        headers: {
          'Authorization': 'Bearer $_emailApiKey',
          'Content-Type': 'application/json',
        },
        body: {
          'to': email,
          'subject': subject,
          'text': body,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send email: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending email: $e');
    }
  }

  Future<void> _saveNotification(TradingNotification notification) async {
    try {
      final notifications = await getNotifications();
      notifications.insert(0, notification);

      // Keep only last 100 notifications
      if (notifications.length > 100) {
        notifications.removeRange(100, notifications.length);
      }

      await _prefs.setString(
        'notifications',
        notifications.map((n) => n.toJson()).toList().toString(),
      );
    } catch (e) {
      debugPrint('Error saving notification: $e');
    }
  }

  Future<List<TradingNotification>> getNotifications() async {
    try {
      final String? notificationsJson = _prefs.getString('notifications');
      if (notificationsJson == null) return [];

      final List<dynamic> notificationsList = List.from(notificationsJson);
      return notificationsList
          .map((json) => TradingNotification.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      return [];
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final notifications = await getNotifications();
      final index = notifications.indexWhere((n) => n.id == notificationId);
      
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        await _prefs.setString(
          'notifications',
          notifications.map((n) => n.toJson()).toList().toString(),
        );
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final notifications = await getNotifications();
      notifications.removeWhere((n) => n.id == notificationId);
      
      await _prefs.setString(
        'notifications',
        notifications.map((n) => n.toJson()).toList().toString(),
      );
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      await _prefs.remove('notifications');
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }

  Future<void> updateNotificationSettings({
    required NotificationType type,
    required bool enabled,
    required bool emailEnabled,
    String? email,
  }) async {
    final notificationKey = 'notifications_${type.toString().split('.').last}';
    final emailKey = 'email_notifications_${type.toString().split('.').last}';

    await _prefs.setBool(notificationKey, enabled);
    await _prefs.setBool(emailKey, emailEnabled);

    if (email != null) {
      await _prefs.setString('notification_email', email);
    }
  }

  Future<Map<String, bool>> getNotificationSettings(NotificationType type) async {
    final notificationKey = 'notifications_${type.toString().split('.').last}';
    final emailKey = 'email_notifications_${type.toString().split('.').last}';

    return {
      'enabled': _prefs.getBool(notificationKey) ?? true,
      'emailEnabled': _prefs.getBool(emailKey) ?? false,
    };
  }

  String? getNotificationEmail() {
    return _prefs.getString('notification_email');
  }
}
