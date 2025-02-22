import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  final SharedPreferences _prefs;

  AuthService(this._prefs) {
    _loadUser();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  Future<void> _loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userJson = _prefs.getString('user');
      if (userJson != null) {
        _currentUser = User.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveUser(User user) async {
    await _prefs.setString('user', jsonEncode(user.toJson()));
    _currentUser = user;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual login logic with backend
      await Future.delayed(const Duration(seconds: 1)); // Simulated delay
      
      final user = User(
        id: '1',
        email: email,
        username: email.split('@')[0],
      );

      await _saveUser(user);
    } catch (e) {
      debugPrint('Error during login: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String username) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual registration logic with backend
      await Future.delayed(const Duration(seconds: 1)); // Simulated delay
      
      final user = User(
        id: DateTime.now().toString(),
        email: email,
        username: username,
      );

      await _saveUser(user);
    } catch (e) {
      debugPrint('Error during registration: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _prefs.remove('user');
      _currentUser = null;
    } catch (e) {
      debugPrint('Error during logout: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBinanceKeys(String apiKey, String secretKey) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual key update logic with backend
      await Future.delayed(const Duration(seconds: 1)); // Simulated delay
      
      final updatedUser = User(
        id: _currentUser!.id,
        email: _currentUser!.email,
        username: _currentUser!.username,
        binanceApiKey: apiKey,
        binanceSecretKey: secretKey,
      );

      await _saveUser(updatedUser);
    } catch (e) {
      debugPrint('Error updating Binance keys: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
