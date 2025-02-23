import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelectionDialog extends StatelessWidget {
  const LanguageSelectionDialog({Key? key}) : super(key: key);

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
              // TODO: Implement language change
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('العربية'),
            onTap: () {
              // TODO: Implement language change
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
