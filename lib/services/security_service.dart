import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Timer? _autoLogoutTimer;
  Timer? _apiCheckTimer;
  static const int AUTO_LOGOUT_DURATION = 15; // minutes
  static const String _encryptionKey = 'your_encryption_key_here'; // يجب تغييره في الإنتاج
  
  Future<void> secureStore(String key, String value) async {
    final encryptedValue = _encrypt(value);
    await _storage.write(key: key, value: encryptedValue);
  }
  
  Future<String?> secureRead(String key) async {
    final value = await _storage.read(key: key);
    return value != null ? _decrypt(value) : null;
  }

  void startAutoLogoutTimer(Function onLogout) {
    _autoLogoutTimer?.cancel();
    _autoLogoutTimer = Timer(
      Duration(minutes: AUTO_LOGOUT_DURATION),
      () => onLogout(),
    );
  }

  void resetAutoLogoutTimer() {
    _autoLogoutTimer?.cancel();
  }

  String _encrypt(String value) {
    final key = utf8.encode(_encryptionKey);
    final bytes = utf8.encode(value);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return base64.encode(bytes) + '.' + digest.toString();
  }

  String _decrypt(String encrypted) {
    final parts = encrypted.split('.');
    if (parts.length != 2) throw Exception('Invalid encrypted value');
    
    final data = base64.decode(parts[0]);
    final key = utf8.encode(_encryptionKey);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(data);
    
    if (digest.toString() != parts[1]) {
      throw Exception('Data tampering detected');
    }
    
    return utf8.decode(data);
  }

  void startApiHealthCheck(User user, Function(String) onApiError) {
    _apiCheckTimer?.cancel();
    _apiCheckTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _checkApiHealth(user, onApiError),
    );
  }

  Future<void> _checkApiHealth(User user, Function(String) onApiError) async {
    try {
      // اختبار صحة مفاتيح API
      final isValid = await _testApiKeys(user.binanceApiKey!, user.binanceSecretKey!);
      if (!isValid) {
        onApiError('مفاتيح API غير صالحة أو منتهية الصلاحية');
      }
    } catch (e) {
      onApiError(e.toString());
    }
  }

  Future<bool> _testApiKeys(String apiKey, String secretKey) async {
    try {
      // هنا نقوم باختبار بسيط لصحة المفاتيح
      // يمكن استخدام endpoint آمن من Binance مثل /api/v3/account
      // TODO: تنفيذ اختبار حقيقي لمفاتيح API
      return true;
    } catch (e) {
      return false;
    }
  }

  void stopAllTimers() {
    _autoLogoutTimer?.cancel();
    _apiCheckTimer?.cancel();
  }

  Future<void> clearSecureStorage() async {
    await _storage.deleteAll();
  }
}
