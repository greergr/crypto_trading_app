import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/providers/trading_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class PerformanceAnalysis extends StatelessWidget {
  const PerformanceAnalysis({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TradingProvider>(
      builder: (context, provider, _) {
        final stats = provider.tradingStats;
        final profitPercent = stats.profitPercentage;
        final isPositive = profitPercent >= 0;

        return Card(
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'تحليل الأداء',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: provider.isRunning
                              ? provider.stopBot
                              : provider.startBot,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: provider.isRunning
                                ? Colors.red
                                : Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(provider.isRunning
                                  ? Icons.stop
                                  : Icons.play_arrow),
                              const SizedBox(width: 8),
                              Text(provider.isRunning ? 'إيقاف' : 'بدء'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CircularPercentIndicator(
                        radius: 60.0,
                        lineWidth: 10.0,
                        percent: stats.winRate / 100,
                        center: Text(
                          '${stats.winRate.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 20),
                        ),
                        progressColor: Colors.green,
                        backgroundColor: Colors.green.withOpacity(0.2),
                        header: const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text('نسبة النجاح'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: CircularPercentIndicator(
                        radius: 60.0,
                        lineWidth: 10.0,
                        percent: profitPercent.abs() / 100,
                        center: Text(
                          '${profitPercent.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 20,
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                        ),
                        progressColor: isPositive ? Colors.green : Colors.red,
                        backgroundColor:
                            (isPositive ? Colors.green : Colors.red)
                                .withOpacity(0.2),
                        header: const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text('نسبة الربح'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'الصفقات الناجحة',
                      stats.successfulTrades.toString(),
                      Colors.green,
                    ),
                    _buildStatCard(
                      'الصفقات الخاسرة',
                      stats.failedTrades.toString(),
                      Colors.red,
                    ),
                    _buildStatCard(
                      'إجمالي الصفقات',
                      stats.totalTrades.toString(),
                      Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearPercentIndicator(
                  lineHeight: 20.0,
                  percent: stats.profitProgress,
                  center: Text(
                    '${(stats.profitProgress * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.grey[300],
                  progressColor: _getProgressColor(stats.profitProgress),
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                ),
                const SizedBox(height: 8),
                Text(
                  'التقدم نحو هدف الـ 20%',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0) {
      // للخسائر
      final redIntensity = ((-progress) / 0.2).clamp(0.0, 1.0);
      return Colors.red.withOpacity(redIntensity);
    } else {
      // للأرباح
      final greenIntensity = (progress / 0.2).clamp(0.0, 1.0);
      return Colors.green.withOpacity(greenIntensity);
    }
  }
}
