import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:crypto_trading_app/models/performance_report.dart';

class ReportingProvider with ChangeNotifier {
  final String _baseUrl = 'http://localhost:5000/api';
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  Timer? _reportTimer;
  
  List<PerformanceReport> _reports = [];
  List<TradeAlert> _alerts = [];
  DateTime? _lastReportDate;
  
  List<PerformanceReport> get reports => _reports;
  List<TradeAlert> get alerts => _alerts;

  ReportingProvider() {
    _initializeNotifications();
    _startReportingCycle();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
  }

  void _startReportingCycle() {
    _reportTimer?.cancel();
    _reportTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _checkAndGenerateReports(),
    );
  }

  Future<void> _checkAndGenerateReports() async {
    final now = DateTime.now();
    
    // التحقق من التقرير الأسبوعي
    if (_shouldGenerateWeeklyReport(now)) {
      await generateReport(ReportType.weekly);
    }
    
    // التحقق من التقرير الشهري
    if (_shouldGenerateMonthlyReport(now)) {
      await generateReport(ReportType.monthly);
    }
  }

  bool _shouldGenerateWeeklyReport(DateTime now) {
    if (_lastReportDate == null) return true;
    
    final lastWeek = ((_lastReportDate!.difference(DateTime(now.year, 1, 1)).inDays) / 7).floor();
    final currentWeek = ((now.difference(DateTime(now.year, 1, 1)).inDays) / 7).floor();
    
    return currentWeek > lastWeek;
  }

  bool _shouldGenerateMonthlyReport(DateTime now) {
    if (_lastReportDate == null) return true;
    return now.month != _lastReportDate!.month || now.year != _lastReportDate!.year;
  }

  Future<void> generateReport(ReportType type) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/generate-report'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'type': type.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode == 200) {
        final reportData = json.decode(response.body);
        final report = PerformanceReport.fromJson(reportData);
        
        _reports.add(report);
        _lastReportDate = DateTime.now();
        
        // إرسال إشعار بالتقرير الجديد
        await _showReportNotification(report);
        
        notifyListeners();
      }
    } catch (e) {
      print('Error generating report: $e');
    }
  }

  Future<void> processAlert(TradeAlert alert) async {
    _alerts.add(alert);
    
    // إرسال إشعار بناءً على نوع وأولوية التنبيه
    await _showAlertNotification(alert);
    
    notifyListeners();
  }

  Future<void> _showAlertNotification(TradeAlert alert) async {
    String title;
    String body = alert.message;
    
    switch (alert.type) {
      case AlertType.profitTarget:
        title = 'هدف الربح! 🎯';
        break;
      case AlertType.stopLoss:
        title = 'تنبيه وقف الخسارة ⚠️';
        break;
      case AlertType.takeProfit:
        title = 'تحقيق ربح! 💰';
        break;
      case AlertType.drawdown:
        title = 'تنبيه انخفاض ⬇️';
        break;
      case AlertType.weeklyLoss:
        title = 'تحذير خسارة أسبوعية ❌';
        break;
      case AlertType.multiplierIncrease:
        title = 'مضاعفة الصفقة 📈';
        break;
      case AlertType.botStopped:
        title = 'تم إيقاف البوت ⛔';
        break;
      case AlertType.marketVolatility:
        title = 'تقلبات في السوق 📊';
        break;
    }

    await _notifications.show(
      alert.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'trading_alerts',
          'Trading Alerts',
          importance: _getNotificationImportance(alert.priority),
          priority: _getNotificationPriority(alert.priority),
          enableLights: true,
          enableVibration: true,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> _showReportNotification(PerformanceReport report) async {
    final title = report.type == ReportType.weekly
        ? 'التقرير الأسبوعي جاهز 📊'
        : 'التقرير الشهري جاهز 📈';
        
    final body = 'الربح الإجمالي: ${report.totalProfit.toStringAsFixed(2)}% | '
        'معدل النجاح: ${report.winRate.toStringAsFixed(1)}%';

    await _notifications.show(
      report.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'trading_reports',
          'Trading Reports',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Importance _getNotificationImportance(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.low:
        return Importance.low;
      case AlertPriority.medium:
        return Importance.defaultImportance;
      case AlertPriority.high:
        return Importance.high;
      case AlertPriority.critical:
        return Importance.max;
    }
  }

  Priority _getNotificationPriority(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.low:
        return Priority.low;
      case AlertPriority.medium:
        return Priority.defaultPriority;
      case AlertPriority.high:
        return Priority.high;
      case AlertPriority.critical:
        return Priority.max;
    }
  }

  void clearAlerts() {
    _alerts.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _reportTimer?.cancel();
    super.dispose();
  }
}
