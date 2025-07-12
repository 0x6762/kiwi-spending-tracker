import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

/// Button variants for different use cases
enum AppButtonVariant {
  /// Primary button - main actions
  primary,
  /// Secondary button - secondary actions
  secondary,
  /// Text button - minimal actions
  text,
  /// Outline button - alternative actions
  outline,
  /// Destructive button - dangerous actions
  destructive,
}

/// Button sizes for different contexts
enum AppButtonSize {
  /// Small button (36px height)
  small,
  /// Medium button (48px height) - default
  medium,
  /// Large button (56px height)
  large,
}

/// Standardized button component with consistent styling and variants
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? icon;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool isLoading;
  final bool isExpanded;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
    this.borderRadius,
  });

  /// Primary button constructor
  const AppButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
    this.borderRadius,
  }) : variant = AppButtonVariant.primary;

  /// Secondary button constructor
  const AppButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
    this.borderRadius,
  }) : variant = AppButtonVariant.secondary;

  /// Text button constructor
  const AppButton.text({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
    this.borderRadius,
  }) : variant = AppButtonVariant.text;

  /// Outline button constructor
  const AppButton.outline({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
    this.borderRadius,
  }) : variant = AppButtonVariant.outline;

  /// Destructive button constructor
  const AppButton.destructive({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
    this.borderRadius,
  }) : variant = AppButtonVariant.destructive;

  /// Icon button constructor
  const AppButton.icon({
    super.key,
    required this.text,
    required this.onPressed,
    required this.icon,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onPressed == null || isLoading;
    
    // Get button configuration based on variant
    final buttonConfig = _getButtonConfig(theme);
    
    // Get button size configuration
    final sizeConfig = _getSizeConfig();
    
    // Build button content
    Widget buttonContent = _buildButtonContent(theme);
    
    // Add loading indicator if needed
    if (isLoading) {
      buttonContent = _buildLoadingContent(theme, buttonContent);
    }
    
    // Create the button
    Widget button = _buildButton(
      context,
      buttonContent,
      buttonConfig,
      sizeConfig,
      isDisabled,
    );
    
    // Expand button if needed
    if (isExpanded) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    
    return button;
  }

  /// Get button configuration based on variant
  _ButtonConfig _getButtonConfig(ThemeData theme) {
    switch (variant) {
      case AppButtonVariant.primary:
        return _ButtonConfig(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          borderColor: null,
          elevation: DesignTokens.elevationButton,
        );
      case AppButtonVariant.secondary:
        return _ButtonConfig(
          backgroundColor: theme.colorScheme.surfaceContainer,
          foregroundColor: theme.colorScheme.onSurface,
          borderColor: null,
          elevation: DesignTokens.elevationButton,
        );
      case AppButtonVariant.text:
        return _ButtonConfig(
          backgroundColor: Colors.transparent,
          foregroundColor: theme.colorScheme.primary,
          borderColor: null,
          elevation: DesignTokens.elevation0,
        );
      case AppButtonVariant.outline:
        return _ButtonConfig(
          backgroundColor: Colors.transparent,
          foregroundColor: theme.colorScheme.primary,
          borderColor: theme.colorScheme.outline,
          elevation: DesignTokens.elevation0,
        );
      case AppButtonVariant.destructive:
        return _ButtonConfig(
          backgroundColor: theme.colorScheme.error,
          foregroundColor: theme.colorScheme.onError,
          borderColor: null,
          elevation: DesignTokens.elevationButton,
        );
    }
  }

  /// Get size configuration based on size
  _SizeConfig _getSizeConfig() {
    switch (size) {
      case AppButtonSize.small:
        return _SizeConfig(
          height: DesignTokens.buttonHeightSm,
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingMd,
            vertical: DesignTokens.spacingSm,
          ),
          textStyle: 'labelMedium',
          iconSize: DesignTokens.iconSm,
        );
      case AppButtonSize.medium:
        return _SizeConfig(
          height: DesignTokens.buttonHeight,
          padding: padding ?? DesignTokens.paddingButton,
          textStyle: 'labelLarge',
          iconSize: DesignTokens.iconButton,
        );
      case AppButtonSize.large:
        return _SizeConfig(
          height: DesignTokens.buttonHeightLg,
          padding: padding ?? DesignTokens.paddingButtonLg,
          textStyle: 'titleMedium',
          iconSize: DesignTokens.iconMd,
        );
    }
  }

  /// Build button content with text and icons
  Widget _buildButtonContent(ThemeData theme) {
    final sizeConfig = _getSizeConfig();
    final textStyle = _getTextStyle(theme, sizeConfig.textStyle);
    
    List<Widget> children = [];
    
    // Add leading icon
    if (leadingIcon != null) {
      children.add(leadingIcon!);
      children.add(SizedBox(width: DesignTokens.spacingSm));
    }
    
    // Add main icon (for icon buttons)
    if (icon != null) {
      children.add(icon!);
      if (text.isNotEmpty) {
        children.add(SizedBox(width: DesignTokens.spacingSm));
      }
    }
    
    // Add text
    if (text.isNotEmpty) {
      children.add(
        Flexible(
          child: Text(
            text,
            style: textStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      );
    }
    
    // Add trailing icon
    if (trailingIcon != null) {
      children.add(SizedBox(width: DesignTokens.spacingSm));
      children.add(trailingIcon!);
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  /// Build loading content with spinner
  Widget _buildLoadingContent(ThemeData theme, Widget originalContent) {
    final buttonConfig = _getButtonConfig(theme);
    final sizeConfig = _getSizeConfig();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: sizeConfig.iconSize,
          height: sizeConfig.iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              buttonConfig.foregroundColor,
            ),
          ),
        ),
        if (text.isNotEmpty) ...[
          SizedBox(width: DesignTokens.spacingSm),
          Flexible(
            child: Opacity(
              opacity: DesignTokens.opacityDisabled,
              child: originalContent,
            ),
          ),
        ],
      ],
    );
  }

  /// Build the actual button widget
  Widget _buildButton(
    BuildContext context,
    Widget content,
    _ButtonConfig buttonConfig,
    _SizeConfig sizeConfig,
    bool isDisabled,
  ) {
    return Material(
      color: isDisabled 
          ? buttonConfig.backgroundColor.withOpacity(DesignTokens.opacityDisabled)
          : buttonConfig.backgroundColor,
      borderRadius: borderRadius ?? DesignTokens.borderRadius(DesignTokens.radiusButton),
      elevation: buttonConfig.elevation,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: borderRadius ?? DesignTokens.borderRadius(DesignTokens.radiusButton),
        child: Container(
          height: sizeConfig.height,
          padding: sizeConfig.padding,
          decoration: buttonConfig.borderColor != null
              ? BoxDecoration(
                  border: Border.all(
                    color: isDisabled
                        ? buttonConfig.borderColor!.withOpacity(DesignTokens.opacityDisabled)
                        : buttonConfig.borderColor!,
                  ),
                  borderRadius: borderRadius ?? DesignTokens.borderRadius(DesignTokens.radiusButton),
                )
              : null,
          child: DefaultTextStyle(
            style: TextStyle(
              color: isDisabled
                  ? buttonConfig.foregroundColor.withOpacity(DesignTokens.opacityDisabled)
                  : buttonConfig.foregroundColor,
            ),
            child: IconTheme(
              data: IconThemeData(
                color: isDisabled
                    ? buttonConfig.foregroundColor.withOpacity(DesignTokens.opacityDisabled)
                    : buttonConfig.foregroundColor,
                size: sizeConfig.iconSize,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  /// Get text style based on style name
  TextStyle _getTextStyle(ThemeData theme, String styleName) {
    switch (styleName) {
      case 'labelSmall':
        return theme.textTheme.labelSmall!;
      case 'labelMedium':
        return theme.textTheme.labelMedium!;
      case 'labelLarge':
        return theme.textTheme.labelLarge!;
      case 'titleMedium':
        return theme.textTheme.titleMedium!;
      default:
        return theme.textTheme.labelLarge!;
    }
  }
}

/// Button configuration for styling
class _ButtonConfig {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final double elevation;

  _ButtonConfig({
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    required this.elevation,
  });
}

/// Size configuration for buttons
class _SizeConfig {
  final double height;
  final EdgeInsets padding;
  final String textStyle;
  final double iconSize;

  _SizeConfig({
    required this.height,
    required this.padding,
    required this.textStyle,
    required this.iconSize,
  });
} 