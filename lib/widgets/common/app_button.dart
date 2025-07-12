import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

/// Button variants for production use
enum AppButtonVariant {
  /// Primary button - main actions
  primary,
  /// Text button - minimal actions
  text,
  /// Destructive button - dangerous actions
  destructive,
}

/// Standardized button component for production use
/// Only supports the variants actually used in the app
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? icon;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool isLoading;
  final bool isExpanded;
  final EdgeInsets? padding;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
  });

  /// Primary button constructor
  const AppButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
  }) : variant = AppButtonVariant.primary;

  /// Text button constructor
  const AppButton.text({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
  }) : variant = AppButtonVariant.text;

  /// Destructive button constructor
  const AppButton.destructive({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
  }) : variant = AppButtonVariant.destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onPressed == null || isLoading;
    
    // Get button configuration based on variant
    final buttonConfig = _getButtonConfig(theme);
    
    // Build button content
    Widget buttonContent = _buildButtonContent(theme);
    
    // Add loading indicator if needed
    if (isLoading) {
      buttonContent = _buildLoadingContent(theme, buttonContent);
    }
    
    // Create the button
    Widget button = Material(
      color: isDisabled 
          ? buttonConfig.backgroundColor.withOpacity(DesignTokens.opacityDisabled)
          : buttonConfig.backgroundColor,
      borderRadius: DesignTokens.borderRadius(DesignTokens.radiusButton),
      elevation: buttonConfig.elevation,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: DesignTokens.borderRadius(DesignTokens.radiusButton),
        child: Container(
          height: DesignTokens.buttonHeight,
          padding: padding ?? DesignTokens.paddingButton,
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
                size: DesignTokens.iconButton,
              ),
              child: buttonContent,
            ),
          ),
        ),
      ),
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
          elevation: DesignTokens.elevationButton,
        );
      case AppButtonVariant.text:
        return _ButtonConfig(
          backgroundColor: Colors.transparent,
          foregroundColor: theme.colorScheme.primary,
          elevation: DesignTokens.elevation0,
        );
      case AppButtonVariant.destructive:
        return _ButtonConfig(
          backgroundColor: theme.colorScheme.error,
          foregroundColor: theme.colorScheme.onError,
          elevation: DesignTokens.elevationButton,
        );
    }
  }

  /// Build button content with text and icons
  Widget _buildButtonContent(ThemeData theme) {
    final textStyle = theme.textTheme.labelLarge!;
    
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
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: DesignTokens.iconButton,
          height: DesignTokens.iconButton,
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
}

/// Button configuration for styling
class _ButtonConfig {
  final Color backgroundColor;
  final Color foregroundColor;
  final double elevation;

  _ButtonConfig({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.elevation,
  });
} 