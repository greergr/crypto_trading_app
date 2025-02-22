import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/trading_notification.dart';

class NotificationProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _maxNotifications = 100; // الحد الأقصى للإشعارات المحفوظة

  List<TradingNotification> _notifications = [];
  DateTime _lastUpdate = DateTime.now();
  Timer? _refreshTimer;

  NotificationProvider() {
    _loadNotifications();
    _startRefreshTimer();
  }

  // الحصول على الإشعارات حسب النوع
  List<TradingNotification> get tradeNotifications => _notifications
      .where((n) => n.type == NotificationType.trade)
      .toList();

  List<TradingNotification> get riskNotifications => _notifications
      .where((n) => n.type == NotificationType.risk)
      .toList();

  List<TradingNotification> get systemNotifications => _notifications
      .where((n) => n.type == NotificationType.system)
      .toList();

  // عدد الإشعارات غير المقروءة
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // تحميل الإشعارات من التخزين
  Future<void> _loadNotifications() async {
    try {
      final data = await _storage.read(key: 'notifications');
      if (data != null) {
        final List<dynamic> jsonList = json.decode(data);
        _notifications = jsonList
            .map((json) => TradingNotification.fromJson(json))
            .toList();
        _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        notifyListeners();
      }
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  // حفظ الإشعارات في التخزين
  Future<void> _saveNotifications() async {
    try {
      final jsonList = _notifications.map((n) => n.toJson()).toList();
      await _storage.write(
        key: 'notifications',
        value: json.encode(jsonList),
      );
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }

  // إضافة إشعار جديد
  Future<void> addNotification(TradingNotification notification) async {
    _notifications.insert(0, notification);
    
    // حذف الإشعارات القديمة إذا تجاوز العدد الحد الأقصى
    if (_notifications.length > _maxNotifications) {
      _notifications = _notifications.sublist(0, _maxNotifications);
    }
    
    await _saveNotifications();
    notifyListeners();
  }

  // تحديث حالة القراءة
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
      notifyListeners();
    }
  }

  // تحديث حالة القراءة لجميع الإشعارات
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    await _saveNotifications();
    notifyListeners();
  }

  // حذف إشعار
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
    notifyListeners();
  }

  // حذف جميع الإشعارات
  Future<void> clearAll() async {
    _notifications.clear();
    await _saveNotifications();
    notifyListeners();
  }

  // تحديث الإشعارات من الخادم
  Future<void> refreshNotifications() async {
    // TODO: قم بتنفيذ طلب HTTP للحصول على الإشعارات الجديدة
    _lastUpdate = DateTime.now();
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => refreshNotifications(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
