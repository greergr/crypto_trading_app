import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:binance_spot/binance_spot.dart';
import 'dart:convert';
import 'dart:async';
import 'package:encrypt/encrypt.dart';

class ApiManager {
  static final ApiManager _instance = ApiManager._internal();
  factory ApiManager() => _instance;
  ApiManager._internal();

  final _storage = const FlutterSecureStorage();
  late BinanceSpot _liveClient;
  late BinanceSpot _testClient;
  
  bool _isTestnet = true;
  int _requestCount = 0;
  DateTime _lastRequestReset = DateTime.now();
  int? _dailyRequestsCount;
  DateTime? _lastDailyCountReset;
  
  // حدود API
  static const int MAX_REQUESTS_PER_MINUTE = 1200;
  static const int MAX_REQUESTS_PER_DAY = 100000;
  
  // حالة الاتصال
  bool get isConnected => _liveClient != null || _testClient != null;
  bool get isTestnet => _isTestnet;

  // تهيئة المدير
  Future<void> initialize() async {
    await _loadApiKeys();
    _startRequestCounter();
  }

  // تحميل مفاتيح API
  Future<void> _loadApiKeys() async {
    try {
      final encryptedKeys = await _storage.read(key: 'api_keys');
      if (encryptedKeys != null) {
        final keys = await _decryptApiKeys(encryptedKeys);
        await _initializeClients(keys);
      }
    } catch (e) {
      throw Exception('فشل في تحميل مفاتيح API: $e');
    }
  }

  // تشفير مفاتيح API
  Future<String> _encryptApiKeys(Map<String, String> keys) async {
    // استخدام خوارزمية تشفير قوية
    final key = await _storage.read(key: 'encryption_key');
    if (key == null) {
      final newKey = base64.encode(List<int>.generate(32, (_) => DateTime.now().millisecondsSinceEpoch % 256));
      await _storage.write(key: 'encryption_key', value: newKey);
    }
    
    // تشفير البيانات
    final encryptedData = await _encrypt(json.encode(keys), key!);
    return encryptedData;
  }

  // فك تشفير مفاتيح API
  Future<Map<String, String>> _decryptApiKeys(String encryptedKeys) async {
    final key = await _storage.read(key: 'encryption_key');
    if (key == null) throw Exception('مفتاح التشفير غير موجود');
    
    final decryptedData = await _decrypt(encryptedKeys, key);
    return Map<String, String>.from(json.decode(decryptedData));
  }

  // تهيئة عملاء API
  Future<void> _initializeClients(Map<String, String> keys) async {
    // تهيئة عميل التداول الحقيقي
    _liveClient = BinanceSpot(
      apiKey: keys['live_api_key'] ?? '',
      apiSecret: keys['live_api_secret'] ?? '',
    );

    // تهيئة عميل التداول التجريبي
    _testClient = BinanceSpot(
      apiKey: keys['test_api_key'] ?? '',
      apiSecret: keys['test_api_secret'] ?? '',
      baseUrl: 'https://testnet.binance.vision',
    );
  }

  // تحديث مفاتيح API
  Future<void> updateApiKeys({
    required String liveApiKey,
    required String liveApiSecret,
    required String testApiKey,
    required String testApiSecret,
  }) async {
    final keys = {
      'live_api_key': liveApiKey,
      'live_api_secret': liveApiSecret,
      'test_api_key': testApiKey,
      'test_api_secret': testApiSecret,
    };

    final encryptedKeys = await _encryptApiKeys(keys);
    await _storage.write(key: 'api_keys', value: encryptedKeys);
    await _initializeClients(keys);
    
    // إرسال إشعار بتحديث المفاتيح
    _notifyApiKeysUpdated();
  }

  // تبديل بين الحساب التجريبي والحقيقي
  Future<void> toggleTestnet(bool useTestnet) async {
    if (_isTestnet != useTestnet) {
      _isTestnet = useTestnet;
      // إيقاف جميع الصفقات المفتوحة قبل التبديل
      await _closeAllOpenOrders();
      // إعادة تهيئة العميل
      await _loadApiKeys();
    }
  }

  // إغلاق جميع الصفقات المفتوحة
  Future<void> _closeAllOpenOrders() async {
    try {
      final client = _isTestnet ? _testClient : _liveClient;
      final symbols = await client.exchangeInfo();
      
      for (var symbol in symbols.symbols) {
        await client.cancelAllOrders(symbol: symbol.symbol);
      }
    } catch (e) {
      throw Exception('فشل في إغلاق الصفقات المفتوحة: $e');
    }
  }

  // مراقبة عدد الطلبات
  void _startRequestCounter() {
    Timer.periodic(const Duration(minutes: 1), (_) {
      _requestCount = 0;
      _lastRequestReset = DateTime.now();
    });
  }

  // التحقق من حدود API
  bool _checkApiLimits() {
    final now = DateTime.now();
    
    // تحقق من حد الدقيقة
    if (_requestCount >= MAX_REQUESTS_PER_MINUTE) {
      final secondsToWait = 60 - now.difference(_lastRequestReset).inSeconds;
      throw RateLimitException('تم تجاوز حد الطلبات في الدقيقة. انتظر $secondsToWait ثانية');
    }
    
    // تحقق من الحد اليومي
    final dailyRequests = _calculateDailyRequests();
    if (dailyRequests >= MAX_REQUESTS_PER_DAY) {
      final hoursToWait = 24 - now.hour;
      throw RateLimitException('تم تجاوز حد الطلبات اليومي. انتظر $hoursToWait ساعة');
    }
    
    return true;
  }

  // حساب عدد الطلبات اليومية
  int _calculateDailyRequests() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    if (_dailyRequestsCount == null || _lastDailyCountReset?.day != now.day) {
      _dailyRequestsCount = 0;
      _lastDailyCountReset = now;
    }
    
    return _dailyRequestsCount!;
  }

  // تشفير البيانات
  Future<String> _encrypt(String data, String key) async {
    try {
      final keyBytes = base64.decode(key);
      final iv = List<int>.generate(16, (_) => DateTime.now().millisecondsSinceEpoch % 256);
      final encrypter = Encrypter(AES(Key(keyBytes)));
      final encrypted = encrypter.encrypt(data, iv: IV(iv));
      return json.encode({
        'data': encrypted.base64,
        'iv': base64.encode(iv),
      });
    } catch (e) {
      throw Exception('فشل في تشفير البيانات: $e');
    }
  }

  // فك تشفير البيانات
  Future<String> _decrypt(String encryptedData, String key) async {
    try {
      final keyBytes = base64.decode(key);
      final data = json.decode(encryptedData);
      final iv = IV(base64.decode(data['iv']));
      final encrypter = Encrypter(AES(Key(keyBytes)));
      return encrypter.decrypt64(data['data'], iv: iv);
    } catch (e) {
      throw Exception('فشل في فك تشفير البيانات: $e');
    }
  }

  // تنفيذ طلب API مع إعادة المحاولة
  Future<T> executeWithRetry<T>(
    Future<T> Function() apiCall, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    Exception? lastError;

    while (attempts < maxRetries) {
      try {
        _checkApiLimits();
        _requestCount++;
        _dailyRequestsCount = (_dailyRequestsCount ?? 0) + 1;
        
        final result = await apiCall();
        
        // إعادة ضبط عداد المحاولات في حالة النجاح
        attempts = 0;
        return result;
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        attempts++;
        
        if (e is RateLimitException) {
          // انتظار أطول في حالة تجاوز الحد
          await Future.delayed(delay * 2 * attempts);
        } else {
          await Future.delayed(delay * attempts);
        }
        
        // إعادة تهيئة العميل في حالة أخطاء الاتصال
        if (attempts == maxRetries ~/ 2) {
          await _loadApiKeys();
        }
      }
    }
    
    throw ApiException('فشل في تنفيذ الطلب بعد $maxRetries محاولات. آخر خطأ: $lastError');
  }

  // إشعار بتحديث المفاتيح
  void _notifyApiKeysUpdated() {
    // TODO: تنفيذ نظام الإشعارات
  }
}

class RateLimitException implements Exception {
  final String message;

  RateLimitException(this.message);
}

class ApiException implements Exception {
  final String message;

  ApiException(this.message);
}
