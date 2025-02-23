import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bot_manager.dart';
import '../services/api_key_service.dart';
import '../models/bot_settings.dart';
import '../l10n/app_localizations.dart';
import '../services/theme_provider.dart'; // Add this line
import '../dialogs/language_selection_dialog.dart'; // Add this line

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final botManager = context.watch<BotManager>();
    final apiKeyService = context.watch<APIKeyService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.caption),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              icon: Icon(
                Provider.of<ThemeProvider>(context).isDarkMode 
                  ? Icons.light_mode 
                  : Icons.dark_mode,
                color: Colors.white,
              ),
              tooltip: Provider.of<ThemeProvider>(context).isDarkMode 
                ? l10n.lightMode 
                : l10n.darkMode,
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.language, color: Colors.white),
              tooltip: l10n.changeLanguage,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const LanguageSelectionDialog(),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings screen
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildApiKeyStatus(context, apiKeyService),
          const Divider(),
          _buildBotList(context, botManager),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBotDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildApiKeyStatus(BuildContext context, APIKeyService apiKeyService) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                apiKeyService.isTestnet ? Icons.warning : Icons.check_circle,
                color: apiKeyService.isTestnet ? Colors.orange : Colors.green,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  apiKeyService.isTestnet
                      ? 'Running in Testnet Mode'
                      : 'Connected to Binance',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to API key settings
                },
                child: Text(AppLocalizations.of(context)!.validateApiKeys),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotList(BuildContext context, BotManager botManager) {
    // TODO: Implement bot list
    return const Center(
      child: Text('No bots configured'),
    );
  }

  Future<void> _showAddBotDialog(BuildContext context) async {
    final botManager = context.read<BotManager>();
    final controller = TextEditingController();

    final result = await showDialog<BotSettings>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Bot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Bot Name',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Trading Pair',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'BTCUSDT',
                  child: Text('BTC/USDT'),
                ),
                DropdownMenuItem(
                  value: 'ETHUSDT',
                  child: Text('ETH/USDT'),
                ),
                DropdownMenuItem(
                  value: 'BNBUSDT',
                  child: Text('BNB/USDT'),
                ),
              ],
              onChanged: (value) {
                // TODO: Handle trading pair selection
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Create and start new bot
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null) {
      await botManager.startBot(
        result.id,
        result.symbol,
        minimumConfidence: result.minimumConfidence,
        interval: result.interval,
      );
    }
  }
}
