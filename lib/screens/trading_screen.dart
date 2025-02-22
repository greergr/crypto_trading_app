import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/providers/trading_provider.dart';
import 'package:crypto_trading_app/providers/auth_provider.dart';
import 'package:crypto_trading_app/widgets/trading_chart.dart';
import 'package:crypto_trading_app/widgets/active_trades.dart';
import 'package:crypto_trading_app/widgets/trading_controls.dart';
import 'package:crypto_trading_app/screens/account_settings_screen.dart';
import 'package:crypto_trading_app/widgets/performance_analysis.dart';
import 'package:crypto_trading_app/widgets/bot_manager.dart';
import 'package:crypto_trading_app/widgets/market_analysis_view.dart';

class TradingScreen extends StatefulWidget {
  const TradingScreen({Key? key}) : super(key: key);

  @override
  _TradingScreenState createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> {
  String selectedPair = 'BTCUSDT';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TradingProvider>().initializeTrading(selectedPair);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDemo = context.watch<AuthProvider>().isDemo;
    final balance = context.watch<TradingProvider>().demoBalance;

    return Scaffold(
      appBar: AppBar(
        title: Text(isDemo ? 'التداول التجريبي' : 'التداول الحقيقي'),
        actions: [
          if (isDemo)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'الرصيد: ${balance.toStringAsFixed(2)} USDT',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountSettingsScreen(),
                ),
              );
            },
          ),
          DropdownButton<String>(
            value: selectedPair,
            items: ['BTCUSDT', 'ETHUSDT', 'BNBUSDT'].map((String pair) {
              return DropdownMenuItem<String>(
                value: pair,
                child: Text(pair),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedPair = newValue;
                });
                context.read<TradingProvider>().changeTradingPair(newValue);
              }
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: TradingChart(pair: selectedPair),
                ),
                Expanded(
                  flex: 2,
                  child: MarketAnalysisView(pair: selectedPair),
                ),
                const Expanded(
                  flex: 2,
                  child: PerformanceAnalysis(),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Expanded(
                        child: ActiveTrades(),
                      ),
                      Expanded(
                        child: TradingControls(pair: selectedPair),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            flex: 1,
            child: BotManager(),
          ),
        ],
      ),
    );
  }
}
