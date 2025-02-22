import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/localization_service.dart';
import '../theme/arabic_theme.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // شعار التطبيق
              Icon(
                Icons.currency_bitcoin,
                size: 80,
                color: ArabicTheme.primaryColor,
              ),
              const SizedBox(height: 32),
              
              // عنوان الترحيب
              const Text(
                'مرحباً بك في روبوت التداول',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // وصف التطبيق
              const Text(
                'قم باختيار لغة التطبيق المفضلة لديك',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // اختيار اللغة
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // زر العربية
                      _LanguageButton(
                        languageCode: 'ar',
                        languageName: 'العربية',
                        flagEmoji: '🇸🇦',
                        onPressed: () => _selectLanguage(context, 'ar'),
                      ),
                      const SizedBox(height: 16),
                      
                      // زر الإنجليزية
                      _LanguageButton(
                        languageCode: 'en',
                        languageName: 'English',
                        flagEmoji: '🇺🇸',
                        onPressed: () => _selectLanguage(context, 'en'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectLanguage(BuildContext context, String languageCode) {
    final localizationService = context.read<LocalizationService>();
    localizationService.setLocale(Locale(languageCode));
    
    // الانتقال إلى الشاشة الرئيسية
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String languageCode;
  final String languageName;
  final String flagEmoji;
  final VoidCallback onPressed;

  const _LanguageButton({
    required this.languageCode,
    required this.languageName,
    required this.flagEmoji,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              flagEmoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Text(
              languageName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
