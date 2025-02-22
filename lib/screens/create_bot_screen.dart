import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bot_settings.dart';
import '../services/bot_manager.dart';

class CreateBotScreen extends StatefulWidget {
  const CreateBotScreen({super.key});

  @override
  State<CreateBotScreen> createState() => _CreateBotScreenState();
}

class _CreateBotScreenState extends State<CreateBotScreen> {
  final _formKey = GlobalKey<FormState>();
  String _botName = '';
  BotType _botType = BotType.thousandPoint;
  String _tradingPair = 'BTC/USDT';
  AccountType _accountType = AccountType.demo;
  double _initialCapital = 1000.0;

  final List<String> _tradingPairs = [
    'BTC/USDT',
    'ETH/USDT',
    'BNB/USDT',
    'SOL/USDT',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Bot'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bot Configuration',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Bot Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name for your bot';
                        }
                        return null;
                      },
                      onSaved: (value) => _botName = value!,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<BotType>(
                      decoration: const InputDecoration(
                        labelText: 'Bot Type',
                        border: OutlineInputBorder(),
                      ),
                      value: _botType,
                      items: BotType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type == BotType.thousandPoint
                                ? 'Thousand Point Bot'
                                : 'Ten Eye Bot',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _botType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Trading Pair',
                        border: OutlineInputBorder(),
                      ),
                      value: _tradingPair,
                      items: _tradingPairs.map((pair) {
                        return DropdownMenuItem(
                          value: pair,
                          child: Text(pair),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _tradingPair = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Settings',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<AccountType>(
                      decoration: const InputDecoration(
                        labelText: 'Account Type',
                        border: OutlineInputBorder(),
                      ),
                      value: _accountType,
                      items: AccountType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type == AccountType.demo ? 'Demo Account' : 'Live Account',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _accountType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Initial Capital (USDT)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _initialCapital.toString(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter initial capital';
                        }
                        final capital = double.tryParse(value);
                        if (capital == null || capital <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                      onSaved: (value) => _initialCapital = double.parse(value!),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bot Parameters',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildBotParametersInfo(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _createBot,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Create Bot'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotParametersInfo() {
    final parameters = _botType == BotType.thousandPoint
        ? {
            'Daily Trades': '1000',
            'Entry Percentage': '5.88%',
            'Take Profit': '0.18%',
            'Stop Loss': '0.09%',
            'Max Loss Multiplier': '2x (up to 5 times)',
            'Max Weekly Loss': '20%',
          }
        : {
            'Daily Trades': '10',
            'Entry Percentage': '5%',
            'Take Profit': '9%',
            'Stop Loss': '4.5%',
            'Max Loss Multiplier': '2x (up to 4 times)',
            'Max Weekly Loss': '20%',
          };

    return Column(
      children: parameters.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(entry.value),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _createBot() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final botSettings = BotSettings(
        name: _botName,
        botType: _botType,
        tradingPair: _tradingPair,
        accountType: _accountType,
        initialCapital: _initialCapital,
      );

      final botManager = context.read<BotManager>();
      botManager.createBot(botSettings);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bot created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }
}
