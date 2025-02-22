import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/bot_provider.dart';

class PerformanceChart extends StatelessWidget {
  final List<FlSpot> spots;

  const PerformanceChart({
    super.key,
    this.spots = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BotProvider>(
      builder: (context, provider, _) {
        if (spots.isEmpty) {
          return const Center(
            child: Text('No performance data available'),
          );
        }

        return AspectRatio(
          aspectRatio: 2,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.shade300),
              ),
              minX: spots.first.x,
              maxX: spots.last.x,
              minY: spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b),
              maxY: spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Theme.of(context).primaryColor,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withAlpha(50),
                        Theme.of(context).primaryColor.withAlpha(10),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
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
