import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/bot_manager.dart';
import '../services/binance_service.dart';
import '../models/market_analysis.dart';
import '../utils/logger.dart';
import '../l10n/app_localizations.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final Logger _logger = Logger('AnalysisScreen');
  String _selectedPair = 'BTCUSDT';
  MarketAnalysis? _analysis;
  List<FlSpot> _priceData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final botManager = context.read<BotManager>();
      final binanceService = context.read<BinanceService>();
      
      // Get market analysis
      _analysis = await botManager.getMarketAnalysis(_selectedPair);
      
      // Get historical prices for chart
      final prices = await binanceService.getHistoricalPrices(_selectedPair);
      _priceData = prices.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value);
      }).toList();

    } catch (e) {
      _logger.e('Error loading analysis: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analysis),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPairSelector(),
                  const SizedBox(height: 16),
                  _buildPriceChart(),
                  const SizedBox(height: 16),
                  if (_analysis != null) _buildAnalysisDetails(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadAnalysis,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildPairSelector() {
    return DropdownButton<String>(
      value: _selectedPair,
      items: const [
        DropdownMenuItem(value: 'BTCUSDT', child: Text('BTC/USDT')),
        DropdownMenuItem(value: 'ETHUSDT', child: Text('ETH/USDT')),
        DropdownMenuItem(value: 'BNBUSDT', child: Text('BNB/USDT')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedPair = value;
          });
          _loadAnalysis();
        }
      },
    );
  }

  Widget _buildPriceChart() {
    if (_priceData.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: const FlTitlesData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: _priceData,
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisDetails() {
    final analysis = _analysis!;
    final sentimentColor = analysis.sentiment == MarketSentiment.bullish
        ? Colors.green
        : analysis.sentiment == MarketSentiment.bearish
            ? Colors.red
            : Colors.grey;

    return Card(
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
            _buildAnalysisRow(
              'Sentiment',
              analysis.sentiment.toString().split('.').last,
              color: sentimentColor,
            ),
            _buildAnalysisRow(
              'Signal Strength',
              analysis.signalStrength.toString().split('.').last,
            ),
            _buildAnalysisRow(
              'Confidence',
              '${(analysis.confidence * 100).toStringAsFixed(1)}%',
            ),
            const Divider(),
            Text(
              'Technical Indicators',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...analysis.technicalIndicators.entries.map(
              (e) => _buildAnalysisRow(
                e.key.toUpperCase(),
                e.value.toStringAsFixed(2),
              ),
            ),
            const Divider(),
            Text(
              'Recommendation',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              analysis.recommendation,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
