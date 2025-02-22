import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/trading_bot.dart';
import '../services/report_service.dart';

class AdvancedPerformanceChart extends StatefulWidget {
  final TradingBot bot;
  final Duration timeFrame;

  const AdvancedPerformanceChart({
    Key? key,
    required this.bot,
    this.timeFrame = const Duration(days: 7),
  }) : super(key: key);

  @override
  _AdvancedPerformanceChartState createState() => _AdvancedPerformanceChartState();
}

class _AdvancedPerformanceChartState extends State<AdvancedPerformanceChart> {
  final ReportService _reportService = ReportService();
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    final endDate = DateTime.now();
    final startDate = endDate.subtract(widget.timeFrame);
    
    _reports = await _reportService.getDailyReports(
      widget.bot.id,
      startDate: startDate,
      endDate: endDate,
    );
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildProfitChart(),
        const SizedBox(height: 20),
        _buildTradeDistribution(),
        const SizedBox(height: 20),
        _buildSuccessRateChart(),
      ],
    );
  }

  Widget _buildProfitChart() {
    final profitData = _reports.map((report) {
      return FlSpot(
        DateTime.parse(report['date']).millisecondsSinceEpoch.toDouble(),
        double.parse(report['daily_profit'].toString().replaceAll('%', '')),
      );
    }).toList();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toStringAsFixed(1)}%');
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Text(
                    '${date.day}/${date.month}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: profitData,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeDistribution() {
    final tradeData = _reports.map((report) {
      return {
        'date': DateTime.parse(report['date']),
        'successful': report['successful_trades'],
        'failed': report['failed_trades'],
      };
    }).toList();

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: tradeData.fold(0, (max, item) {
            final total = (item['successful'] as int) + (item['failed'] as int);
            return total > max ? total.toDouble() : max;
          }),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString());
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final date = tradeData[value.toInt()]['date'] as DateTime;
                  return Text(
                    '${date.day}/${date.month}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: true),
          barGroups: List.generate(tradeData.length, (index) {
            final item = tradeData[index];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: (item['successful'] as int).toDouble(),
                  color: Colors.green,
                  width: 16,
                ),
                BarChartRodData(
                  toY: (item['failed'] as int).toDouble(),
                  color: Colors.red,
                  width: 16,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSuccessRateChart() {
    final successRates = _reports.map((report) {
      final successRate = double.parse(
        report['success_rate'].toString().replaceAll('%', '')
      );
      return FlSpot(
        DateTime.parse(report['date']).millisecondsSinceEpoch.toDouble(),
        successRate,
      );
    }).toList();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toStringAsFixed(1)}%');
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Text(
                    '${date.day}/${date.month}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: successRates,
              isCurved: true,
              color: Colors.purple,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.purple.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
