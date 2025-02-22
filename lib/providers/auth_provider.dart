import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AccountType { demo, live }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _hasPinSet = false;
  AccountType _accountType = AccountType.demo;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasPinSet => _hasPinSet;
  AccountType get accountType => _accountType;

  AuthProvider() {
    _checkPinStatus();
  }

  Future<void> _checkPinStatus() async {
    _hasPinSet = await _authService.hasPinSet();
    notifyListeners();
  }

  // إعداد PIN
  Future<void> setPin(String pin) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.setPin(pin);
      _hasPinSet = true;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // التحقق من PIN
  Future<bool> verifyPin(String pin) async {
    _isLoading = true;
    notifyListeners();

    try {
      final isValid = await _authService.verifyPin(pin);
      if (isValid) {
        _isAuthenticated = true;
        notifyListeners();
      }
      return isValid;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // المصادقة البيومترية
  Future<bool> authenticateWithBiometrics() async {
    _isLoading = true;
    notifyListeners();

    try {
      final canUseBiometrics = await _authService.canUseBiometrics();
      if (!canUseBiometrics) return false;

      final isAuthenticated = await _authService.authenticateWithBiometrics();
      if (isAuthenticated) {
        _isAuthenticated = true;
        notifyListeners();
      }
      return isAuthenticated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تسجيل مستخدم جديد
  Future<void> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
      );
      _accountType = AccountType.demo;
      _isAuthenticated = true;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تسجيل الدخول
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.login(
        email: email,
        password: password,
      );
      _accountType = _currentUser?.accountType ?? AccountType.demo;
      _isAuthenticated = true;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تحديث مفاتيح API باينانس
  Future<void> updateBinanceApiKeys({
    required String apiKey,
    required String secretKey,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.updateBinanceApiKeys(
        apiKey: apiKey,
        secretKey: secretKey,
      );
      _accountType = AccountType.live;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // التبديل بين الحساب التجريبي والحقيقي
  Future<void> switchAccountType(AccountType type) async {
    if (type == AccountType.live && _currentUser?.binanceApiKey == null) {
      throw Exception('يجب إضافة مفاتيح API باينانس أولاً');
    }

    _accountType = type;
    notifyListeners();
  }

  // تسجيل الخروج
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _isAuthenticated = false;
      _accountType = AccountType.demo;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
