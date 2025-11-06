import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      // Used for large amounts in amount step
      displayLarge: base.displayLarge?.copyWith(
        fontFamily: 'Inter',
        fontSize: 48,
        height: 1.1,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontFamily: 'Inter',
        fontSize: 40,
        height: 1.2,
        fontWeight: FontWeight.w600,
      ),
      // Used for the total amount in expense summary
      headlineMedium: base.headlineMedium?.copyWith(
        fontFamily: 'Inter',
        fontSize: 32,
        height: 1.2,
        fontWeight: FontWeight.w600,
      ),
      // Used for dialog titles and main headings
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: 'Inter',
        fontSize: 22,
        height: 1.2,
        fontWeight: FontWeight.w600,
      ),
      // Used for section titles and expense amounts
      titleMedium: base.titleMedium?.copyWith(
        fontFamily: 'Inter',
        fontSize: 20,
        height: 1.4,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontFamily: 'Inter',
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w500,
      ),
      // Used for expense titles and primary labels
      bodyLarge: base.bodyLarge?.copyWith(
        fontFamily: 'Inter',
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w400,
      ),
      // Used for dates, account names, and secondary text
      bodySmall: base.bodySmall?.copyWith(
        fontFamily: 'Inter',
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontFamily: 'Inter',
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontFamily: 'Inter',
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontFamily: 'Inter',
        fontSize: 12,
        height: 1.4,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static final textTheme = _buildTextTheme(
    ThemeData.light().textTheme,
  );

  static final darkTextTheme = _buildTextTheme(
    ThemeData.dark().textTheme,
  );

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    // Main brand color, used for FAB, buttons, and accents
    primary: Color(0xFF7FA41C),
    onPrimary: Color(0xFFFFFFFF),
    // Used for secondary text and icons
    secondary: Color(0xFF49454F),
    onSecondary: Color(0xFFFFFFFF),
    // Error states and delete actions
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    // Main screen background
    surface: Color(0xFFFFFBFE),
    onSurface: Color(0xFF1C1B1F),
    onSurfaceVariant: Color(0xFF49454F),
    // Used for the bottom sheet, nav bar, and subtle backgrounds
    surfaceContainer: Color(0xFFF3F3F3),
    surfaceContainerHighest: Color(0xFFF3F3F3),
    surfaceContainerLow: Color(0xFFF3F3F3),
    surfaceContainerLowest: Color(0xFFF3F3F3),
    // Used for borders and dividers
    outline: Color(0xFFE3E3E3),
    outlineVariant: Color(0xFFE3E3E3),
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    // Main brand color, used for FAB, buttons, and accents
    primary: Color(0xFFA2C458),
    onPrimary: Color(0xFF13151D),
    // Used for secondary text and icons
    secondary: Color(0xFFCAC4D0),
    onSecondary: Color(0xFF13151D),
    // Error states and delete actions
    error: Color(0xFFC93838),
    onError: Color(0xFF601410),
    // Main screen background
    surface: Color(0xFF0C0E13),
    onSurface: Color(0xFFDCDCE8),
    onSurfaceVariant: Color(0xFFA3ABBF),
    surfaceDim: Color(0xFF07090C),
    // Used for the bottom sheet, nav bar, and subtle backgrounds
    surfaceContainer: Color(0xFF13151D),
    surfaceContainerHighest: Color(0xFF13151D),
    surfaceContainerLow: Color(0xFF1F2127),
    surfaceContainerLowest: Color(0xFF262933),
    // Used for borders and dividers
    outline: Color(0xFF13151D),
    outlineVariant: Color(0xFF343741),
  );

  // Expense type colors
  static const Color subscriptionColor = Color(0xFF2196F3); // Blue
  static const Color fixedExpenseColor = Color(0xFFCF5825); // Orange
  static const Color variableExpenseColor = Color(0xFF8056E4); // Purple
  static const Color upcomingExpenseColor = Color(0xFF4CAF50); // Green

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      textTheme: textTheme,
      cardTheme: const CardThemeData(
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
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
      cardTheme: const CardThemeData(
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
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

// Extension to add expense type colors to ColorScheme
extension ExpenseTypeColors on ColorScheme {
  Color get subscriptionColor => AppTheme.subscriptionColor;
  Color get fixedExpenseColor => AppTheme.fixedExpenseColor;
  Color get variableExpenseColor => AppTheme.variableExpenseColor;
  Color get upcomingExpenseColor => AppTheme.upcomingExpenseColor;

  // Utility function to get color for expense type
  Color getExpenseTypeColor(String expenseType) {
    switch (expenseType.toLowerCase()) {
      case 'subscription':
        return subscriptionColor;
      case 'fixed':
        return fixedExpenseColor;
      case 'variable':
        return variableExpenseColor;
      case 'upcoming':
        return upcomingExpenseColor;
      default:
        return primary;
    }
  }
}
