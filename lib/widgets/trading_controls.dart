import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trading_provider.dart';

class TradingControls extends StatefulWidget {
  const TradingControls({Key? key}) : super(key: key);

  @override
  State<TradingControls> createState() => _TradingControlsState();
}

class _TradingControlsState extends State<TradingControls> {
  final _amountController = TextEditingController();
  String _selectedType = 'شراء';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'نوع الصفقة',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'شراء', child: Text('شراء')),
                      DropdownMenuItem(value: 'بيع', child: Text('بيع')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'المبلغ (USDT)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text);
                if (amount != null && amount > 0) {
                  final provider = context.read<TradingProvider>();
                  provider.executeManualTrade(
                    provider.currentPair,
                    _selectedType,
                    amount,
                    0, // السعر سيتم تحديده تلقائياً
                  );
                }
              },
              child: Text(_selectedType),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
