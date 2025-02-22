import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

enum AccountType {
  demo,    // حساب تجريبي
  live     // حساب حقيقي
}

class AccountManager {
  static final AccountManager _instance = AccountManager._internal();
  factory AccountManager() => _instance;
  AccountManager._internal();

  final _storage = const FlutterSecureStorage();
  
  AccountType _currentType = AccountType.demo;
  double _demoBalance = 10000.0;  // رصيد افتراضي
  Map<String, String> _apiKeys = {};

  AccountType get currentType => _currentType;
  double get demoBalance => _demoBalance;

  // تهيئة المدير
  Future<void> initialize() async {
    await _loadApiKeys();
    await _loadDemoBalance();
    await _loadAccountType();
  }

  // تحميل مفاتيح API
  Future<void> _loadApiKeys() async {
    final keys = await _storage.read(key: 'api_keys');
    if (keys != null) {
      _apiKeys = Map<String, String>.from(json.decode(keys));
    }
  }

  // تحميل الرصيد التجريبي
  Future<void> _loadDemoBalance() async {
    final balance = await _storage.read(key: 'demo_balance');
    if (balance != null) {
      _demoBalance = double.parse(balance);
    }
  }

  // تحميل نوع الحساب
  Future<void> _loadAccountType() async {
    final type = await _storage.read(key: 'account_type');
    if (type != null) {
      _currentType = AccountType.values.firstWhere(
        (e) => e.toString() == type,
        orElse: () => AccountType.demo,
      );
    }
  }

  // تغيير نوع الحساب
  Future<void> switchAccountType(AccountType type) async {
    _currentType = type;
    await _storage.write(
      key: 'account_type',
      value: type.toString(),
    );
  }

  // تحديث الرصيد التجريبي
  Future<void> updateDemoBalance(double newBalance) async {
    _demoBalance = newBalance;
    await _storage.write(
      key: 'demo_balance',
      value: newBalance.toString(),
    );
  }

  // إضافة مفاتيح API جديدة
  Future<void> addApiKeys({
    required String exchange,
    required String apiKey,
    required String secretKey,
  }) async {
    final encryptedSecret = await _encryptSecret(secretKey);
    
    _apiKeys[exchange] = json.encode({
      'api_key': apiKey,
      'secret_key': encryptedSecret,
    });

    await _storage.write(
      key: 'api_keys',
      value: json.encode(_apiKeys),
    );
  }

  // الحصول على مفاتيح API لمنصة معينة
  Future<Map<String, String>?> getApiKeys(String exchange) async {
    final keys = _apiKeys[exchange];
    if (keys == null) return null;

    final decoded = json.decode(keys);
    final decryptedSecret = await _decryptSecret(decoded['secret_key']);

    return {
      'api_key': decoded['api_key'],
      'secret_key': decryptedSecret,
    };
  }

  // حذف مفاتيح API
  Future<void> removeApiKeys(String exchange) async {
    _apiKeys.remove(exchange);
    await _storage.write(
      key: 'api_keys',
      value: json.encode(_apiKeys),
    );
  }

  // التحقق من وجود مفاتيح API لمنصة معينة
  bool hasApiKeys(String exchange) {
    return _apiKeys.containsKey(exchange);
  }

  // تشفير المفتاح السري
  Future<String> _encryptSecret(String secret) async {
    // هنا يمكن إضافة تشفير إضافي للمفتاح السري
    return secret;
  }

  // فك تشفير المفتاح السري
  Future<String> _decryptSecret(String encrypted) async {
    // هنا يمكن إضافة فك التشفير للمفتاح السري
    return encrypted;
  }

  // الحصول على قائمة المنصات المتصلة
  List<String> getConnectedExchanges() {
    return _apiKeys.keys.toList();
  }

  // التحقق من صلاحية مفاتيح API
  Future<bool> validateApiKeys(String exchange) async {
    final keys = await getApiKeys(exchange);
    if (keys == null) return false;

    try {
      // هنا يمكن إضافة التحقق من صلاحية المفاتيح مع المنصة
      return true;
    } catch (e) {
      return false;
    }
  }
}
