import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:crypto_trading_app/services/theme_provider.dart';
import 'package:crypto_trading_app/services/api_key_service.dart';
import 'package:crypto_trading_app/services/binance_service.dart';
import 'package:crypto_trading_app/services/bot_manager.dart';
import 'package:crypto_trading_app/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiKeyService = APIKeyService();
  await apiKeyService.initialize();
  
  final binanceService = BinanceService(apiKeyService);
  final botManager = BotManager(binanceService);
  final themeProvider = ThemeProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: apiKeyService),
        ChangeNotifierProvider.value(value: botManager),
        Provider.value(value: binanceService),
      ],
      child: const CryptoTradingApp(),
    ),
  );
}

class CryptoTradingApp extends StatelessWidget {
  const CryptoTradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'Crypto Trading Bot',
      theme: themeProvider.currentTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      home: const HomeScreen(),
    );
  }
}
