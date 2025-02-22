import 'package:flutter/material.dart';

class ArabicTheme {
  // الألوان الرئيسية
  static const primaryColor = Color(0xFF2E7D32);
  static const secondaryColor = Color(0xFF1565C0);
  static const backgroundColor = Color(0xFFF5F5F5);
  static const surfaceColor = Colors.white;
  
  // ألوان النصوص
  static const textColor = Color(0xFF212121);
  static const secondaryTextColor = Color(0xFF757575);
  
  // ألوان الحالة
  static const successColor = Color(0xFF43A047);
  static const errorColor = Color(0xFFD32F2F);
  static const warningColor = Color(0xFFFFA000);
  static const infoColor = Color(0xFF1976D2);
  
  // أحجام الخطوط
  static const double fontSizeSmall = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeHeading = 24.0;
  
  // المسافات
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  
  // نصف قطر الزوايا
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  
  // الظلال
  static List<BoxShadow> get shadowSmall => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  // نمط النص العربي
  static TextTheme get arabicTextTheme => const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      fontFamily: 'Cairo',
      color: textColor,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      fontFamily: 'Cairo',
      color: textColor,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      fontFamily: 'Cairo',
      color: textColor,
    ),
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      fontFamily: 'Cairo',
      color: textColor,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      fontFamily: 'Cairo',
      color: textColor,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      fontFamily: 'Cairo',
      color: textColor,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      fontFamily: 'Cairo',
      color: textColor,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamily: 'Cairo',
      color: textColor,
    ),
    titleSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      fontFamily: 'Cairo',
      color: textColor,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontFamily: 'Cairo',
      color: textColor,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontFamily: 'Cairo',
      color: textColor,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontFamily: 'Cairo',
      color: secondaryTextColor,
    ),
  );
  
  // نمط الأزرار
  static ButtonStyle get primaryButtonStyle => ButtonStyle(
    backgroundColor: MaterialStateProperty.resolveWith<Color>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return primaryColor.withOpacity(0.5);
        }
        return primaryColor;
      },
    ),
    foregroundColor: MaterialStateProperty.all(Colors.white),
    padding: MaterialStateProperty.all(
      const EdgeInsets.symmetric(
        horizontal: spacingMedium,
        vertical: spacingSmall,
      ),
    ),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
    ),
  );
  
  // نمط البطاقات
  static CardTheme get cardTheme => CardTheme(
    color: surfaceColor,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadiusMedium),
    ),
    margin: const EdgeInsets.all(spacingSmall),
  );
  
  // نمط حقول الإدخال
  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: surfaceColor,
    contentPadding: const EdgeInsets.all(spacingMedium),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadiusMedium),
      borderSide: const BorderSide(color: secondaryTextColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadiusMedium),
      borderSide: const BorderSide(color: secondaryTextColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadiusMedium),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadiusMedium),
      borderSide: const BorderSide(color: errorColor),
    ),
    labelStyle: const TextStyle(
      color: secondaryTextColor,
      fontFamily: 'Cairo',
    ),
    hintStyle: const TextStyle(
      color: secondaryTextColor,
      fontFamily: 'Cairo',
    ),
  );
  
  // النمط الكامل للتطبيق
  static ThemeData get theme => ThemeData(
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    textTheme: arabicTextTheme,
    cardTheme: cardTheme,
    inputDecorationTheme: inputDecorationTheme,
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    fontFamily: 'Cairo',
  );
}
