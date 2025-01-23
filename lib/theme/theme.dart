import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static TextTheme _buildTextTheme(
      TextTheme base, Color primaryTextColor, Color secondaryTextColor) {
    return GoogleFonts.interTextTheme(base).copyWith(
      displayLarge: GoogleFonts.inter(
        textStyle: base.displayLarge?.copyWith(color: primaryTextColor),
        fontWeight: FontWeight.w600,
      ),
      displayMedium: GoogleFonts.inter(
        textStyle: base.displayMedium?.copyWith(color: primaryTextColor),
        fontWeight: FontWeight.w600,
      ),
      displaySmall: GoogleFonts.inter(
        textStyle: base.displaySmall?.copyWith(color: primaryTextColor),
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: GoogleFonts.inter(
        textStyle: base.headlineLarge?.copyWith(color: primaryTextColor),
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.inter(
        textStyle: base.headlineMedium?.copyWith(color: primaryTextColor),
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.inter(
        textStyle: base.headlineSmall?.copyWith(color: primaryTextColor),
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.inter(
        textStyle: base.titleLarge?.copyWith(color: primaryTextColor),
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.inter(
        textStyle: base.titleMedium?.copyWith(color: primaryTextColor),
        fontWeight: FontWeight.w500,
      ),
      titleSmall: GoogleFonts.inter(
        textStyle: base.titleSmall?.copyWith(color: primaryTextColor),
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.inter(
        textStyle: base.bodyLarge?.copyWith(color: primaryTextColor),
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: GoogleFonts.inter(
        textStyle: base.bodyMedium?.copyWith(color: primaryTextColor),
        fontWeight: FontWeight.normal,
      ),
      bodySmall: GoogleFonts.inter(
        textStyle: base.bodySmall?.copyWith(color: secondaryTextColor),
        fontWeight: FontWeight.normal,
      ),
      labelLarge: GoogleFonts.inter(
        textStyle: base.labelLarge?.copyWith(color: primaryTextColor),
        fontWeight: FontWeight.w500,
      ),
      labelMedium: GoogleFonts.inter(
        textStyle: base.labelMedium?.copyWith(color: secondaryTextColor),
        fontWeight: FontWeight.w500,
      ),
      labelSmall: GoogleFonts.inter(
        textStyle: base.labelSmall?.copyWith(color: secondaryTextColor),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static final textTheme = _buildTextTheme(
    ThemeData.light().textTheme,
    const Color(0xFF1C1B1F), // Primary text color for light mode
    const Color(0xFF49454F), // Secondary text color for light mode
  );

  static final darkTextTheme = _buildTextTheme(
    ThemeData.dark().textTheme,
    const Color(0xFFE6E1E5), // Primary text color for dark mode
    const Color(0xFFCAC4D0), // Secondary text color for dark mode
  );

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFA2C458),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFEADDFF),
    onPrimaryContainer: Color(0xFF21005E),
    secondary: Color(0xFF625B71),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFE8DEF8),
    onSecondaryContainer: Color(0xFF1E192B),
    tertiary: Color(0xFF7D5260),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFFFD8E4),
    onTertiaryContainer: Color(0xFF31111D),
    error: Color(0xFFB3261E),
    onError: Colors.white,
    errorContainer: Color(0xFFF9DEDC),
    onErrorContainer: Color(0xFF410E0B),
    background: Colors.white,
    onBackground: Color(0xFF1C1B1F),
    surface: Colors.white,
    onSurface: Color(0xFF1C1B1F),
    surfaceVariant: Color(0xFFE7E0EC),
    onSurfaceVariant: Color(0xFF49454F),
    outline: Color(0xFF79747E),
    outlineVariant: Color(0xFFCAC4D0),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFF313033),
    onInverseSurface: Color(0xFFF4EFF4),
    inversePrimary: Color(0xFFD0BCFF),
    surfaceTint: Color(0xFF6750A4),
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFA2C458),
    onPrimary: Color(0xFF13151D),
    primaryContainer: Color(0xFF13151D),
    onPrimaryContainer: Color(0xFFFFFFFF),
    secondary: Color(0xFFCAC4D0),
    onSecondary: Color(0xFF13151D),
    secondaryContainer: Color(0xFF13151D),
    onSecondaryContainer: Color(0xFFCAC4D0),
    tertiary: Color(0xFFEFB8C8),
    onTertiary: Color(0xFF13151D),
    tertiaryContainer: Color(0xFF13151D),
    onTertiaryContainer: Color(0xFFEFB8C8),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    errorContainer: Color(0xFF8C1D18),
    onErrorContainer: Color(0xFFF9DEDC),
    background: Color(0xFF0C0E13),
    onBackground: Color(0xFFE6E1E5),
    surface: Color(0xFF0C0E13),
    onSurface: Color(0xFFE6E1E5),
    surfaceVariant: Color(0xFF13151D),
    onSurfaceVariant: Color(0xFFCAC4D0),
    outline: Color(0xFF938F99),
    outlineVariant: Color(0xFF49454F),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFE6E1E5),
    onInverseSurface: Color(0xFF13151D),
    inversePrimary: Color(0xFF13151D),
    surfaceTint: Color(0xFFFFFFFF),
  );

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      textTheme: textTheme,
      cardTheme: const CardTheme(
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: lightColorScheme.onSurface,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightColorScheme.primary,
        foregroundColor: lightColorScheme.onPrimary,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      textTheme: darkTextTheme,
      cardTheme: const CardTheme(
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: darkTextTheme.titleLarge?.copyWith(
          color: darkColorScheme.onSurface,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkColorScheme.outlineVariant,
        foregroundColor: const Color(0xFFffffff),
      ),
    );
  }
}
