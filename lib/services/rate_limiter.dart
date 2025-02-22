import 'dart:async';
import 'dart:collection';

class RateLimiter {
  static final RateLimiter _instance = RateLimiter._internal();
  factory RateLimiter() => _instance;
  RateLimiter._internal();

  // حدود Binance API
  static const int ORDERS_PER_SECOND = 10;
  static const int ORDERS_PER_DAY = 1000;
  static const int REQUESTS_PER_MINUTE = 1200;

  final Queue<DateTime> _orderTimestamps = Queue<DateTime>();
  final Queue<DateTime> _requestTimestamps = Queue<DateTime>();
  int _dailyOrderCount = 0;
  DateTime _dailyCounterReset = DateTime.now();

  Future<bool> canMakeOrder() async {
    _cleanupOldTimestamps();
    
    if (_dailyOrderCount >= ORDERS_PER_DAY) {
      return false;
    }

    final now = DateTime.now();
    if (_orderTimestamps.length >= ORDERS_PER_SECOND) {
      final oldestTimestamp = _orderTimestamps.first;
      if (now.difference(oldestTimestamp).inSeconds < 1) {
        return false;
      }
      _orderTimestamps.removeFirst();
    }

    _orderTimestamps.add(now);
    _dailyOrderCount++;
    return true;
  }

  Future<bool> canMakeRequest() async {
    _cleanupOldTimestamps();

    final now = DateTime.now();
    if (_requestTimestamps.length >= REQUESTS_PER_MINUTE) {
      final oldestTimestamp = _requestTimestamps.first;
      if (now.difference(oldestTimestamp).inMinutes < 1) {
        return false;
      }
      _requestTimestamps.removeFirst();
    }

    _requestTimestamps.add(now);
    return true;
  }

  void _cleanupOldTimestamps() {
    final now = DateTime.now();

    // إعادة تعيين العداد اليومي
    if (now.difference(_dailyCounterReset).inDays >= 1) {
      _dailyOrderCount = 0;
      _dailyCounterReset = now;
    }

    // تنظيف الطلبات القديمة
    while (_orderTimestamps.isNotEmpty &&
           now.difference(_orderTimestamps.first).inSeconds >= 1) {
      _orderTimestamps.removeFirst();
    }

    // تنظيف الطلبات في الدقيقة
    while (_requestTimestamps.isNotEmpty &&
           now.difference(_requestTimestamps.first).inMinutes >= 1) {
      _requestTimestamps.removeFirst();
    }
  }

  Future<void> waitForNextAvailableSlot() async {
    while (!(await canMakeRequest())) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> waitForNextOrderSlot() async {
    while (!(await canMakeOrder())) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void reset() {
    _orderTimestamps.clear();
    _requestTimestamps.clear();
    _dailyOrderCount = 0;
    _dailyCounterReset = DateTime.now();
  }
}
