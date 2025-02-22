import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bot_config.dart';
import '../providers/bot_provider.dart';

class BotControlCard extends StatelessWidget {
  final BotConfig bot;

  const BotControlCard({
    Key? key,
    required this.bot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bot.name,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    Text(
                      bot.pair,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
                Switch(
                  value: bot.isActive,
                  onChanged: (value) {
                    final provider = context.read<BotProvider>();
                    if (value) {
                      provider.startBot(bot.id);
                    } else {
                      provider.stopBot(bot.id);
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  context,
                  'الصفقات اليوم',
                  '${bot.todayTradesCount}/${bot.maxDailyTrades}',
                ),
                _buildStatItem(
                  context,
                  'خسارة الأسبوع',
                  '${bot.weeklyLoss.toStringAsFixed(2)}%',
                  color: bot.weeklyLoss > 0 ? Colors.red : null,
                ),
                _buildStatItem(
                  context,
                  'المضاعفات',
                  '${bot.currentMultiplier}x',
                ),
              ],
            ),
            if (bot.isActive) ...[
              SizedBox(height: 16),
              LinearProgressIndicator(
                value: bot.todayTradesCount / bot.maxDailyTrades,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value, {
    Color? color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.caption,
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.subtitle2?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
