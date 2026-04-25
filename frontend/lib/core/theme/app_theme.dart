import 'package:flutter/material.dart';

class AppTheme {
  // --- New Color Palette ---
  static const Color background = Color(0xFF0D0D0F);
  static const Color onBackground = Color(0xFFD1D2D5);

  static const Color surface = Color(0xFF0D0D0F);
  static const Color surfaceDim = Color(0xFF0D0D0F);
  static const Color surfaceBright = Color(0xFF2C2D2F);
  static const Color surfaceContainerLowest = Color(0xFF080809);
  static const Color surfaceContainerLow = Color(0xFF141516);
  static const Color surfaceContainer = Color(0xFF181A1B);
  static const Color surfaceContainerHigh = Color(0xFF222324);
  static const Color surfaceContainerHighest = Color(0xFF2C2D2F);
  static const Color onSurface = Color(0xFFD1D2D5);
  static const Color onSurfaceVariant = Color(0xFFA9ABB3);
  static const Color surfaceVariant = Color(0xFF2C2D2F);
  static const Color inverseSurface = Color(0xFFD1D2D5);
  static const Color inverseOnSurface = Color(0xFF1A1B1D);

  static const Color outline = Color(0xFF6B6E75);
  static const Color outlineVariant = Color(0xFF363940);
  static const Color surfaceTint = Color(0xFF7A9BC5);

  static const Color primary = Color(0xFF7A9BC5);
  static const Color onPrimary = Color(0xFF0C1F2F);
  static const Color primaryContainer = Color(0xFF5A7A99);
  static const Color onPrimaryContainer = Color(0xFF042232);
  static const Color inversePrimary = Color(0xFF35586D);

  static const Color secondary = Color(0xFF7A9BC5);
  static const Color onSecondary = Color(0xFF0C1F2E);
  static const Color secondaryContainer = Color(0xFF223A4D);
  static const Color onSecondaryContainer = Color(0xFF7AA3BC);

  static const Color tertiary = Color(0xFFC49A5B);
  static const Color onTertiary = Color(0xFF301C00);
  static const Color tertiaryContainer = Color(0xFF8C6A3D);
  static const Color onTertiaryContainer = Color(0xFF271900);

  static const Color error = Color(0xFFFF9593);
  static const Color onError = Color(0xFF370000);
  static const Color errorContainer = Color(0xFF780004);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // Legacy aliases kept temporarily for widgets/screens that still reference
  // the previous token names.
  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color divider = outlineVariant;
  // static const Color orangePrimary = primary;
  // static const Color orangeAccent = secondary;
  // static const Color redPrimary = primaryContainer;
  // static const Color redGlow = secondaryContainer;

  // Note: Fixed/Fixed-Dim colors are usually handled via custom extensions in Flutter,
  // but they are stored here if you need to reference them directly in your UI.
  static const Color primaryFixed = Color(0xFFCDE5FF);
  static const Color primaryFixedDim = Color(0xFFAACAEA);
  static const Color onPrimaryFixed = Color(0xFF001D32);
  static const Color onPrimaryFixedVariant = Color(0xFF2A4965);
  static const Color secondaryFixed = Color(0xFFCCE5FF);
  static const Color secondaryFixedDim = Color(0xFFAACAE8);
  static const Color onSecondaryFixed = Color(0xFF001E31);
  static const Color onSecondaryFixedVariant = Color(0xFF2A4A63);
  static const Color tertiaryFixed = Color(0xFFFFDDB5);
  static const Color tertiaryFixedDim = Color(0xFFEBBF87);
  static const Color onTertiaryFixed = Color(0xFF2A1800);
  static const Color onTertiaryFixedVariant = Color(0xFF5F4115);

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

    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(color: onSurface, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: onSurface),
      bodyMedium: TextStyle(color: onSurfaceVariant),
    ),

    dividerColor: outlineVariant,

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceContainer,
      selectedItemColor: primary,
      unselectedItemColor: onSurfaceVariant,
      selectedIconTheme: IconThemeData(size: 24),
      unselectedIconTheme: IconThemeData(size: 24),
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    ),

    listTileTheme: const ListTileThemeData(
      iconColor: primary,
      textColor: onSurface,
      tileColor: Colors.transparent,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      hintStyle: const TextStyle(color: onSurfaceVariant, fontSize: 14),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: primary, width: 1.2),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: tertiary, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    dialogTheme: const DialogThemeData(
      backgroundColor:
          surfaceContainerHigh, // Dialogs usually sit higher up in elevation
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      titleTextStyle: TextStyle(
        color: onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: TextStyle(color: onSurfaceVariant, fontSize: 14),
    ),

    cardColor: surfaceContainer,
    cardTheme: const CardThemeData(
      color: surfaceContainer,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
  );
}
