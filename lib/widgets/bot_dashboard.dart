import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bot_analysis_provider.dart';
import '../models/trading_bot.dart';

class BotDashboard extends StatelessWidget {
  const BotDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer&lt;BotAnalysisProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            _buildBotControls(context, provider),
            _buildAnalytics(context, provider),
            _buildActiveBots(context, provider),
          ],
        );
      },
    );
  }

  Widget _buildBotControls(BuildContext context, BotAnalysisProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'لوحة التحكم بالبوتات',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBotButton(
                  context,
                  'BTC/USD',
                  BotType.thousandPoints,
                  provider,
                ),
                _buildBotButton(
                  context,
                  'ETH/USD',
                  BotType.thousandPoints,
                  provider,
                ),
                _buildBotButton(
                  context,
                  'BNB/USD',
                  BotType.tenEye,
                  provider,
                ),
                _buildBotButton(
                  context,
                  'SOL/USD',
                  BotType.tenEye,
                  provider,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotButton(
    BuildContext context,
    String pair,
    BotType type,
    BotAnalysisProvider provider,
  ) {
    final bot = provider.bots[pair];
    final isActive = bot?.isActive ?? false;

    return Column(
      children: [
        Text(pair),
        Switch(
          value: isActive,
          onChanged: (value) {
            if (bot == null) {
              final newBot = type == BotType.thousandPoints
                  ? TradingBot.thousandPoints(pair)
                  : TradingBot.tenEye(pair);
              provider.addBot(newBot);
            }
            provider.toggleBot(pair);
          },
        ),
        Text(type == BotType.thousandPoints ? 'ألف نقطة' : 'عشرة عين'),
      ],
    );
  }

  Widget _buildAnalytics(BuildContext context, BotAnalysisProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إحصائيات التداول',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('الربح/الخسارة الأسبوعي', '${provider.weeklyPnL.toStringAsFixed(2)}%'),
                _buildStat('نسبة النجاح', '${provider.successRate.toStringAsFixed(1)}%'),
                _buildStat('إجمالي الصفقات', provider.totalTrades.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActiveBots(BuildContext context, BotAnalysisProvider provider) {
    final activeBots = provider.bots.values.where((bot) => bot.isActive).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'البوتات النشطة',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeBots.length,
              itemBuilder: (context, index) {
                final bot = activeBots[index];
                return ListTile(
                  title: Text(bot.pair),
                  subtitle: Text(
                    bot.type == BotType.thousandPoints ? 'بوت الألف نقطة' : 'بوت العشرة عين',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('الربح: ${bot.profitTarget}%'),
                      Text('الخسارة: ${bot.stopLoss}%'),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
