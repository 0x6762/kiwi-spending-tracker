import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

/// Card variants for different use cases
enum AppCardVariant {
  /// Standard card with surface container background
  standard,
  /// Elevated card with shadow
  elevated,
  /// Outlined card with border
  outlined,
  /// Filled card with primary color background
  filled,
  /// Surface card with surface background
  surface,
}

/// Card sizes for different contexts
enum AppCardSize {
  /// Small card with compact padding
  small,
  /// Medium card with standard padding - default
  medium,
  /// Large card with expanded padding
  large,
}

/// Standardized card component with consistent styling and variants
class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardVariant variant;
  final AppCardSize size;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final double? borderWidth;
  final bool isSelected;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.standard,
    this.size = AppCardSize.medium,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.borderWidth,
    this.isSelected = false,
  });

  /// Standard card constructor
  const AppCard.standard({
    super.key,
    required this.child,
    this.size = AppCardSize.medium,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.isSelected = false,
  }) : variant = AppCardVariant.standard,
       borderColor = null,
       elevation = null,
       borderWidth = null;

  /// Elevated card constructor
  const AppCard.elevated({
    super.key,
    required this.child,
    this.size = AppCardSize.medium,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.elevation,
    this.isSelected = false,
  }) : variant = AppCardVariant.elevated,
       borderColor = null,
       borderWidth = null;

  /// Outlined card constructor
  const AppCard.outlined({
    super.key,
    required this.child,
    this.size = AppCardSize.medium,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.isSelected = false,
  }) : variant = AppCardVariant.outlined,
       elevation = null;

  /// Filled card constructor
  const AppCard.filled({
    super.key,
    required this.child,
    this.size = AppCardSize.medium,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.isSelected = false,
  }) : variant = AppCardVariant.filled,
       borderColor = null,
       elevation = null,
       borderWidth = null;

  /// Surface card constructor
  const AppCard.surface({
    super.key,
    required this.child,
    this.size = AppCardSize.medium,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.isSelected = false,
  }) : variant = AppCardVariant.surface,
       borderColor = null,
       elevation = null,
       borderWidth = null;

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

  /// Get card configuration based on variant and size
  _CardConfig _getCardConfig(ThemeData theme) {
    // Get size configuration
    final EdgeInsets sizePadding;
    switch (size) {
      case AppCardSize.small:
        sizePadding = DesignTokens.paddingCardSm;
        break;
      case AppCardSize.medium:
        sizePadding = DesignTokens.paddingCard;
        break;
      case AppCardSize.large:
        sizePadding = DesignTokens.paddingCardLg;
        break;
    }

    // Get variant configuration
    switch (variant) {
      case AppCardVariant.standard:
        return _CardConfig(
          backgroundColor: theme.colorScheme.surfaceContainer,
          borderRadius: DesignTokens.borderRadius(DesignTokens.radiusCard),
          padding: sizePadding,
          elevation: DesignTokens.elevationCard,
        );
      case AppCardVariant.elevated:
        return _CardConfig(
          backgroundColor: theme.colorScheme.surface,
          borderRadius: DesignTokens.borderRadius(DesignTokens.radiusCard),
          padding: sizePadding,
          elevation: elevation ?? DesignTokens.elevation2,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case AppCardVariant.outlined:
        return _CardConfig(
          backgroundColor: theme.colorScheme.surface,
          borderRadius: DesignTokens.borderRadius(DesignTokens.radiusCard),
          padding: sizePadding,
          elevation: DesignTokens.elevationCard,
          border: Border.all(
            color: borderColor ?? theme.colorScheme.outline,
            width: borderWidth ?? 1,
          ),
        );
      case AppCardVariant.filled:
        return _CardConfig(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: DesignTokens.borderRadius(DesignTokens.radiusCard),
          padding: sizePadding,
          elevation: DesignTokens.elevationCard,
        );
      case AppCardVariant.surface:
        return _CardConfig(
          backgroundColor: theme.colorScheme.surface,
          borderRadius: DesignTokens.borderRadius(DesignTokens.radiusCard),
          padding: sizePadding,
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
    this.border,
    this.boxShadow,
  });
}

/// Specialized card components for common use cases
class InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final AppCardSize size;

  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.size = AppCardSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppCard.standard(
      size: size,
      onTap: onTap,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: DesignTokens.spacingMd),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: DesignTokens.spacingXs),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: DesignTokens.spacingMd),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Metric card for displaying statistics
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Widget? icon;
  final Color? accentColor;
  final VoidCallback? onTap;
  final AppCardSize size;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.accentColor,
    this.onTap,
    this.size = AppCardSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppCard.standard(
      size: size,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            SizedBox(height: DesignTokens.spacingMd),
          ],
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: DesignTokens.spacingXs),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: accentColor ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Action card with prominent call-to-action
class ActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final String? actionText;
  final VoidCallback? onTap;
  final AppCardSize size;

  const ActionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionText,
    this.onTap,
    this.size = AppCardSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppCard.outlined(
      size: size,
      onTap: onTap,
      child: Row(
        children: [
          if (icon != null) ...[
            icon!,
            SizedBox(width: DesignTokens.spacingMd),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: DesignTokens.spacingXs),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionText != null) ...[
            SizedBox(width: DesignTokens.spacingMd),
            Text(
              actionText!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
          SizedBox(width: DesignTokens.spacingSm),
          Icon(
            Icons.arrow_forward_ios,
            size: DesignTokens.iconSm,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
} 