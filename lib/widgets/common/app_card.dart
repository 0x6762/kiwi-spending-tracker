import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

/// Card variants for different use cases
enum AppCardVariant {
  /// Standard card with surface container background
  standard,
  /// Surface card with surface background
  surface,
}

/// Standardized card component with consistent styling and variants
class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardVariant variant;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final bool isSelected;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.standard,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.isSelected = false,
  });

  /// Standard card constructor
  const AppCard.standard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.isSelected = false,
  }) : variant = AppCardVariant.standard;

  /// Surface card constructor
  const AppCard.surface({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.isSelected = false,
  }) : variant = AppCardVariant.surface;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _getCardConfig(theme);
    
    Widget cardContent = Container(
      padding: padding ?? config.padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? config.backgroundColor,
        borderRadius: borderRadius ?? config.borderRadius,
        border: config.border,
        boxShadow: config.boxShadow,
      ),
      child: child,
    );

    // Add margin if specified
    if (margin != null) {
      cardContent = Container(
        margin: margin,
        child: cardContent,
      );
    }

    // Add tap functionality if needed
    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? config.borderRadius,
        child: cardContent,
      );
    }

    // Add selection styling if needed
    if (isSelected) {
      cardContent = Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? config.borderRadius,
          border: Border.all(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        child: cardContent,
      );
    }

    return cardContent;
  }

  /// Get card configuration based on variant
  _CardConfig _getCardConfig(ThemeData theme) {
    switch (variant) {
      case AppCardVariant.standard:
        return _CardConfig(
          backgroundColor: theme.colorScheme.surfaceContainer,
          borderRadius: DesignTokens.borderRadius(DesignTokens.radiusCard),
          padding: DesignTokens.paddingCard,
          elevation: DesignTokens.elevationCard,
        );
      case AppCardVariant.surface:
        return _CardConfig(
          backgroundColor: theme.colorScheme.surface,
          borderRadius: DesignTokens.borderRadius(DesignTokens.radiusCard),
          padding: DesignTokens.paddingCard,
          elevation: DesignTokens.elevationCard,
        );
    }
  }
}

/// Card configuration for styling
class _CardConfig {
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final double elevation;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  _CardConfig({
    required this.backgroundColor,
    required this.borderRadius,
    required this.padding,
    required this.elevation,
  }) : border = null,
       boxShadow = null;
}