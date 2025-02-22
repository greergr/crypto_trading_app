import 'package:flutter/material.dart';
import 'package:crypto_trading_app/models/trade_sequence.dart';

class TradeSequenceView extends StatelessWidget {
  final TradeSequence sequence;

  const TradeSequenceView({
    Key? key,
    required this.sequence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تسلسل المضاعفات - ${sequence.pair}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildMultiplierBadge(),
              ],
            ),
            const SizedBox(height: 16),
            _buildTradeStats(),
            const SizedBox(height: 16),
            _buildTradesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiplierBadge() {
    final multiplier = sequence.currentMultiplier;
    final maxMultiplier = sequence.maxMultiplications;
    final color = _getMultiplierColor(multiplier, maxMultiplier);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        'مضاعفة ${multiplier}x',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTradeStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'القيمة الحالية',
            '${sequence.currentAmount.toStringAsFixed(2)}%',
            Colors.blue,
          ),
        ),
        Expanded(
          child: _buildStatCard(
            'تيك بروفيت',
            '${sequence.currentTakeProfit.toStringAsFixed(2)}%',
            Colors.green,
          ),
        ),
        Expanded(
          child: _buildStatCard(
            'ستوب لوس',
            '${sequence.currentStopLoss.toStringAsFixed(2)}%',
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'سجل الصفقات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...sequence.trades.map((trade) => _buildTradeItem(trade)).toList(),
      ],
    );
  }

  Widget _buildTradeItem(SequenceTrade trade) {
    final isPending = trade.result == TradeResult.pending;
    final isProfit = trade.result == TradeResult.profit;
    final color = isPending
        ? Colors.orange
        : isProfit
            ? Colors.green
            : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isPending
              ? Icons.pending
              : isProfit
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
          color: color,
        ),
        title: Text(
          isPending
              ? 'صفقة جارية'
              : isProfit
                  ? 'ربح: ${trade.profit?.toStringAsFixed(2)}%'
                  : 'خسارة: ${trade.profit?.abs().toStringAsFixed(2)}%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'القيمة: ${trade.amount.toStringAsFixed(2)}% | '
          'تيك بروفيت: ${trade.takeProfit.toStringAsFixed(2)}% | '
          'ستوب لوس: ${trade.stopLoss.toStringAsFixed(2)}%',
        ),
        trailing: Text(
          isPending
              ? 'سعر الدخول: ${trade.entryPrice}'
              : 'سعر الخروج: ${trade.exitPrice}',
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Color _getMultiplierColor(int current, int max) {
    if (current == 1) return Colors.green;
    if (current == max) return Colors.red;
    final ratio = current / max;
    if (ratio <= 0.5) return Colors.orange;
    return Colors.deepOrange;
  }
}
