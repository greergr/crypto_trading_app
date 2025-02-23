import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelectionDialog extends StatelessWidget {
  const LanguageSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text(l10n.selectLanguage),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('English'),
            onTap: () {
              Locale newLocale = const Locale('en');
              // Update the app's locale
              Navigator.of(context).pop(newLocale);
            },
          ),
          ListTile(
            title: const Text('العربية'),
            onTap: () {
              Locale newLocale = const Locale('ar');
              // Update the app's locale
              Navigator.of(context).pop(newLocale);
            },
          ),
        ],
      ),
    );
  }
}
