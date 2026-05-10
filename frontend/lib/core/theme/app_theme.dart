import 'package:flutter/material.dart';

class AppTheme {
  // --- Dark Theme with Poppins Green Palette ---

  // Base surfaces—dark with green tinted depth
  static const Color background = Color(0xFF04040A);
  static const Color onBackground = Color(0xFFF5F5FA);

  static const Color surface = Color(0xFF04040A);
  static const Color surfaceDim = Color(0xFF04040A);
  static const Color surfaceBright = Color(0xFF3A3A42);
  static const Color surfaceContainerLowest = Color(0xFF000000);
  static const Color surfaceContainerLow = Color(0xFF0E0E14);
  static const Color surfaceContainer = Color(0xFF1A1A21);
  static const Color surfaceContainerHigh = Color(0xFF24242D);
  static const Color surfaceContainerHighest = Color(0xFF2E2E38);
  static const Color onSurface = Color(0xFFF5F5FA);
  static const Color onSurfaceVariant = Color(0xFFB0B1B8);
  static const Color surfaceVariant = Color(0xFF2E2E38);
  static const Color inverseSurface = Color(0xFFF5F5FA);
  static const Color inverseOnSurface = Color(0xFF050509);

  static const Color outline = Color(0xFF6D6E76);
  static const Color outlineVariant = Color(0xFF3A3A42);
  static const Color surfaceTint = Color(0xFF4CA771);

  // Primary: Soft green (from Poppins palette)
  static const Color primary = Color(0xFF4CA771);
  static const Color onPrimary = Color(0xFF000000);
  static const Color primaryContainer = Color(0xFF356B49);
  static const Color onPrimaryContainer = Color(0xFFC0E6BA);
  static const Color inversePrimary = Color(0xFF9EDBB9);

  // Secondary: Mint green
  static const Color secondary = Color(0xFF6DB596);
  static const Color onSecondary = Color(0xFF000000);
  static const Color secondaryContainer = Color(0xFF2D6A56);
  static const Color onSecondaryContainer = Color(0xFFC0DFD6);

  // Tertiary: Sage blue
  static const Color tertiary = Color(0xFF4A9FA8);
  static const Color onTertiary = Color(0xFF000000);
  static const Color tertiaryContainer = Color(0xFF00596B);
  static const Color onTertiaryContainer = Color(0xFFB9E1EB);

  // Semantic colors for dark theme
  static const Color error = Color(0xFFFF6B63);
  static const Color onError = Color(0xFF000000);
  static const Color errorContainer = Color(0xFFB82828);
  static const Color onErrorContainer = Color(0xFFFFDDD9);

  // Success: Soft green (wins, positive)
  static const Color success = Color(0xFF66BB6A);
  static const Color onSuccess = Color(0xFF000000);
  static const Color successContainer = Color(0xFF1F9D4A);
  static const Color onSuccessContainer = Color(0xFFD4F5C8);

  // Warning: Soft amber (cautions)
  static const Color warning = Color(0xFFFFB84D);
  static const Color onWarning = Color(0xFF000000);
  static const Color warningContainer = Color(0xFF8B5900);
  static const Color onWarningContainer = Color(0xFFFFE4B5);

  // Info: Soft blue (informational)
  static const Color info = Color(0xFF64B5F6);
  static const Color onInfo = Color(0xFF000000);
  static const Color infoContainer = Color(0xFF0D47A1);
  static const Color onInfoContainer = Color(0xFFBBDEFB);

  // Fixed colors for persistent UI
  static const Color primaryFixed = Color(0xFFDFF5E8);
  static const Color primaryFixedDim = Color(0xFFC0E6BA);
  static const Color onPrimaryFixed = Color(0xFF0F3C1F);
  static const Color onPrimaryFixedVariant = Color(0xFF356B49);
  static const Color secondaryFixed = Color(0xFFDFF5E8);
  static const Color secondaryFixedDim = Color(0xFFC0DFD6);
  static const Color onSecondaryFixed = Color(0xFF0F3C25);
  static const Color onSecondaryFixedVariant = Color(0xFF2D6A56);
  static const Color tertiaryFixed = Color(0xFFD5F3F9);
  static const Color tertiaryFixedDim = Color(0xFFB9E1EB);
  static const Color onTertiaryFixed = Color(0xFF002F37);
  static const Color onTertiaryFixedVariant = Color(0xFF00596B);

  // Poppins green accent colors
  static const Color accentGreenLight = Color(0xFFC0E6BA);
  static const Color accentGreenDark = Color(0xFF013237);
  static const Color accentMintSoft = Color(0xFF6DB596);
  static const Color accentSageBlue = Color(0xFF4A9FA8);

  // Legacy aliases
  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color divider = outlineVariant;

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Satoshi',
    scaffoldBackgroundColor: background,

    colorScheme: const ColorScheme.dark(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceContainer: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
      surfaceTint: surfaceTint,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        color: onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(color: primary, size: 24),
      actionsIconTheme: const IconThemeData(color: primary, size: 24),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: onSurface,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        color: onSurface,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        color: onSurface,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineSmall: TextStyle(
        color: onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleLarge: TextStyle(
        color: onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      titleMedium: TextStyle(
        color: onSurface,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      titleSmall: TextStyle(
        color: onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      bodyLarge: TextStyle(
        color: onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        color: onSurfaceVariant,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        color: onSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        color: onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.7,
      ),
      labelMedium: TextStyle(
        color: onSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        color: onSurfaceVariant,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),

    dividerColor: outlineVariant,
    dividerTheme: const DividerThemeData(
      color: outlineVariant,
      thickness: 0.5,
      space: 16,
    ),

    // Primary button: Soft green with intensity
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        disabledBackgroundColor: surfaceContainer,
        disabledForegroundColor: onSurfaceVariant,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 12,
        shadowColor: primary.withAlpha(180),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Secondary action button (mint accent)
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: secondary,
        foregroundColor: onSecondary,
        disabledBackgroundColor: surfaceContainer,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 8,
        shadowColor: secondary.withAlpha(150),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Outline button: secondary action
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        disabledForegroundColor: onSurfaceVariant,
        side: const BorderSide(color: primary, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Text button: tertiary action
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        disabledForegroundColor: onSurfaceVariant,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Bottom nav: Primary navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceContainerHighest,
      selectedItemColor: primary,
      unselectedItemColor: onSurfaceVariant,
      selectedIconTheme: const IconThemeData(size: 26),
      unselectedIconTheme: const IconThemeData(size: 24),
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        letterSpacing: 0.3,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 11,
      ),
      elevation: 20,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      mouseCursor: WidgetStateMouseCursor.clickable,
    ),

    // List tiles
    listTileTheme: ListTileThemeData(
      iconColor: primary,
      textColor: onSurface,
      subtitleTextStyle: const TextStyle(
        color: onSurfaceVariant,
        fontSize: 13,
        height: 1.4,
      ),
      tileColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      minTileHeight: 56,
    ),

    // Input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceContainer,
      hintStyle: const TextStyle(
        color: onSurfaceVariant,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: const TextStyle(
        color: onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: outline, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primary, width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: error, width: 2.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIconColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) return primary;
        return onSurfaceVariant;
      }),
      suffixIconColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) return primary;
        return onSurfaceVariant;
      }),
      errorStyle: const TextStyle(color: error, fontSize: 12),
      helperStyle: const TextStyle(color: onSurfaceVariant, fontSize: 12),
    ),

    // Dialogs
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceContainerHighest,
      elevation: 28,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: const TextStyle(
        color: onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      contentTextStyle: const TextStyle(
        color: onSurfaceVariant,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
    ),

    // Cards
    cardTheme: CardThemeData(
      color: surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(0),
      clipBehavior: Clip.antiAlias,
    ),

    // Chips
    chipTheme: ChipThemeData(
      backgroundColor: surfaceContainer,
      disabledColor: surfaceContainerLow,
      selectedColor: primaryContainer,
      secondarySelectedColor: secondaryContainer,
      labelPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: outline, width: 1.5),
      ),
      labelStyle: const TextStyle(
        color: onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      secondaryLabelStyle: const TextStyle(
        color: onPrimaryContainer,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      brightness: Brightness.dark,
      showCheckmark: true,
      checkmarkColor: primary,
    ),

    // Progress
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: surfaceContainer,
      linearMinHeight: 6,
      circularTrackColor: surfaceContainer,
      refreshBackgroundColor: surfaceContainerHigh,
    ),

    // Snackbars
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceContainerHighest,
      contentTextStyle: const TextStyle(
        color: onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
      actionTextColor: primary,
      actionOverflowThreshold: 0.8,
      insetPadding: const EdgeInsets.all(12),
    ),

    // Switches
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStatePropertyAll<Color>(primary),
      trackColor: WidgetStatePropertyAll<Color>(outline),
      trackOutlineColor: WidgetStatePropertyAll<Color>(outlineVariant),
    ),

    // Sliders
    sliderTheme: SliderThemeData(
      activeTrackColor: primary,
      inactiveTrackColor: surfaceContainer,
      disabledActiveTrackColor: onSurfaceVariant,
      disabledInactiveTrackColor: surfaceContainerLow,
      activeTickMarkColor: primary.withAlpha(100),
      inactiveTickMarkColor: outline.withAlpha(100),
      thumbColor: primary,
      disabledThumbColor: onSurfaceVariant,
      overlayColor: primary.withAlpha(80),
      valueIndicatorColor: primaryContainer,
      valueIndicatorTextStyle: const TextStyle(
        color: onPrimaryContainer,
        fontWeight: FontWeight.w700,
      ),
    ),

    // Icons
    iconTheme: const IconThemeData(color: primary, size: 24),
  );

  // Utility method: Get gradient for cards
  static LinearGradient getPrimaryGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primary, primaryContainer],
    );
  }

  // Utility method: Get gradient for achievement/stats
  static LinearGradient getSuccessGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [success, successContainer],
    );
  }

  // Utility method: Get gradient for warnings
  static LinearGradient getWarningGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [warning, warningContainer],
    );
  }

  // Utility method: Get gradient for secondary action
  static LinearGradient getSecondaryGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [secondary, secondaryContainer],
    );
  }

  // Border radius constants
  static const BorderRadius radiusSmall = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusMedium = BorderRadius.all(
    Radius.circular(10),
  );
  static const BorderRadius radiusLarge = BorderRadius.all(Radius.circular(14));
  static const BorderRadius radiusXLarge = BorderRadius.all(
    Radius.circular(16),
  );
  static const BorderRadius radiusPill = BorderRadius.all(Radius.circular(20));

  // Elevation values
  static const double elevationSmall = 4;
  static const double elevationMedium = 8;
  static const double elevationLarge = 12;
  static const double elevationXLarge = 20;
}
