import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData get currentTheme {
    final baseTheme = _isDarkMode ? ThemeData.dark() : ThemeData.light();
    
    return baseTheme.copyWith(
      primaryColor: Colors.blue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.blue,
        foregroundColor: _isDarkMode ? Colors.white : Colors.white,
      ),
      cardTheme: CardTheme(
        color: _isDarkMode ? Colors.grey[850] : Colors.white,
        elevation: 4,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}
