import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static const String LANGUAGE_CODE = 'languageCode';
  final SharedPreferences _prefs;
  Locale _currentLocale;

  LocalizationService(this._prefs) {
    String? storedLocale = _prefs.getString(LANGUAGE_CODE);
    _currentLocale = storedLocale != null ? Locale(storedLocale) : const Locale('en');
  }

  Locale get currentLocale => _currentLocale;

  // المتوفرة اللغات
  static List<Locale> get supportedLocales => const [
    Locale('en'), // الإنجليزية
    Locale('ar'), // العربية
  ];
  
  // أسماء اللغات
  static const Map<String, String> languageNames = {
    'ar': 'العربية',
    'en': 'English',
  };
  
  // تغيير اللغة
  Future<void> setLocale(Locale locale) async {
    if (_currentLocale == locale) return;
    
    await _prefs.setString(LANGUAGE_CODE, locale.languageCode);
    _currentLocale = locale;
    notifyListeners();
  }
  
  // الحصول على اسم اللغة الحالية
  String getCurrentLanguageName() {
    return languageNames[_currentLocale.languageCode] ?? 'العربية';
  }
  
  // التحقق من اتجاه النص
  bool get isRTL => _currentLocale.languageCode == 'ar';
  
  // الحصول على اتجاه النص
  TextDirection get textDirection => isRTL ? TextDirection.rtl : TextDirection.ltr;
  
  // تهيئة الخط العربي
  String get fontFamily => isRTL ? 'Cairo' : 'Roboto';
}
