import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/providers/reporting_provider.dart';
import 'package:crypto_trading_app/models/performance_report.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التقارير والتنبيهات'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'التقارير'),
              Tab(text: 'التنبيهات'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ReportsTab(),
            _AlertsTab(),
          ],
        ),
      ),
    );
  }
}

class _ReportsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ReportingProvider>(
      builder: (context, provider, _) {
        if (provider.reports.isEmpty) {
          return const Center(
            child: Text('لا توجد تقارير متاحة'),
          );
        }

        return ListView.builder(
          itemCount: provider.reports.length,
          itemBuilder: (context, index) {
            final report = provider.reports[index];
            return _ReportCard(report: report);
          },
        );
      },
    );
  }
}

class _ReportCard extends StatelessWidget {
  final PerformanceReport report;

  const _ReportCard({
    Key? key,
    required this.report,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        title: Text(
          report.type == ReportType.weekly
              ? 'التقرير الأسبوعي'
              : 'التقرير الشهري',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${report.startDate.toString().substring(0, 10)} - '
          '${report.endDate.toString().substring(0, 10)}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPerformanceMetrics(),
                const SizedBox(height: 16),
                _buildPerformanceChart(),
                const SizedBox(height: 16),
                _buildSignificantEvents(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMetricCard(
              'الربح الإجمالي',
              '${report.totalProfit.toStringAsFixed(2)}%',
              report.totalProfit >= 0 ? Colors.green : Colors.red,
            ),
            _buildMetricCard(
              'أقصى انخفاض',
              '${report.maxDrawdown.toStringAsFixed(2)}%',
              Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMetricCard(
              'معدل النجاح',
              '${report.winRate.toStringAsFixed(1)}%',
              Colors.blue,
            ),
            _buildMetricCard(
              'عامل الربح',
              report.profitFactor.toStringAsFixed(2),
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Column(
          children: [
            Text(
              label,
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
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart() {
    final spots = report.dailyPerformance.map((day) {
      final x = day.date.difference(report.startDate).inDays.toDouble();
      return FlSpot(x, day.profit);
    }).toList();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
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

  Widget _buildSignificantEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'أحداث مهمة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ...report.significantEvents.map((event) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(event),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

class _AlertsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ReportingProvider>(
      builder: (context, provider, _) {
        if (provider.alerts.isEmpty) {
          return const Center(
            child: Text('لا توجد تنبيهات'),
          );
        }

        return ListView.builder(
          itemCount: provider.alerts.length,
          itemBuilder: (context, index) {
            final alert = provider.alerts[index];
            return _AlertCard(alert: alert);
          },
        );
      },
    );
  }
}

class _AlertCard extends StatelessWidget {
  final TradeAlert alert;

  const _AlertCard({
    Key? key,
    required this.alert,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: ListTile(
        leading: _buildAlertIcon(),
        title: Text(
          alert.message,
          style: TextStyle(
            color: _getAlertColor(),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          alert.timestamp.toString().substring(0, 19),
          style: TextStyle(
            color: _getAlertColor().withOpacity(0.7),
          ),
        ),
        trailing: alert.tradeId != null
            ? IconButton(
                icon: const Icon(Icons.remove_red_eye),
                onPressed: () {
                  // عرض تفاصيل الصفقة
                },
              )
            : null,
      ),
    );
  }

  Widget _buildAlertIcon() {
    IconData iconData;
    switch (alert.type) {
      case AlertType.profitTarget:
        iconData = Icons.emoji_events;
        break;
      case AlertType.stopLoss:
        iconData = Icons.warning;
        break;
      case AlertType.takeProfit:
        iconData = Icons.trending_up;
        break;
      case AlertType.drawdown:
        iconData = Icons.trending_down;
        break;
      case AlertType.weeklyLoss:
        iconData = Icons.report_problem;
        break;
      case AlertType.multiplierIncrease:
        iconData = Icons.exposure_plus_2;
        break;
      case AlertType.botStopped:
        iconData = Icons.stop_circle;
        break;
      case AlertType.marketVolatility:
        iconData = Icons.show_chart;
        break;
    }

    return Icon(
      iconData,
      color: _getAlertColor(),
      size: 28,
    );
  }

  Color _getAlertColor() {
    switch (alert.priority) {
      case AlertPriority.low:
        return Colors.blue;
      case AlertPriority.medium:
        return Colors.orange;
      case AlertPriority.high:
        return Colors.deepOrange;
      case AlertPriority.critical:
        return Colors.red;
    }
  }
}
