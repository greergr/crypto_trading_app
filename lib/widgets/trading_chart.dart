import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/providers/trading_provider.dart';
import '../utils/performance_optimizer.dart';

class TradingChart extends StatelessWidget {
  final String pair;

  const TradingChart({Key? key, required this.pair}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TradingProvider>(
      builder: (context, provider, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pair,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(show: true),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            const FlSpot(0, 0),
                            const FlSpot(1, 1),
                          ],
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TradingChartWidget extends StatelessWidget {
  final String pair;
  final List<FlSpot> data;
  final double minY;
  final double maxY;

  const TradingChartWidget({
    Key? key, 
    required this.pair,
    required this.data,
    this.minY = 0,
    this.maxY = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pair,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: data.length.toDouble() - 1,
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
