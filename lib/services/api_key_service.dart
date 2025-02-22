import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class APIKeyService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  bool _isTestnet = true;
  String? _apiKey;
  String? _secretKey;

  bool get isTestnet => _isTestnet;
  bool get hasKeys => _apiKey != null && _secretKey != null;

  Future<void> initialize() async {
    _apiKey = await _storage.read(key: 'api_key');
    _secretKey = await _storage.read(key: 'secret_key');
    final testnetStr = await _storage.read(key: 'testnet');
    _isTestnet = testnetStr == 'true';
    notifyListeners();
  }

  Future<void> setApiKey(String apiKey) async {
    await _storage.write(key: 'api_key', value: apiKey);
    _apiKey = apiKey;
    notifyListeners();
  }

  Future<void> setSecretKey(String secretKey) async {
    await _storage.write(key: 'secret_key', value: secretKey);
    _secretKey = secretKey;
    notifyListeners();
  }

  Future<void> setTestnet(bool value) async {
    await _storage.write(key: 'testnet', value: value.toString());
    _isTestnet = value;
    notifyListeners();
  }

  Future<String> getApiKey() async {
    if (_apiKey == null) {
      throw Exception('API key not set');
    }
    return _apiKey!;
  }

  Future<String> getSecretKey() async {
    if (_secretKey == null) {
      throw Exception('Secret key not set');
    }
    return _secretKey!;
  }

  Future<void> clearKeys() async {
    await _storage.delete(key: 'api_key');
    await _storage.delete(key: 'secret_key');
    _apiKey = null;
    _secretKey = null;
    notifyListeners();
  }
}
