import 'package:flutter/material.dart';
import '../models/trade_sequence.dart';

class ActiveTradesList extends StatelessWidget {
  final Map<String, TradeSequence> sequences;

  const ActiveTradesList({
    Key? key,
    required this.sequences,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: sequences.length,
      itemBuilder: (context, index) {
        final pair = sequences.keys.elementAt(index);
        final sequence = sequences[pair]!;
        final lastTrade = sequence.trades.lastWhere(
          (trade) => trade.result == TradeResult.pending,
          orElse: () => sequence.trades.last,
        );

        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      pair,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    _buildStatusChip(lastTrade.result),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سعر الدخول',
                          style: Theme.of(context).textTheme.caption,
                        ),
                        Text(
                          '\$${lastTrade.entryPrice.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تيك بروفيت',
                          style: Theme.of(context).textTheme.caption,
                        ),
                        Text(
                          '\$${(lastTrade.entryPrice * (1 + lastTrade.takeProfit / 100)).toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.subtitle2?.copyWith(
                                color: Colors.green,
                              ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ستوب لوس',
                          style: Theme.of(context).textTheme.caption,
                        ),
                        Text(
                          '\$${(lastTrade.entryPrice * (1 - lastTrade.stopLoss / 100)).toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.subtitle2?.copyWith(
                                color: Colors.red,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (sequence.trades.length > 1) ...[
                  SizedBox(height: 8),
                  Text(
                    'المضاعفة #${sequence.trades.length}',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(TradeResult result) {
    late final Color color;
    late final String text;

    switch (result) {
      case TradeResult.pending:
        color = Colors.blue;
        text = 'نشط';
        break;
      case TradeResult.profit:
        color = Colors.green;
        text = 'ربح';
        break;
      case TradeResult.loss:
        color = Colors.red;
        text = 'خسارة';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
