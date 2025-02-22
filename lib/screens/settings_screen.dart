import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/localization_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/api_key_form.dart';
import '../theme/arabic_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localizationService = context.watch<LocalizationService>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // اللغة والمظهر
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.language,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      // اختيار اللغة
                      DropdownButtonFormField<String>(
                        value: localizationService.currentLocale.languageCode,
                        decoration: InputDecoration(
                          labelText: l10n.language,
                          border: const OutlineInputBorder(),
                        ),
                        items: LocalizationService.supportedLocales
                            .map((locale) => DropdownMenuItem(
                                  value: locale.languageCode,
                                  child: Text(
                                    LocalizationService.languageNames[locale.languageCode]!,
                                  ),
                                ))
                            .toList(),
                        onChanged: (String? languageCode) {
                          if (languageCode != null) {
                            localizationService.setLocale(Locale(languageCode));
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // المظهر
                      Text(
                        l10n.theme,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        title: Text(l10n.darkMode),
                        trailing: Switch(
                          value: Theme.of(context).brightness == Brightness.dark,
                          onChanged: (bool value) {
                            // تحديث المظهر
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // نوع الحساب
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.testnet,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: Text(l10n.testnet),
                        subtitle: Text(
                          'استخدم بيانات السوق الحقيقية مع أموال افتراضية',
                        ),
                        value: auth.isDemo,
                        onChanged: (value) {
                          auth.setDemoMode(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // رأس المال
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'رأس المال',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: auth.balance.toString(),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'المبلغ بالدولار',
                          prefixText: '\$',
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          final amount = double.tryParse(value);
                          if (amount != null) {
                            auth.setBalance(amount);
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'هذا المبلغ سيتم استخدامه لحساب نسب الدخول في الصفقات',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // إعدادات API
              if (!auth.isDemo) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.apiSettings,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        const APIKeyForm(),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // إعدادات الإشعارات
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.notifications,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: Text(l10n.tradeNotifications),
                        subtitle: Text('استلام إشعار عند فتح أو إغلاق أي صفقة'),
                        value: auth.tradeNotifications,
                        onChanged: (value) {
                          auth.setTradeNotifications(value);
                        },
                      ),
                      SwitchListTile(
                        title: Text(l10n.riskAlerts),
                        subtitle: Text('استلام تنبيه عند اقتراب حد الخسارة'),
                        value: auth.riskAlerts,
                        onChanged: (value) {
                          auth.setRiskAlerts(value);
                        },
                      ),
                      SwitchListTile(
                        title: Text(l10n.weeklyReports),
                        subtitle: Text('استلام تقرير أداء أسبوعي'),
                        value: auth.weeklyReports,
                        onChanged: (value) {
                          auth.setWeeklyReports(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
