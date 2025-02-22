import 'package:flutter/material.dart';
import '../models/advanced_market_analysis.dart';

class AdvancedAnalysisCard extends StatelessWidget {
  final AdvancedMarketAnalysis analysis;

  const AdvancedAnalysisCard({
    Key? key,
    required this.analysis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Divider(),
          _buildTrendAnalysis(),
          Divider(),
          _buildMomentumIndicators(),
          Divider(),
          _buildVolatilityAnalysis(),
          Divider(),
          _buildVolumeAnalysis(),
          Divider(),
          _buildSupportResistance(),
          Divider(),
          _buildSentimentAnalysis(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                analysis.symbol,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'تحديث: ${_formatDateTime(analysis.timestamp)}',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          _buildMarketPhaseChip(),
        ],
      ),
    );
  }

  Widget _buildMarketPhaseChip() {
    Color color;
    String label;

    switch (analysis.marketPhase) {
      case MarketPhase.accumulation:
        color = Colors.blue;
        label = 'تجميع';
        break;
      case MarketPhase.markup:
        color = Colors.green;
        label = 'صعود';
        break;
      case MarketPhase.distribution:
        color = Colors.orange;
        label = 'توزيع';
        break;
      case MarketPhase.markdown:
        color = Colors.red;
        label = 'هبوط';
        break;
    }

    return Chip(
      label: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildTrendAnalysis() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تحليل الاتجاه',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIndicator(
                'قوة الاتجاه',
                analysis.adx.toStringAsFixed(2),
                analysis.isStrongTrend ? Colors.green : Colors.orange,
              ),
              _buildIndicator(
                'RSI',
                analysis.rsi.toStringAsFixed(2),
                _getRsiColor(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMomentumIndicators() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مؤشرات الزخم',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIndicator(
                'MACD',
                analysis.macd.toStringAsFixed(2),
                analysis.isMacdBullish ? Colors.green : Colors.red,
              ),
              _buildIndicator(
                'MACD Signal',
                analysis.macdSignal.toStringAsFixed(2),
                Colors.blue,
              ),
              _buildIndicator(
                'Histogram',
                analysis.macdHistogram.toStringAsFixed(2),
                analysis.macdHistogram > 0 ? Colors.green : Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVolatilityAnalysis() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تحليل التقلب',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIndicator(
                'ATR',
                analysis.atr.toStringAsFixed(2),
                Colors.blue,
              ),
              _buildIndicator(
                'مؤشر التقلب',
                analysis.volatilityIndex.toStringAsFixed(2),
                analysis.isHighVolatility ? Colors.orange : Colors.green,
              ),
              _buildIndicator(
                'عرض البولنجر',
                analysis.bollingerBandWidth.toStringAsFixed(2),
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeAnalysis() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تحليل الحجم',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIndicator(
                'OBV',
                analysis.obv.toStringAsFixed(0),
                Colors.blue,
              ),
              _buildIndicator(
                'متوسط الحجم',
                analysis.volumeEma.toStringAsFixed(0),
                analysis.isVolumeIncreasing ? Colors.green : Colors.red,
              ),
              _buildIndicator(
                'مؤشر تدفق المال',
                analysis.moneyFlowIndex.toStringAsFixed(2),
                _getMoneyFlowColor(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupportResistance() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مستويات الدعم والمقاومة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الدعم',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 4),
                    Text(
                      analysis.supportLevels
                          .take(3)
                          .map((e) => e.toStringAsFixed(2))
                          .join('\n'),
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المقاومة',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 4),
                    Text(
                      analysis.resistanceLevels
                          .take(3)
                          .map((e) => e.toStringAsFixed(2))
                          .join('\n'),
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentAnalysis() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تحليل المشاعر',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIndicator(
                'مؤشر المشاعر',
                analysis.sentimentScore.toStringAsFixed(2),
                _getSentimentColor(),
              ),
              _buildIndicator(
                'قوة العملة',
                analysis.currencyStrength.toStringAsFixed(2),
                analysis.currencyStrength > 0.5 ? Colors.green : Colors.red,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'العوامل المؤثرة:',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: analysis.sentimentFactors.entries.map((entry) {
              return Chip(
                label: Text(
                  '${entry.key}: ${(entry.value * 100).toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 12),
                ),
                backgroundColor: Colors.grey.shade200,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getRsiColor() {
    if (analysis.isOverbought) return Colors.red;
    if (analysis.isOversold) return Colors.green;
    return Colors.blue;
  }

  Color _getMoneyFlowColor() {
    if (analysis.moneyFlowIndex > 80) return Colors.red;
    if (analysis.moneyFlowIndex < 20) return Colors.green;
    return Colors.blue;
  }

  Color _getSentimentColor() {
    if (analysis.sentimentScore > 0.7) return Colors.green;
    if (analysis.sentimentScore < 0.3) return Colors.red;
    return Colors.orange;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
