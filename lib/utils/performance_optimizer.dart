import 'dart:collection';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerformanceOptimizer {
  // حجم الذاكرة المؤقتة للبيانات
  static const int _maxCacheSize = 100;
  
  // ذاكرة مؤقتة للبيانات
  static final _dataCache = LinkedHashMap<String, _CacheEntry>();
  
  // مدة صلاحية البيانات المخزنة مؤقتاً
  static const Duration _cacheDuration = Duration(minutes: 5);
  
  // تخزين البيانات في الذاكرة المؤقتة
  static void cacheData(String key, dynamic data) {
    // حذف أقدم البيانات إذا تجاوز حجم الذاكرة المؤقتة الحد الأقصى
    if (_dataCache.length >= _maxCacheSize) {
      _dataCache.remove(_dataCache.keys.first);
    }
    
    _dataCache[key] = _CacheEntry(
      data: data,
      timestamp: DateTime.now(),
    );
  }
  
  // استرجاع البيانات من الذاكرة المؤقتة
  static dynamic getCachedData(String key) {
    final entry = _dataCache[key];
    if (entry == null) return null;
    
    // التحقق من صلاحية البيانات
    if (DateTime.now().difference(entry.timestamp) > _cacheDuration) {
      _dataCache.remove(key);
      return null;
    }
    
    return entry.data;
  }
  
  // حذف البيانات منتهية الصلاحية
  static void cleanExpiredCache() {
    final now = DateTime.now();
    _dataCache.removeWhere((key, entry) {
      return now.difference(entry.timestamp) > _cacheDuration;
    });
  }
  
  // تحسين أداء القوائم
  static Widget optimizedListView<T>({
    required List<T> items,
    required Widget Function(BuildContext, T) itemBuilder,
    bool shrinkWrap = false,
  }) {
    return ListView.builder(
      itemCount: items.length,
      shrinkWrap: shrinkWrap,
      itemBuilder: (context, index) => itemBuilder(context, items[index]),
    );
  }
  
  // تحسين أداء الصور
  static Widget optimizedImage(
    String imageUrl, {
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.error);
      },
    );
  }
  
  // تحسين أداء التحديثات في الوقت الحقيقي
  static Stream<T> optimizedStream<T>(
    Stream<T> stream, {
    Duration? throttleDuration,
  }) {
    if (throttleDuration != null) {
      return stream.throttle(throttleDuration);
    }
    return stream;
  }
  
  // تخزين البيانات محلياً
  static Future<void> saveLocalData(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    if (data is String) {
      await prefs.setString(key, data);
    } else if (data is int) {
      await prefs.setInt(key, data);
    } else if (data is double) {
      await prefs.setDouble(key, data);
    } else if (data is bool) {
      await prefs.setBool(key, data);
    } else if (data is List<String>) {
      await prefs.setStringList(key, data);
    }
  }
  
  // استرجاع البيانات المحلية
  static Future<T?> getLocalData<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key) as T?;
  }
  
  // تنظيف الذاكرة
  static void dispose() {
    _dataCache.clear();
  }
}

// نموذج لتخزين البيانات في الذاكرة المؤقتة
class _CacheEntry {
  final dynamic data;
  final DateTime timestamp;

  _CacheEntry({
    required this.data,
    required this.timestamp,
  });
}

// امتداد للتحكم في معدل تحديث البيانات
extension StreamThrottleExtension<T> on Stream<T> {
  Stream<T> throttle(Duration duration) {
    StreamController<T>? controller;
    Timer? timer;
    StreamSubscription<T>? subscription;

    void startTimer(T data) {
      timer?.cancel();
      timer = Timer(duration, () {
        controller?.add(data);
        timer = null;
      });
    }

    controller = StreamController<T>(
      onListen: () {
        subscription = listen((data) => startTimer(data));
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: () {
        timer?.cancel();
        subscription?.cancel();
      },
    );

    return controller.stream;
  }
}
