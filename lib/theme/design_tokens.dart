import 'package:flutter/material.dart';

/// Design tokens for the Kiwi Spending Tracker app
/// This class provides standardized spacing, border radius, and dimension values
/// to ensure consistency across all components.
class DesignTokens {
  DesignTokens._();

  // ==================== SPACING SYSTEM ====================
  /// Base spacing unit (4px) - all other spacing values are multiples of this
  static const double _baseSpacing = 4.0;

  /// Spacing scale based on 4px base unit
  /// Use these values for consistent spacing throughout the app
  static const double spacing0 = 0;
  static const double spacing1 = _baseSpacing * 1; // 4px
  static const double spacing2 = _baseSpacing * 2; // 8px
  static const double spacing3 = _baseSpacing * 3; // 12px
  static const double spacing4 = _baseSpacing * 4; // 16px
  static const double spacing5 = _baseSpacing * 5; // 20px
  static const double spacing6 = _baseSpacing * 6; // 24px
  static const double spacing8 = _baseSpacing * 8; // 32px
  static const double spacing10 = _baseSpacing * 10; // 40px
  static const double spacing12 = _baseSpacing * 12; // 48px
  static const double spacing16 = _baseSpacing * 16; // 64px
  static const double spacing20 = _baseSpacing * 20; // 80px

  // ==================== SEMANTIC SPACING ====================
  /// Semantic spacing values for common use cases
  static const double spacingXs = spacing1; // 4px
  static const double spacingSm = spacing2; // 8px
  static const double spacingMd = spacing4; // 16px
  static const double spacingLg = spacing6; // 24px
  static const double spacingXl = spacing8; // 32px
  static const double spacingXxl = spacing12; // 48px

  // ==================== BORDER RADIUS SYSTEM ====================
  /// Border radius values for different component types
  static const double radiusNone = 0;
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusXxl = 24;
  static const double radiusRounded = 28;

  /// Semantic border radius values
  static const double radiusButton = radiusXl; // 20px
  static const double radiusCard = radiusRounded; // 28px
  static const double radiusInput = radiusXl; // 20px
  static const double radiusSheet = radiusXxl; // 24px
  static const double radiusIcon = radiusMd; // 12px
  static const double radiusChip = radiusXl; // 20px

  // ==================== COMPONENT DIMENSIONS ====================
  /// Standard component heights
  static const double buttonHeight = 48;
  static const double inputHeight = 52;
  static const double appBarHeight = 72;
  static const double chipHeight = 32;
  static const double iconButtonSize = 40;
  static const double iconButtonSizeSm = 32;
  static const double iconButtonSizeLg = 48;

  /// Icon sizes
  static const double iconXs = 16;
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 40;
  static const double iconXxl = 48;

  /// Common icon sizes for specific use cases
  static const double iconButton = iconSm; // 20px
  static const double iconCard = iconSm; // 20px
  static const double iconListItem = iconMd; // 24px
  static const double iconFab = iconLg; // 32px

  // ==================== ELEVATION SYSTEM ====================
  /// Material 3 elevation values
  static const double elevation0 = 0;
  static const double elevation1 = 1;
  static const double elevation2 = 2;
  static const double elevation3 = 3;
  static const double elevation4 = 4;
  static const double elevation5 = 5;

  /// Semantic elevation values
  static const double elevationCard = elevation0; // Flat design
  static const double elevationButton = elevation0; // Flat design
  static const double elevationSheet = elevation0; // Flat design
  static const double elevationDialog = elevation3; // Moderate elevation
  static const double elevationFab = elevation3; // Moderate elevation

  // ==================== ANIMATION DURATIONS ====================
  /// Standard animation durations in milliseconds
  static const int durationFast = 150;
  static const int durationNormal = 300;
  static const int durationSlow = 500;

  /// Animation curves
  static const Curve curveDefault = Curves.easeInOut;
  static const Curve curveEnter = Curves.easeOut;
  static const Curve curveExit = Curves.easeIn;

  // ==================== COMPONENT PADDING ====================
  /// Standard padding configurations for different component types
  static const EdgeInsets paddingButton = EdgeInsets.symmetric(
    horizontal: spacingMd,
    vertical: spacingSm,
  );

  static const EdgeInsets paddingCard = EdgeInsets.all(spacingLg);

  static const EdgeInsets paddingInput = EdgeInsets.symmetric(
    horizontal: spacingMd,
    vertical: spacingLg,
  );

  static const EdgeInsets paddingSheet = EdgeInsets.all(spacingLg);
  static const EdgeInsets paddingDialog = EdgeInsets.all(spacingLg);

  static const EdgeInsets paddingScreen = EdgeInsets.all(spacingMd);
  static const EdgeInsets paddingScreenHorizontal = EdgeInsets.symmetric(
    horizontal: spacingMd,
  );

  // ==================== COMPONENT MARGINS ====================
  /// Standard margin configurations
  static const EdgeInsets marginComponent = EdgeInsets.only(bottom: spacingSm);
  static const EdgeInsets marginSection = EdgeInsets.only(bottom: spacingMd);
  static const EdgeInsets marginCard = EdgeInsets.only(bottom: spacingMd);

  // ==================== BREAKPOINTS ====================
  /// Responsive breakpoints
  static const double breakpointMobile = 480;
  static const double breakpointTablet = 768;
  static const double breakpointDesktop = 1024;

  // ==================== OPACITY VALUES ====================
  /// Standard opacity values for different states
  static const double opacityDisabled = 0.38;
  static const double opacityHover = 0.08;
  static const double opacityFocus = 0.12;
  static const double opacityPressed = 0.16;
  static const double opacitySelected = 0.12;

  // ==================== UTILITY METHODS ====================
  /// Get EdgeInsets for symmetric padding
  static EdgeInsets paddingSymmetric({
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: vertical,
    );
  }

  /// Get EdgeInsets for all-around padding
  static EdgeInsets paddingAll(double value) {
    return EdgeInsets.all(value);
  }

  /// Get EdgeInsets for directional padding
  static EdgeInsets paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }

  /// Get BorderRadius for different corner configurations
  static BorderRadius borderRadius(double value) {
    return BorderRadius.circular(value);
  }

  /// Get BorderRadius for specific corners
  static BorderRadius borderRadiusOnly({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    );
  }

  /// Get BorderRadius for top corners only (useful for bottom sheets)
  static BorderRadius borderRadiusTop(double value) {
    return BorderRadius.vertical(top: Radius.circular(value));
  }

  /// Get BorderRadius for bottom corners only
  static BorderRadius borderRadiusBottom(double value) {
    return BorderRadius.vertical(bottom: Radius.circular(value));
  }
}



/// Utility class for responsive design
class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < DesignTokens.breakpointMobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= DesignTokens.breakpointMobile && 
           width < DesignTokens.breakpointTablet;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= DesignTokens.breakpointDesktop;
  }
} 