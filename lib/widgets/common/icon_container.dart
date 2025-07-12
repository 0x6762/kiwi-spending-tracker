import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/design_tokens.dart';

/// Standardized icon container component
/// Used throughout the app for consistent icon styling in cards, buttons, etc.
class IconContainer extends StatelessWidget {
  final IconData? icon;
  final String? svgPath;
  final Color? iconColor;
  final Color? backgroundColor;

  const IconContainer({
    super.key,
    this.icon,
    this.svgPath,
    this.iconColor,
    this.backgroundColor,
  }) : assert(icon != null || svgPath != null, 'Either icon or svgPath must be provided');

  /// Create an icon container with an IconData
  const IconContainer.icon({
    super.key,
    required IconData icon,
    this.iconColor,
    this.backgroundColor,
  }) : icon = icon,
       svgPath = null;

  /// Create an icon container with an SVG asset
  const IconContainer.svg({
    super.key,
    required String svgPath,
    this.iconColor,
    this.backgroundColor,
  }) : svgPath = svgPath,
       icon = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Build icon widget
    Widget iconWidget;
    if (icon != null) {
      iconWidget = Icon(
        icon,
        size: DesignTokens.iconSm,
        color: iconColor ?? theme.colorScheme.primary,
      );
    } else {
      iconWidget = SvgPicture.asset(
        svgPath!,
        width: DesignTokens.iconSm,
        height: DesignTokens.iconSm,
        colorFilter: ColorFilter.mode(
          iconColor ?? theme.colorScheme.primary,
          BlendMode.srcIn,
        ),
      );
    }
    
    // Build container with fixed medium size (32px container, 20px icon, 6px padding)
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusIcon),
      ),
      child: iconWidget,
    );
  }
} 