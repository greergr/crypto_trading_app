import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/trading_bot.dart';
import '../models/trading_pair.dart';
import '../providers/bot_manager.dart';
import '../utils/constants.dart';

class BotManagementScreen extends StatelessWidget {
  const BotManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bot Management'),
      ),
      body: Consumer<BotManager>(
        builder: (context, manager, _) {
          final bots = manager.bots;

          if (bots.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No trading bots yet',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: manager.canCreateBot
                        ? () => _showCreateBotDialog(context)
                        : null,
                    child: const Text('Create Bot'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: bots.length,
                itemBuilder: (context, index) {
                  final bot = bots[index];
                  return _buildBotCard(context, bot);
                },
              ),
              if (manager.canCreateBot)
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    onPressed: () => _showCreateBotDialog(context),
                    child: const Icon(Icons.add),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBotCard(BuildContext context, TradingBot bot) {
    final botManager = context.read<BotManager>();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trading Pair: ${bot.pair.symbol}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                _buildStatusChip(bot.state),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricsRow(bot),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showDeleteConfirmation(context, bot),
                  child: const Text('Delete'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: bot.state == BotState.running
                      ? () => botManager.stopBot(bot.id)
                      : () => botManager.startBot(bot.id),
                  child: Text(
                    bot.state == BotState.running ? 'Stop' : 'Start',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BotState state) {
    Color color;
    String label;

    switch (state) {
      case BotState.running:
        color = Colors.green;
        label = 'Running';
        break;
      case BotState.idle:
        color = Colors.grey;
        label = 'Idle';
        break;
      case BotState.error:
        color = Colors.red;
        label = 'Error';
        break;
    }

    return Chip(
      label: Text(
        label,
        style: TextStyle(color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white),
      ),
      backgroundColor: color.withOpacity(0.2),
      side: BorderSide(color: color),
    );
  }

  Widget _buildMetricsRow(TradingBot bot) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMetric('Total Trades', bot.totalTrades.toString()),
        _buildMetric(
          'Success Rate',
          bot.totalTrades > 0
              ? '${((bot.successfulTrades / bot.totalTrades) * 100).toStringAsFixed(1)}%'
              : '0%',
        ),
        _buildMetric(
          'Total Profit',
          '\$${bot.totalProfit.toStringAsFixed(2)}',
        ),
      ],
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _showCreateBotDialog(BuildContext context) async {
    final result = await showDialog<TradingPair>(
      context: context,
      builder: (context) => const CreateBotDialog(),
    );

    if (result != null) {
      final manager = context.read<BotManager>();
      await manager.createBot(result);
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    TradingBot bot,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bot'),
        content: Text(
          'Are you sure you want to delete the bot trading ${bot.pair.symbol}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final manager = context.read<BotManager>();
      await manager.deleteBot(bot.id);
    }
  }
}

class CreateBotDialog extends StatefulWidget {
  const CreateBotDialog({Key? key}) : super(key: key);

  @override
  State<CreateBotDialog> createState() => _CreateBotDialogState();
}

class _CreateBotDialogState extends State<CreateBotDialog> {
  String _selectedPair = 'BTCUSDT';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Trading Bot'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Trading Pair:'),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: _selectedPair,
            isExpanded: true,
            items: [
              'BTCUSDT',
              'ETHUSDT',
              'BNBUSDT',
              'ADAUSDT',
              'DOGEUSDT',
            ].map((pair) {
              return DropdownMenuItem(
                value: pair,
                child: Text(pair),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedPair = value);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              TradingPair(symbol: _selectedPair),
            );
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
