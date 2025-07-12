import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/design_tokens.dart';

/// Size variants for icon containers
enum IconContainerSize {
  /// Small container (24px)
  small,
  /// Medium container (32px) - default
  medium,
  /// Large container (40px)
  large,
  /// Extra large container (48px)
  extraLarge,
}

/// Standardized icon container component
/// Used throughout the app for consistent icon styling in cards, buttons, etc.
class IconContainer extends StatelessWidget {
  final IconData? icon;
  final String? svgPath;
  final Color? iconColor;
  final Color? backgroundColor;
  final IconContainerSize size;
  final double? customSize;
  final double? borderRadius;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const IconContainer({
    super.key,
    this.icon,
    this.svgPath,
    this.iconColor,
    this.backgroundColor,
    this.size = IconContainerSize.medium,
    this.customSize,
    this.borderRadius,
    this.padding,
    this.onTap,
  }) : assert(icon != null || svgPath != null, 'Either icon or svgPath must be provided');

  /// Create an icon container with an IconData
  const IconContainer.icon({
    super.key,
    required IconData icon,
    this.iconColor,
    this.backgroundColor,
    this.size = IconContainerSize.medium,
    this.customSize,
    this.borderRadius,
    this.padding,
    this.onTap,
  }) : icon = icon,
       svgPath = null;

  /// Create an icon container with an SVG asset
  const IconContainer.svg({
    super.key,
    required String svgPath,
    this.iconColor,
    this.backgroundColor,
    this.size = IconContainerSize.medium,
    this.customSize,
    this.borderRadius,
    this.padding,
    this.onTap,
  }) : svgPath = svgPath,
       icon = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _getConfig(theme);
    
    Widget iconWidget;
    
    // Build icon widget
    if (icon != null) {
      iconWidget = Icon(
        icon,
        size: config.iconSize,
        color: iconColor ?? config.defaultIconColor,
      );
    } else {
      iconWidget = SvgPicture.asset(
        svgPath!,
        width: config.iconSize,
        height: config.iconSize,
        colorFilter: ColorFilter.mode(
          iconColor ?? config.defaultIconColor,
          BlendMode.srcIn,
        ),
      );
    }
    
    // Build container
    Widget container = Container(
      padding: padding ?? config.padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? config.defaultBackgroundColor,
        borderRadius: BorderRadius.circular(
          borderRadius ?? config.borderRadius,
        ),
      ),
      child: iconWidget,
    );
    
    // Add tap functionality if needed
    if (onTap != null) {
      container = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          borderRadius ?? config.borderRadius,
        ),
        child: container,
      );
    }
    
    return container;
  }

  /// Get configuration based on size and theme
  _IconContainerConfig _getConfig(ThemeData theme) {
    final double containerSize;
    final double iconSize;
    final EdgeInsets defaultPadding;
    
    if (customSize != null) {
      containerSize = customSize!;
      iconSize = customSize! * 0.6; // Icon is 60% of container size
      defaultPadding = EdgeInsets.all((containerSize - iconSize) / 2);
    } else {
      switch (size) {
        case IconContainerSize.small:
          containerSize = 24;
          iconSize = DesignTokens.iconSm;
          defaultPadding = const EdgeInsets.all(2);
          break;
        case IconContainerSize.medium:
          containerSize = 32;
          iconSize = DesignTokens.iconSm;
          defaultPadding = const EdgeInsets.all(6);
          break;
        case IconContainerSize.large:
          containerSize = 40;
          iconSize = DesignTokens.iconMd;
          defaultPadding = DesignTokens.paddingIcon;
          break;
        case IconContainerSize.extraLarge:
          containerSize = 48;
          iconSize = DesignTokens.iconLg;
          defaultPadding = DesignTokens.paddingIcon;
          break;
      }
    }
    
    return _IconContainerConfig(
      containerSize: containerSize,
      iconSize: iconSize,
      padding: defaultPadding,
      borderRadius: DesignTokens.radiusIcon,
      defaultIconColor: theme.colorScheme.primary,
      defaultBackgroundColor: theme.colorScheme.primary.withOpacity(0.1),
    );
  }
}

/// Configuration for icon container
class _IconContainerConfig {
  final double containerSize;
  final double iconSize;
  final EdgeInsets padding;
  final double borderRadius;
  final Color defaultIconColor;
  final Color defaultBackgroundColor;

  _IconContainerConfig({
    required this.containerSize,
    required this.iconSize,
    required this.padding,
    required this.borderRadius,
    required this.defaultIconColor,
    required this.defaultBackgroundColor,
  });
}

/// Specialized icon containers for common use cases
class ExpenseTypeIconContainer extends StatelessWidget {
  final String expenseType;
  final IconContainerSize size;
  final VoidCallback? onTap;

  const ExpenseTypeIconContainer({
    super.key,
    required this.expenseType,
    this.size = IconContainerSize.medium,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return IconContainer.svg(
      svgPath: _getExpenseTypeIcon(expenseType),
      iconColor: _getExpenseTypeColor(theme, expenseType),
      backgroundColor: _getExpenseTypeColor(theme, expenseType).withOpacity(0.1),
      size: size,
      onTap: onTap,
    );
  }

  String _getExpenseTypeIcon(String expenseType) {
    switch (expenseType.toLowerCase()) {
      case 'subscription':
        return 'assets/icons/subscription.svg';
      case 'fixed':
        return 'assets/icons/fixed_expense.svg';
      case 'variable':
        return 'assets/icons/variable_expense.svg';
      default:
        return 'assets/icons/variable_expense.svg';
    }
  }

  Color _getExpenseTypeColor(ThemeData theme, String expenseType) {
    switch (expenseType.toLowerCase()) {
      case 'subscription':
        return theme.colorScheme.primaryContainer;
      case 'fixed':
        return const Color(0xFFCF5825); // Orange
      case 'variable':
        return const Color(0xFF8056E4); // Purple
      default:
        return theme.colorScheme.primary;
    }
  }
}

/// Category icon container
class CategoryIconContainer extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final IconContainerSize size;
  final VoidCallback? onTap;

  const CategoryIconContainer({
    super.key,
    required this.icon,
    this.color,
    this.size = IconContainerSize.medium,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = color ?? theme.colorScheme.primary;
    
    return IconContainer.icon(
      icon: icon,
      iconColor: iconColor,
      backgroundColor: iconColor.withOpacity(0.1),
      size: size,
      onTap: onTap,
    );
  }
} 