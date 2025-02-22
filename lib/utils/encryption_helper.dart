import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionHelper {
  static const _storage = FlutterSecureStorage();
  static const _keyKey = 'encryption_key';

  // توليد مفتاح تشفير عشوائي
  static Future<String> _getOrCreateKey() async {
    String? key = await _storage.read(key: _keyKey);
    if (key == null) {
      key = base64Encode(List<int>.generate(32, (i) => DateTime.now().microsecondsSinceEpoch % 256));
      await _storage.write(key: _keyKey, value: key);
    }
    return key;
  }

  // تشفير البيانات
  static Future<String> encrypt(String data) async {
    final key = await _getOrCreateKey();
    final bytes = utf8.encode(data);
    final hash = await _computeHash(key, bytes);
    final encrypted = base64Encode(bytes);
    return '$encrypted.$hash';
  }

  // فك تشفير البيانات
  static Future<String> decrypt(String encryptedData) async {
    try {
      final parts = encryptedData.split('.');
      if (parts.length != 2) throw Exception('بيانات غير صالحة');

      final encrypted = parts[0];
      final hash = parts[1];

      final key = await _getOrCreateKey();
      final bytes = base64Decode(encrypted);
      final computedHash = await _computeHash(key, bytes);

      if (hash != computedHash) throw Exception('البيانات تم العبث بها');

      return utf8.decode(bytes);
    } catch (e) {
      throw Exception('فشل في فك التشفير: $e');
    }
  }

  // حساب التجزئة للتحقق من سلامة البيانات
  static Future<String> _computeHash(String key, List<int> data) async {
    final hmac = Hmac(sha256, utf8.encode(key));
    final digest = hmac.convert(data);
    return base64Encode(digest.bytes);
  }
}
