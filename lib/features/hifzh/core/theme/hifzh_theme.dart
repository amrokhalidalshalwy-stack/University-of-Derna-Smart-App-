/// Application color palette and theme tokens for HifdhTracker.
///
/// Do NOT use raw [Color] values in widgets — always reference this class.
library;

import 'package:flutter/material.dart';

/// All application color constants.
///
/// Inspired by classic Islamic manuscript illumination:
/// deep navy, emerald teal, and accent gold.
abstract final class AppColors {
  // ── Primary Brand ─────────────────────────────────────────────────────
  /// Deep navy — AppBars, primary buttons, key accents.
  static const Color primary = Color(0xFF1A3A5C);

  /// Lighter teal variant for interactive states.
  static const Color primaryLight = Color(0xFF2E5F8A);

  /// Dark navy for pressed/active states.
  static const Color primaryDark = Color(0xFF0D1F33);

  // ── Secondary ─────────────────────────────────────────────────────────
  /// Emerald teal — progress rings, streaks, CTAs.
  static const Color secondary = Color(0xFF00A896);

  /// Light teal for chip backgrounds.
  static const Color secondaryLight = Color(0xFFE0F5F3);

  // ── Accent ────────────────────────────────────────────────────────────
  /// Islamic gold — achievements, Surah numbers, star ratings.
  static const Color accentGold = Color(0xFFC9A84C);

  /// Light gold for badge backgrounds.
  static const Color accentGoldLight = Color(0xFFF9F0DC);

  // ── Background & Surface ──────────────────────────────────────────────
  /// App scaffold background.
  static const Color background = Color(0xFFF7F8FA);

  /// Card and dialog surfaces.
  static const Color surface = Color(0xFFFFFFFF);

  /// Elevated surface (slightly off-white).
  static const Color surfaceVariant = Color(0xFFF2F4F7);

  // ── Text ──────────────────────────────────────────────────────────────
  /// Primary body text (on light backgrounds).
  static const Color onSurface = Color(0xFF1C1C1E);

  /// Secondary / muted text.
  static const Color textSecondary = Color(0xFF6B7280);

  /// Hint text.
  static const Color textHint = Color(0xFFADB5BD);

  /// Text on primary-colored backgrounds.
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ── State / Status ─────────────────────────────────────────────────────
  /// Error / validation failure.
  static const Color error = Color(0xFFD62828);

  /// Success / correct.
  static const Color success = Color(0xFF2E7D32);

  /// Warning / in-progress.
  static const Color warning = Color(0xFFF59E0B);

  // ── Gradients ─────────────────────────────────────────────────────────
  /// Hero card gradient (navy to teal).
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF1D6A8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gold shimmer gradient for achievements.
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFC9A84C), Color(0xFFE8C97A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Memorization Status Colors ─────────────────────────────────────────
  /// Color for "not started" status.
  static const Color statusNotStarted = Color(0xFFE5E7EB);

  /// Color for "in progress" status.
  static const Color statusInProgress = Color(0xFFFBBF24);

  /// Color for "memorized" status.
  static const Color statusMemorized = Color(0xFF60A5FA);

  /// Color for "mastered" status.
  static const Color statusMastered = Color(0xFF34D399);
}

/// The global [ThemeData] for the HifdhTracker application.
abstract final class AppTheme {
  /// Light theme — the primary theme of the application.
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onPrimary,
        error: AppColors.error,
        onError: AppColors.onPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceVariant,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,

      // ── AppBar ──────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          color: AppColors.onPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.onPrimary),
      ),

      // ── Typography ──────────────────────────────────────────────────
      textTheme: base.textTheme.copyWith(
        displayLarge: const TextStyle(
          fontFamily: 'Amiri',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
        displayMedium: const TextStyle(
          fontFamily: 'Amiri',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
        headlineLarge: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
        headlineMedium: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
        titleLarge: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        titleMedium: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        bodyLarge: const TextStyle(fontFamily: 'Cairo', fontSize: 16, color: AppColors.onSurface),
        bodyMedium: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.onSurface),
        bodySmall: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
        labelLarge: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.onPrimary,
        ),
      ),

      // ── Cards ────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.06)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ── Buttons ──────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(color: AppColors.primary),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary,
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Input Fields ─────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
        hintStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.textHint),
        errorStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.error, fontSize: 12),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),

      // ── Bottom Navigation Bar ─────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.textHint,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ── Chip ─────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.secondaryLight,
        labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),

      // ── Divider ──────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E7EB),
        thickness: 1,
        space: 1,
      ),

      // ── Progress Indicator ────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.secondary,
        linearTrackColor: AppColors.secondaryLight,
      ),

      // ── SnackBar ─────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primaryDark,
        contentTextStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.onPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
