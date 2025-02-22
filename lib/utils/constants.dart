import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Crypto Trading Bot';
  static const String version = '1.0.0';
  
  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color successColor = Color(0xFF4CAF50);
  
  // App settings
  static const int maxActiveBots = 5;
  static const String botConfigKey = 'bot_config';

  // Trading settings
  static const double minTradingAmount = 10.0;
  static const double maxTradingAmount = 1000.0;
  static const double defaultTradingAmount = 100.0;

  // Trading Parameters
  static const int minDataPoints = 100;
  static const Duration tradingInterval = Duration(minutes: 1);
  static const Duration minUpdateInterval = Duration(seconds: 10);
  static const Duration minErrorRecoveryInterval = Duration(minutes: 5);
  static const int maxConsecutiveErrors = 3;
  
  // Market analysis settings
  static const int priceUpdateInterval = 60; // seconds
  static const int maxPriceHistoryLength = 100;
  static const int minRequiredPriceHistory = 20;

  // Technical indicators
  static const int rsiPeriod = 14;
  static const double rsiOversoldThreshold = 30.0;
  static const double rsiOverboughtThreshold = 70.0;

  static const int macdFastPeriod = 12;
  static const int macdSlowPeriod = 26;
  static const int macdSignalPeriod = 9;

  static const int bbPeriod = 20;
  static const double bbStdDev = 2.0;

  // Available Trading Pairs
  static const List<String> availableSymbols = [
    'BTCUSDT',
    'ETHUSDT',
    'BNBUSDT',
    'ADAUSDT',
    'DOGEUSDT',
    'XRPUSDT',
    'DOTUSDT',
    'LINKUSDT',
  ];
  
  // Model Constants
  static const String modelPath = 'assets/models/price_prediction.tflite';
  static const int predictionWindow = 60; // minutes
  static const double minConfidence = 0.6;
  
  // Notification Constants
  static const String notificationChannelId = 'trading_notifications';
  static const String notificationChannelName = 'Trading Notifications';
  static const String notificationChannelDescription = 'Notifications for trading events and bot status updates';
  
  // Storage Keys
  static const String tradingHistoryKey = 'trading_history';
  static const String apiKeyKey = 'api_key';
  static const String secretKeyKey = 'secret_key';
  
  // API Constants
  static const String baseUrl = 'https://api.binance.com';
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // UI settings
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultIconSize = 24.0;
  static const double defaultButtonHeight = 48.0;
  static const double defaultCardElevation = 4.0;

  // Chart settings
  static const int maxChartPoints = 50;
  static const double chartAspectRatio = 2.0;
  static const double chartLineWidth = 2.0;
  static const double chartDotSize = 4.0;
  static const double chartHeight = 300.0;
  
  // Error Messages
  static const String networkError = 'Network error occurred. Please check your connection.';
  static const String invalidApiKey = 'Invalid API key. Please check your credentials.';
  static const String insufficientFunds = 'Insufficient funds for trading.';
  static const String maxBotsReached = 'Maximum number of active bots reached.';
  static const String modelLoadError = 'Failed to load prediction model.';
  static const String tradingError = 'Error occurred while executing trade.';
}
