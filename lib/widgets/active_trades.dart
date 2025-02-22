import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/providers/trading_provider.dart';

class ActiveTrades extends StatelessWidget {
  const ActiveTrades({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TradingProvider>(
      builder: (context, provider, _) {
        final trades = provider.activeTrades;

        return Card(
          margin: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Active Trades',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: trades.isEmpty
                    ? const Center(
                        child: Text('No active trades'),
                      )
                    : ListView.builder(
                        itemCount: trades.length,
                        itemBuilder: (context, index) {
                          final trade = trades[index];
                          return ListTile(
                            title: Text(trade.pair),
                            subtitle: Text(
                              '${trade.type.toUpperCase()} @ ${trade.entryPrice}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${trade.amount} USDT',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => provider.closeTrade(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
