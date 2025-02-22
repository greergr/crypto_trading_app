import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'caption': 'Crypto Trading Bot',
      'validateApiKeys': 'Validate API Keys',
      'addBot': 'Add Bot',
      'botName': 'Bot Name',
      'tradingPair': 'Trading Pair',
      'minimumConfidence': 'Minimum Confidence',
      'interval': 'Interval',
      'save': 'Save',
      'cancel': 'Cancel',
      'settings': 'Settings',
      'apiKey': 'API Key',
      'secretKey': 'Secret Key',
      'testnet': 'Testnet Mode',
      'language': 'Language',
      'theme': 'Theme',
      'light': 'Light',
      'dark': 'Dark',
      'system': 'System',
    },
    'ar': {
      'caption': 'روبوت تداول العملات الرقمية',
      'validateApiKeys': 'التحقق من مفاتيح API',
      'addBot': 'إضافة روبوت',
      'botName': 'اسم الروبوت',
      'tradingPair': 'زوج التداول',
      'minimumConfidence': 'الحد الأدنى للثقة',
      'interval': 'الفاصل الزمني',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'settings': 'الإعدادات',
      'apiKey': 'مفتاح API',
      'secretKey': 'المفتاح السري',
      'testnet': 'وضع الاختبار',
      'language': 'اللغة',
      'theme': 'المظهر',
      'light': 'فاتح',
      'dark': 'داكن',
      'system': 'النظام',
    },
  };

  String get caption => _localizedValues[locale.languageCode]!['caption']!;
  String get validateApiKeys => _localizedValues[locale.languageCode]!['validateApiKeys']!;
  String get addBot => _localizedValues[locale.languageCode]!['addBot']!;
  String get botName => _localizedValues[locale.languageCode]!['botName']!;
  String get tradingPair => _localizedValues[locale.languageCode]!['tradingPair']!;
  String get minimumConfidence => _localizedValues[locale.languageCode]!['minimumConfidence']!;
  String get interval => _localizedValues[locale.languageCode]!['interval']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get apiKey => _localizedValues[locale.languageCode]!['apiKey']!;
  String get secretKey => _localizedValues[locale.languageCode]!['secretKey']!;
  String get testnet => _localizedValues[locale.languageCode]!['testnet']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get theme => _localizedValues[locale.languageCode]!['theme']!;
  String get light => _localizedValues[locale.languageCode]!['light']!;
  String get dark => _localizedValues[locale.languageCode]!['dark']!;
  String get system => _localizedValues[locale.languageCode]!['system']!;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
