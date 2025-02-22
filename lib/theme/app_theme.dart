import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // الألوان الرئيسية
  static const primaryColor = Color(0xFF2962FF);
  static const secondaryColor = Color(0xFF3D5AFE);
  static const accentColor = Color(0xFF00B0FF);
  
  // ألوان الحالة
  static const successColor = Color(0xFF00C853);
  static const warningColor = Color(0xFFFFD600);
  static const errorColor = Color(0xFFFF1744);
  static const infoColor = Color(0xFF00B0FF);
  
  // ألوان الخلفية
  static const backgroundColor = Color(0xFFF5F5F5);
  static const surfaceColor = Colors.white;
  static const cardColor = Colors.white;
  
  // ألوان النص
  static const primaryTextColor = Color(0xFF212121);
  static const secondaryTextColor = Color(0xFF757575);
  static const disabledTextColor = Color(0xFFBDBDBD);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      
      // الخط
      textTheme: GoogleFonts.cairoTextTheme(),
      
      // الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: primaryColor,
          onPrimary: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // البطاقات
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      
      // حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorColor),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // شريط التطبيق
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryColor),
        titleTextStyle: GoogleFonts.cairo(
          color: primaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // القوائم
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      // الرموز
      iconTheme: IconThemeData(
        color: primaryColor,
        size: 24,
      ),
      
      // التبويبات
      tabBarTheme: TabBarTheme(
        labelColor: primaryColor,
        unselectedLabelColor: secondaryTextColor,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: primaryColor, width: 2),
          ),
        ),
      ),
      
      // المؤشرات
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        circularTrackColor: primaryColor.withOpacity(0.2),
      ),
      
      // الشرائح
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: primaryColor.withOpacity(0.2),
        thumbColor: primaryColor,
        overlayColor: primaryColor.withOpacity(0.1),
      ),
      
      // التبديل
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return Colors.grey.withOpacity(0.5);
        }),
      ),
      
      // الحوارات
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: GoogleFonts.cairo(
          color: primaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: GoogleFonts.cairo(
          color: secondaryTextColor,
          fontSize: 16,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: primaryColor,
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Color(0xFF121212),
      cardColor: Color(0xFF1E1E1E),
      
      // الخط
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
      
      // الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: primaryColor,
          onPrimary: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // البطاقات
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      
      // حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorColor),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // شريط التطبيق
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryColor),
        titleTextStyle: GoogleFonts.cairo(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // القوائم
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      // الرموز
      iconTheme: IconThemeData(
        color: primaryColor,
        size: 24,
      ),
      
      // التبويبات
      tabBarTheme: TabBarTheme(
        labelColor: primaryColor,
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: primaryColor, width: 2),
          ),
        ),
      ),
      
      // المؤشرات
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        circularTrackColor: primaryColor.withOpacity(0.2),
      ),
      
      // الشرائح
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: primaryColor.withOpacity(0.2),
        thumbColor: primaryColor,
        overlayColor: primaryColor.withOpacity(0.1),
      ),
      
      // التبديل
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return Colors.grey.withOpacity(0.5);
        }),
      ),
      
      // الحوارات
      dialogTheme: DialogTheme(
        backgroundColor: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: GoogleFonts.cairo(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: GoogleFonts.cairo(
          color: Colors.grey,
          fontSize: 16,
        ),
      ),
    );
  }
  
  // أنماط النصوص
  static TextStyle get headlineLarge => GoogleFonts.cairo(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: primaryTextColor,
  );
  
  static TextStyle get headlineMedium => GoogleFonts.cairo(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryTextColor,
  );
  
  static TextStyle get headlineSmall => GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: primaryTextColor,
  );
  
  static TextStyle get bodyLarge => GoogleFonts.cairo(
    fontSize: 16,
    color: primaryTextColor,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.cairo(
    fontSize: 14,
    color: secondaryTextColor,
  );
  
  static TextStyle get bodySmall => GoogleFonts.cairo(
    fontSize: 12,
    color: secondaryTextColor,
  );
  
  // التحريكات
  static Duration get animationDuration => Duration(milliseconds: 300);
  static Curve get animationCurve => Curves.easeInOut;
  
  // الظلال
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];
  
  // الحدود
  static BorderRadius get borderRadius => BorderRadius.circular(12);
  
  // المسافات
  static const double spacing = 8;
  static const double padding = 16;
  static const double margin = 16;
  
  // الأحجام
  static const double iconSize = 24;
  static const double buttonHeight = 48;
  static const double inputHeight = 48;
  
  // ألوان الوضع الليلي
  static Color getDarkSurfaceColor(int elevation) {
    return Color.lerp(
      Color(0xFF121212),
      Colors.white,
      (elevation * 0.05).clamp(0.0, 1.0),
    )!;
  }
}
