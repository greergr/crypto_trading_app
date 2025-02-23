import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'services/bot_manager.dart';
import 'services/api_key_service.dart';
import 'services/binance_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final apiKeyService = APIKeyService();
  await apiKeyService.initialize();
  
  final binanceService = BinanceService(apiKeyService);
  final botManager = BotManager(binanceService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => apiKeyService),
        ChangeNotifierProvider(create: (_) => botManager),
        Provider.value(value: binanceService),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const CryptoTradingApp(),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData get currentTheme => _isDarkMode ? ThemeData.dark() : ThemeData.light();
}

class CryptoTradingApp extends StatelessWidget {
  const CryptoTradingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Crypto Trading Bot',
          theme: themeProvider.currentTheme,
          darkTheme: themeProvider.currentTheme,
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
      },
    );
  }
}
