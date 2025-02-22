import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/providers/market_analysis_provider.dart';
import 'package:crypto_trading_app/models/market_analysis.dart';
import 'package:fl_chart/fl_chart.dart';

class MarketAnalysisView extends StatelessWidget {
  final String pair;

  const MarketAnalysisView({
    Key? key,
    required this.pair,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketAnalysisProvider>(
      builder: (context, provider, _) {
        final analysis = provider.analysisResults[pair];
        
        if (analysis == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Card(
          margin: const EdgeInsets.all(16.0),
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                _buildHeader(analysis),
                const TabBar(
                  tabs: [
                    Tab(text: 'تحليل فني'),
                    Tab(text: 'تحليل المشاعر'),
                    Tab(text: 'تحليل تنبؤي'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildTechnicalAnalysis(analysis.technical),
                      _buildSentimentAnalysis(analysis.sentiment),
                      _buildPredictiveAnalysis(analysis.predictive),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(MarketAnalysis analysis) {
    final score = analysis.overallScore;
    final color = _getScoreColor(score);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تحليل السوق - $pair',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  analysis.recommendation,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildScoreIndicator(
                  'فني',
                  analysis.technical.score,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildScoreIndicator(
                  'مشاعر',
                  analysis.sentiment.score,
                  Colors.purple,
                ),
              ),
              Expanded(
                child: _buildScoreIndicator(
                  'تنبؤي',
                  analysis.predictive.score,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalAnalysis(TechnicalAnalysis analysis) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الاتجاه الرئيسي: ${analysis.primaryTrend}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildIndicatorsGrid(analysis.indicators),
          const SizedBox(height: 16),
          _buildLevelsCard(
            'مستويات الدعم',
            analysis.supportLevels,
            Colors.green,
          ),
          const SizedBox(height: 8),
          _buildLevelsCard(
            'مستويات المقاومة',
            analysis.resistanceLevels,
            Colors.red,
          ),
          const SizedBox(height: 16),
          _buildPatternsCard(analysis.patterns),
        ],
      ),
    );
  }

  Widget _buildSentimentAnalysis(SentimentAnalysis analysis) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مزاج السوق: ${analysis.marketMood}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildSocialMetricsChart(analysis.socialMetrics),
          const SizedBox(height: 16),
          const Text(
            'أهم الأخبار',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ...analysis.topNews.map((news) => _buildNewsCard(news)),
          const SizedBox(height: 16),
          _buildKeywordCloud(analysis.keywordFrequency),
        ],
      ),
    );
  }

  Widget _buildPredictiveAnalysis(PredictiveAnalysis analysis) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الاتجاه المتوقع: ${analysis.trend}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildPredictionChart(analysis),
          const SizedBox(height: 16),
          _buildConfidenceIndicators(analysis.confidence),
        ],
      ),
    );
  }

  Widget _buildScoreIndicator(String label, double score, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 4,
          child: LinearProgressIndicator(
            value: score,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(score * 100).toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildIndicatorsGrid(Map<String, double> indicators) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2,
      ),
      itemCount: indicators.length,
      itemBuilder: (context, index) {
        final entry = indicators.entries.elementAt(index);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  entry.value.toStringAsFixed(2),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelsCard(String title, List<String> levels, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: levels.map((level) {
                return Chip(
                  label: Text(level),
                  backgroundColor: color.withOpacity(0.1),
                  labelStyle: TextStyle(color: color),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(NewsItem news) {
    final color = _getScoreColor(news.sentiment);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(news.title),
        subtitle: Text(news.source),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'تأثير: ${news.impact}',
            style: TextStyle(color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionChart(PredictiveAnalysis analysis) {
    final points = analysis.historicalData;
    
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            // خط القيم الفعلية
            LineChartBarData(
              spots: points.map((p) => FlSpot(
                p.timestamp.millisecondsSinceEpoch.toDouble(),
                p.actual,
              )).toList(),
              isCurved: true,
              color: Colors.blue,
              dotData: FlDotData(show: false),
            ),
            // خط التوقعات
            LineChartBarData(
              spots: points.map((p) => FlSpot(
                p.timestamp.millisecondsSinceEpoch.toDouble(),
                p.predicted,
              )).toList(),
              isCurved: true,
              color: Colors.orange,
              dotData: FlDotData(show: false),
              dashArray: [5, 5],
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.7) return Colors.green;
    if (score >= 0.6) return Colors.lightGreen;
    if (score >= 0.4) return Colors.orange;
    if (score >= 0.3) return Colors.deepOrange;
    return Colors.red;
  }
}
