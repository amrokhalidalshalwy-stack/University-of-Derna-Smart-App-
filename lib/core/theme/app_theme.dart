import 'package:flutter/material.dart';

class AppTheme {
  // --- Academic Excellence Palette ---
  static const Color primaryColor = Color(0xFF001835); // الكحلي الداكن الرئيسي للجامعة
  static const Color onPrimaryColor = Colors.white;
  static const Color primaryContainer = Color(0xFF0F2D52);
  static const Color onPrimaryContainer = Color(0xFF7B95C0);

  // توحيد الهوية الفخمة للكحلي
  static const Color secondaryColor = Color(0xFF001835);          // كحلي داكن للنصوص والعناوين
  static const Color onSecondaryColor = Colors.white;             // أبيض للنصوص فوق الخلفيات الداكنة
  static const Color secondaryContainer = Color(0xFF0F2D52);      // كحلي متوسط لخلفيات الأيقونات والأزرار
  static const Color tertiaryColor = Color(0xFF00A694);

  static const Color backgroundColor = Color(0xFFF7F9FB);
  static const Color surfaceColor = Color(0xFFF7F9FB);

  // Alias constants for backward compatibility
  static const Color primary = primaryColor;
  static const Color background = backgroundColor;
  static const Color onSurfaceColor = Color(0xFF191C1E);
  
  // لون رمادي داكن صريح لضمان ظهور النصوص الفرعية فوق الكروت البيضاء بالوضع الفاتح
  static const Color onSurfaceVariantColor = Color(0xFF2F3542);

  static const Color outlineColor = Color(0xFF74777F);
  static const Color outlineVariantColor = Color(0xFFC4C6CF);

  static const Color errorColor = Color(0xFFBA1A1A);

  // خط Cairo الموحد
  static const String fontFamily = 'Cairo';

  /// ☀️ ثيم الوضع الفاتح (Light Mode) - لم يتم تعديله بناءً على رغبتك ليبقى مستقراً
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,

      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: onPrimaryColor,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondaryColor,
        onSecondary: onSecondaryColor,
        secondaryContainer: secondaryContainer,
        tertiary: tertiaryColor,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
        onSurfaceVariant: onSurfaceVariantColor,
        outline: outlineColor,
        outlineVariant: outlineVariantColor,
        error: errorColor,
      ),

      scaffoldBackgroundColor: backgroundColor,

      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      textTheme: _textTheme(),
      inputDecorationTheme: _inputTheme(),
      elevatedButtonTheme: _buttonTheme(),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: outlineVariantColor, width: 0.5),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: fontFamily,
            fontSize: selected ? 12 : 11,
fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
      ),
    );
  }

  /// 🌙 ثيم الوضع الداكن المطور الشامل (Dark Mode) - تم تعديله لحل مشاكل التباين في كامل المشروع
  static ThemeData get darkTheme {
    const darkBackground = Color(0xFF0A0E1A);
    const darkSurface = Color(0xFF111827);
    const darkSurfaceVariant = Color(0xFF1F2937);
    const darkCardSurface = Color(0xFF1F2937);
    
    // إدخال لون أزرق سماوي مضيء ومريح للعين لاستخدامه كـ Primary بالوضع الداكن لحل مشكلة اختفاء النصوص والأزرار
    const darkPrimaryAccent = Color(0xFF64B5F6); 

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,

      colorScheme: const ColorScheme.dark(
        // ✅ تم التعديل: استبدال اللون الكحلي الغامق بلون أكเซنت مضيء للأزرار والعناصر المتفاعلة بالوضع الداكن
        primary: darkPrimaryAccent,
        onPrimary: Color(0xFF001835), // نص داكن فوق لون الأكเซنت الفاتح للتباين
        primaryContainer: primaryContainer,
        onPrimaryContainer: Color(0xFFE0E7FF), // تفتيح حاويات النصوص
        secondary: tertiaryColor, // اللون الفيروزي المعتمد
        onSecondary: Colors.white,
        surface: darkSurface,
        onSurface: Color(0xFFE5E7EB), // رمادي فاتح مريح جداً للقراءة وعالي التباين
        
        // ✅ تم الإصلاح: الحفاظ على أبيض ناصع للنصوص الفرعية والـ Icons المدمجة
        onSurfaceVariant: Colors.white,

        outline: Color(0xFF6B7280),
        outlineVariant: Color(0xFF4B5563),
        error: errorColor,
      ),

      scaffoldBackgroundColor: darkBackground,

      // ✅ تم الإصلاح: العناوين والأيقونات في الـ AppBar أصبحت بيضاء بدلاً من الكحلي المخفي
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white, // أبيض ناصع ممتاز ومقروء فوراً
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      textTheme: _textTheme().apply(
        bodyColor: const Color(0xFFE5E7EB),
        displayColor: const Color(0xFFE5E7EB),
      ),

      // ✅ تحسين الحقول النصية لمنع تداخل الظلال بالخلفيات
      inputDecorationTheme: _inputTheme().copyWith(
        fillColor: darkSurfaceVariant,
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          color: Color(0xFFE3E2E6),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: darkPrimaryAccent, width: 1.5),
        ),
      ),

      // ✅ تعديل ثيم الأزرار المرفوعة لتأخذ اللون المضيء الجديد وتظهر بوضوح في شاشات التطبيق
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryAccent,
          foregroundColor: const Color(0xFF001835),
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.4),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: darkCardSurface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFF374151).withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),

      // ✅ تم الإصلاح: العناصر النشطة في الـ Navigation Bar أصبحت مضيئة وواضحة جداً للمستخدم
      navigationBarTheme: NavigationBarThemeData(
        height: 65,
        backgroundColor: darkSurface,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: fontFamily,
            fontSize: selected ? 12 : 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? darkPrimaryAccent : const Color(0xFFE3E2E6),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? darkPrimaryAccent : const Color(0xFFE3E2E6),
          );
        }),
        indicatorColor: darkPrimaryAccent.withValues(alpha: 0.15),
      ),
    );
  }

  static TextTheme _textTheme() => const TextTheme(
    displayLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold),
    headlineLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold, fontSize: 32),
    headlineMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold, fontSize: 24),
    headlineSmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold, fontSize: 20),
    titleLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600, fontSize: 18),
    titleMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500, fontSize: 16),
    bodyLarge: TextStyle(fontFamily: fontFamily, fontSize: 16, height: 1.6),
    bodyMedium: TextStyle(fontFamily: fontFamily, fontSize: 14, height: 1.6),
    bodySmall: TextStyle(fontFamily: fontFamily, fontSize: 12, height: 1.5),
    labelLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500, letterSpacing: 0.02),
  );

  static InputDecorationTheme _inputTheme() => InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: outlineVariantColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: outlineVariantColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryColor, width: 1.5),
    ),
    labelStyle: const TextStyle(
      fontFamily: fontFamily,
      color: onSurfaceVariantColor,
    ),
  );

  static ElevatedButtonThemeData _buttonTheme() => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: onPrimaryColor,
      elevation: 4,
      shadowColor: primaryContainer.withValues(alpha: 0.2),
      minimumSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      textStyle: const TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
  );
}