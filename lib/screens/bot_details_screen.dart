import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bot_settings.dart';
import '../models/trade.dart';
import '../services/bot_manager.dart';
import '../services/ai_market_analyzer.dart';
import '../models/market_analysis.dart';

class BotDetailsScreen extends StatelessWidget {
  final BotSettings bot;

  const BotDetailsScreen({super.key, required this.bot});

  @override
  Widget build(BuildContext context) {
    final botManager = context.watch<BotManager>();
    final trades = botManager.getTradesForBot(bot.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(bot.name),
        actions: [
          IconButton(
            icon: Icon(bot.isActive ? Icons.stop : Icons.play_arrow),
            onPressed: () {
              if (bot.isActive) {
                botManager.stopBot(bot.id);
              } else {
                botManager.startBot(bot.id);
              }
            },
            tooltip: bot.isActive ? 'Stop Bot' : 'Start Bot',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _showDeleteConfirmation(context, botManager);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Bot'),
              ),
            ],
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Trades'),
                Tab(text: 'Analysis'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildOverviewTab(context),
                  _buildTradesTab(trades),
                  _buildAnalysisTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatusCard(context),
        const SizedBox(height: 16),
        _buildSettingsCard(context),
        const SizedBox(height: 16),
        _buildPerformanceCard(context),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bot Type: ${bot.botType == BotType.thousandPoint ? "Thousand Point" : "Ten Eye"}'),
                    const SizedBox(height: 8),
                    Text('Trading Pair: ${bot.tradingPair}'),
                    const SizedBox(height: 8),
                    Text('Account Type: ${bot.accountType == AccountType.demo ? "Demo" : "Live"}'),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: bot.isActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    bot.isActive ? 'Active' : 'Inactive',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text('Initial Capital: ${bot.initialCapital} USDT'),
            const SizedBox(height: 8),
            Text('Entry Percentage: ${bot.entryPercentage}%'),
            const SizedBox(height: 8),
            Text('Take Profit: ${bot.takeProfit}%'),
            const SizedBox(height: 8),
            Text('Stop Loss: ${bot.stopLoss}%'),
            const SizedBox(height: 8),
            Text('Max Loss Multiplier: ${bot.maxLossMultiplier}x'),
            const SizedBox(height: 8),
            Text('Daily Trades Limit: ${bot.dailyTradesLimit}'),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(BuildContext context) {
    // TODO: Implement actual performance metrics
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Text('Total Trades: 0'),
            const SizedBox(height: 8),
            const Text('Success Rate: 0%'),
            const SizedBox(height: 8),
            const Text('Total Profit: 0 USDT'),
            const SizedBox(height: 8),
            const Text('Weekly P/L: 0%'),
          ],
        ),
      ),
    );
  }

  Widget _buildTradesTab(List<Trade> trades) {
    if (trades.isEmpty) {
      return const Center(
        child: Text('No trades yet'),
      );
    }

    return ListView.builder(
      itemCount: trades.length,
      itemBuilder: (context, index) {
        final trade = trades[index];
        final isProfit = trade.result == TradeResult.profit;
        final profitColor = isProfit ? Colors.green : Colors.red;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text('${trade.type == TradeType.buy ? "Buy" : "Sell"} ${trade.tradingPair}'),
            subtitle: Text(
              'Entry: ${trade.entryPrice}\n'
              'Exit: ${trade.exitPrice ?? "Open"}\n'
              'Time: ${trade.openTime.toString()}',
            ),
            trailing: trade.profit != null
                ? Text(
                    '${trade.profit! >= 0 ? "+" : ""}${trade.profit!.toStringAsFixed(2)} USDT',
                    style: TextStyle(
                      color: profitColor,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : const Text('Open'),
          ),
        );
      },
    );
  }

  Widget _buildAnalysisTab(BuildContext context) {
    return FutureBuilder<MarketAnalysis>(
      future: context.read<AIMarketAnalyzer>().analyzeMarket(bot.tradingPair),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final analysis = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Market Analysis',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text('Sentiment: ${analysis.sentiment}'),
                    const SizedBox(height: 8),
                    Text('Signal Strength: ${analysis.signalStrength}'),
                    const SizedBox(height: 8),
                    Text('AI Confidence: ${(analysis.aiConfidence * 100).toStringAsFixed(1)}%'),
                    const SizedBox(height: 16),
                    Text('Recommendation: ${analysis.recommendation}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Technical Indicators',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ...analysis.technicalIndicators.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key),
                            Text(e.value.toStringAsFixed(2)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, BotManager botManager) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bot'),
        content: const Text('Are you sure you want to delete this bot?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      await botManager.deleteBot(bot.id);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}
