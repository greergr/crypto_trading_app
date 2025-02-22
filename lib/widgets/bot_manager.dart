import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/providers/bot_provider.dart';
import 'package:crypto_trading_app/models/bot_config.dart';

class BotManager extends StatelessWidget {
  const BotManager({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BotProvider>(
      builder: (context, botProvider, _) {
        final bots = botProvider.bots;
        
        return Card(
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'إدارة البوتات',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: bots.length,
                    itemBuilder: (context, index) {
                      final bot = bots[index];
                      return _buildBotCard(context, bot, index);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBotCard(BuildContext context, BotConfig bot, int index) {
    final isThousandTrades = bot.dailyTrades == 1000;
    final color = isThousandTrades ? Colors.blue : Colors.green;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(
              isThousandTrades ? Icons.flash_on : Icons.access_time,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bot.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'الصفقات اليوم: ${bot.todayTradesCount}/${bot.dailyTrades}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: bot.isActive,
              onChanged: (value) {
                context.read<BotProvider>().toggleBot(index, value);
              },
              activeColor: color,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildStatRow(
                  'نسبة الدخول',
                  '${(bot.entryPercentage * bot.currentMultiplier).toStringAsFixed(2)}%',
                  subtitle: bot.currentMultiplier > 1 
                      ? '(مضاعفة ${bot.currentMultiplier}x)'
                      : null,
                ),
                _buildStatRow(
                  'الربح المستهدف',
                  '${bot.takeProfit}%',
                ),
                _buildStatRow(
                  'وقف الخسارة',
                  '${bot.stopLoss}%',
                ),
                _buildStatRow(
                  'الخسارة الأسبوعية',
                  '${bot.weeklyLoss.toStringAsFixed(2)}%',
                  maxValue: bot.maxWeeklyLoss,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: bot.weeklyLoss / bot.maxWeeklyLoss,
                  backgroundColor: Colors.red.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    bot.weeklyLoss >= bot.maxWeeklyLoss 
                        ? Colors.red 
                        : Colors.red.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {
    String? subtitle,
    double? maxValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (maxValue != null) ...[
                Text(
                  ' / ${maxValue.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
              if (subtitle != null) ...[
                const SizedBox(width: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
