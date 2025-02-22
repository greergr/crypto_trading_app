import 'dart:async';
import '../models/user_model.dart';
import '../models/trading_bot.dart';

class AccountTransitionManager {
  static final AccountTransitionManager _instance = AccountTransitionManager._internal();
  factory AccountTransitionManager() => _instance;
  AccountTransitionManager._internal();

  bool _isTransitioning = false;
  Timer? _transitionTimer;

  Future<void> switchAccount(
    AccountType newType,
    TradingBot tradingBot,
    Function(String) onError,
    Function() onSuccess,
  ) async {
    if (_isTransitioning) {
      onError('عملية تبديل الحساب جارية بالفعل');
      return;
    }

    _isTransitioning = true;

    try {
      // إيقاف جميع عمليات التداول الحالية
      await tradingBot.stopTrading();

      // انتظار إغلاق جميع الصفقات المفتوحة
      await _waitForOpenOrdersToClose(tradingBot);

      // تبديل نوع الحساب
      if (newType == AccountType.live) {
        await _switchToLiveAccount(tradingBot);
      } else {
        await _switchToTestnetAccount(tradingBot);
      }

      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      _isTransitioning = false;
    }
  }

  Future<void> _waitForOpenOrdersToClose(TradingBot tradingBot) async {
    int retryCount = 0;
    const maxRetries = 10;
    const checkInterval = Duration(seconds: 3);

    while (retryCount < maxRetries) {
      final hasOpenOrders = await tradingBot.hasOpenOrders();
      if (!hasOpenOrders) break;

      await Future.delayed(checkInterval);
      retryCount++;
    }

    if (retryCount >= maxRetries) {
      throw Exception('لم نتمكن من إغلاق جميع الصفقات المفتوحة');
    }
  }

  Future<void> _switchToLiveAccount(TradingBot tradingBot) async {
    // تحديث إعدادات البوت للحساب الحقيقي
    await tradingBot.updateConfig(
      isTestnet: false,
      maxLeverage: 3, // تقليل الرافعة المالية في الحساب الحقيقي
      maxPositionSize: 0.1, // تقليل حجم الصفقة في الحساب الحقيقي
    );
  }

  Future<void> _switchToTestnetAccount(TradingBot tradingBot) async {
    // تحديث إعدادات البوت للحساب التجريبي
    await tradingBot.updateConfig(
      isTestnet: true,
      maxLeverage: 10, // يمكن استخدام رافعة مالية أعلى في الحساب التجريبي
      maxPositionSize: 1.0, // يمكن استخدام أحجام صفقات أكبر في الحساب التجريبي
    );
  }

  void startTransitionTimeout(Duration timeout, Function() onTimeout) {
    _transitionTimer?.cancel();
    _transitionTimer = Timer(timeout, () {
      if (_isTransitioning) {
        _isTransitioning = false;
        onTimeout();
      }
    });
  }

  void cancelTransition() {
    _isTransitioning = false;
    _transitionTimer?.cancel();
  }

  bool get isTransitioning => _isTransitioning;
}
