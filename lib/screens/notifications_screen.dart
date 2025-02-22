import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../models/trading_notification.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('الإشعارات'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'الصفقات'),
              Tab(text: 'المخاطر'),
              Tab(text: 'النظام'),
            ],
          ),
        ),
        body: Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            return TabBarView(
              children: [
                // تنبيهات الصفقات
                _buildNotificationList(
                  provider.tradeNotifications,
                  onEmpty: 'لا توجد تنبيهات صفقات',
                ),
                
                // تحذيرات المخاطر
                _buildNotificationList(
                  provider.riskNotifications,
                  onEmpty: 'لا توجد تحذيرات مخاطر',
                ),
                
                // إشعارات النظام
                _buildNotificationList(
                  provider.systemNotifications,
                  onEmpty: 'لا توجد إشعارات نظام',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationList(
    List<TradingNotification> notifications, {
    required String onEmpty,
  }) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              onEmpty,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _NotificationCard(notification: notification);
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final TradingNotification notification;

  const _NotificationCard({
    Key? key,
    required this.notification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _buildIcon(),
        title: Text(notification.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            SizedBox(height: 4),
            Text(
              _formatDateTime(notification.timestamp),
              style: Theme.of(context).textTheme.caption,
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;

    switch (notification.type) {
      case NotificationType.trade:
        icon = Icons.show_chart;
        color = Colors.blue;
        break;
      case NotificationType.risk:
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case NotificationType.system:
        icon = Icons.info;
        color = Colors.grey;
        break;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}
