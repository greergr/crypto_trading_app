import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bot_manager.dart';
import '../widgets/performance_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: Consumer<BotManager>(
        builder: (context, manager, _) {
          final totalProfit = manager.getTotalProfit();
          final totalTrades = manager.getTotalTrades();
          final successRate = manager.getSuccessRate();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(
                  context,
                  totalProfit: totalProfit,
                  totalTrades: totalTrades,
                  successRate: successRate,
                ),
                const SizedBox(height: 24),
                _buildPerformanceChart(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required double totalProfit,
    required int totalTrades,
    required double successRate,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Performance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              context,
              label: 'Total Profit',
              value: '\$${totalProfit.toStringAsFixed(2)}',
              isPositive: totalProfit >= 0,
            ),
            const SizedBox(height: 8),
            _buildMetricRow(
              context,
              label: 'Total Trades',
              value: totalTrades.toString(),
            ),
            const SizedBox(height: 8),
            _buildMetricRow(
              context,
              label: 'Success Rate',
              value: '${(successRate * 100).toStringAsFixed(1)}%',
              isPositive: successRate >= 0.5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context, {
    required String label,
    required String value,
    bool? isPositive,
  }) {
    Color? valueColor;
    if (isPositive != null) {
      valueColor = isPositive ? Colors.green : Colors.red;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildPerformanceChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Performance Chart'),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: PerformanceChart(
                spots: [
                  const FlSpot(0, 0),
                  const FlSpot(1, 1),
                  const FlSpot(2, 1.5),
                  const FlSpot(3, 2),
                  const FlSpot(4, 1.8),
                  const FlSpot(5, 2.2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
