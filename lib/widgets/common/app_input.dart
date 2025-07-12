import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/design_tokens.dart';

/// Input variants for different use cases
enum AppInputVariant {
  /// Standard filled input
  filled,
  /// Outlined input
  outlined,
  /// Underlined input
  underlined,
}

/// Input sizes for different contexts
enum AppInputSize {
  /// Small input (compact)
  small,
  /// Medium input - default
  medium,
  /// Large input (expanded)
  large,
}

/// Standardized input component with consistent styling and variants
class AppInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final AppInputVariant variant;
  final AppInputSize size;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final EdgeInsets? contentPadding;
  final Color? fillColor;
  final Color? borderColor;
  final double? borderRadius;

  const AppInput({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.variant = AppInputVariant.filled,
    this.size = AppInputSize.medium,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.validator,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.borderRadius,
  });

  /// Filled input constructor
  const AppInput.filled({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.size = AppInputSize.medium,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.validator,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.borderRadius,
  }) : variant = AppInputVariant.filled;

  /// Outlined input constructor
  const AppInput.outlined({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.size = AppInputSize.medium,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.validator,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.borderRadius,
  }) : variant = AppInputVariant.outlined;

  /// Underlined input constructor
  const AppInput.underlined({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.size = AppInputSize.medium,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.validator,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.borderRadius,
  }) : variant = AppInputVariant.underlined;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _getInputConfig(theme);
    
    return TextFormField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onTap: onTap,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      focusNode: focusNode,
      textCapitalization: textCapitalization,
      style: config.textStyle,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        prefixText: prefixText,
        suffixText: suffixText,
        filled: config.filled,
        fillColor: fillColor ?? config.fillColor,
        contentPadding: contentPadding ?? config.contentPadding,
        border: config.border,
        enabledBorder: config.enabledBorder,
        focusedBorder: config.focusedBorder,
        errorBorder: config.errorBorder,
        focusedErrorBorder: config.focusedErrorBorder,
        disabledBorder: config.disabledBorder,
        labelStyle: config.labelStyle,
        hintStyle: config.hintStyle,
        helperStyle: config.helperStyle,
        errorStyle: config.errorStyle,
        counterStyle: config.counterStyle,
      ),
    );
  }

  /// Get input configuration based on variant and size
  _InputConfig _getInputConfig(ThemeData theme) {
    // Get size configuration
    final sizeConfig = _getSizeConfig(theme);
    
    // Get variant configuration
    switch (variant) {
      case AppInputVariant.filled:
        return _InputConfig(
          textStyle: sizeConfig.textStyle,
          filled: true,
          fillColor: theme.colorScheme.surfaceContainer,
          contentPadding: sizeConfig.contentPadding,
          border: OutlineInputBorder(
            borderRadius: DesignTokens.borderRadius(
              borderRadius ?? DesignTokens.radiusInput,
            ),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: DesignTokens.borderRadius(
              borderRadius ?? DesignTokens.radiusInput,
            ),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: DesignTokens.borderRadius(
              borderRadius ?? DesignTokens.radiusInput,
            ),
            borderSide: BorderSide(
              color: borderColor ?? theme.colorScheme.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: DesignTokens.borderRadius(
              borderRadius ?? DesignTokens.radiusInput,
            ),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: DesignTokens.borderRadius(
              borderRadius ?? DesignTokens.radiusInput,
            ),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: DesignTokens.borderRadius(
              borderRadius ?? DesignTokens.radiusInput,
            ),
            borderSide: BorderSide.none,
          ),
          labelStyle: sizeConfig.labelStyle,
          hintStyle: sizeConfig.hintStyle,
          helperStyle: sizeConfig.helperStyle,
          errorStyle: sizeConfig.errorStyle,
          counterStyle: sizeConfig.counterStyle,
        );
      case AppInputVariant.outlined:
        return _InputConfig(
          textStyle: sizeConfig.textStyle,
          filled: false,
          fillColor: Colors.transparent,
          contentPadding: sizeConfig.contentPadding,
          border: OutlineInputBorder(
            borderRadius: DesignTokens.borderRadius(
              borderRadius ?? DesignTokens.radiusInput,
            ),
            borderSide: BorderSide(
              color: borderColor ?? theme.colorScheme.outline,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: DesignTokens.borderRadius(
              borderRadius ?? DesignTokens.radiusInput,
            ),
            borderSide: BorderSide(
              color: borderColor ?? theme.colorScheme.outline,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: DesignTokens.borderRadius(
              borderRadius ?? DesignTokens.radiusInput,
            ),
            borderSide: BorderSide(
              color: borderColor ?? theme.colorScheme.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: DesignTokens.borderRadius(
              borderRadius ?? DesignTokens.radiusInput,
            ),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: DesignTokens.borderRadius(
              borderRadius ?? DesignTokens.radiusInput,
            ),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: DesignTokens.borderRadius(
              borderRadius ?? DesignTokens.radiusInput,
            ),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withOpacity(DesignTokens.opacityDisabled),
            ),
          ),
          labelStyle: sizeConfig.labelStyle,
          hintStyle: sizeConfig.hintStyle,
          helperStyle: sizeConfig.helperStyle,
          errorStyle: sizeConfig.errorStyle,
          counterStyle: sizeConfig.counterStyle,
        );
      case AppInputVariant.underlined:
        return _InputConfig(
          textStyle: sizeConfig.textStyle,
          filled: false,
          fillColor: Colors.transparent,
          contentPadding: sizeConfig.contentPadding,
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: borderColor ?? theme.colorScheme.outline,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: borderColor ?? theme.colorScheme.outline,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: borderColor ?? theme.colorScheme.primary,
              width: 2,
            ),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: theme.colorScheme.error,
            ),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: theme.colorScheme.error,
              width: 2,
            ),
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withOpacity(DesignTokens.opacityDisabled),
            ),
          ),
          labelStyle: sizeConfig.labelStyle,
          hintStyle: sizeConfig.hintStyle,
          helperStyle: sizeConfig.helperStyle,
          errorStyle: sizeConfig.errorStyle,
          counterStyle: sizeConfig.counterStyle,
        );
    }
  }

  /// Get size configuration based on input size
  _SizeConfig _getSizeConfig(ThemeData theme) {
    switch (size) {
      case AppInputSize.small:
        return _SizeConfig(
          textStyle: theme.textTheme.bodySmall!,
          contentPadding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingMd,
            vertical: DesignTokens.spacingSm,
          ),
          labelStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          hintStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          helperStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          errorStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
          counterStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        );
      case AppInputSize.medium:
        return _SizeConfig(
          textStyle: theme.textTheme.bodyLarge!,
          contentPadding: DesignTokens.paddingInput,
          labelStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          helperStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          errorStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
          counterStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        );
      case AppInputSize.large:
        return _SizeConfig(
          textStyle: theme.textTheme.titleMedium!,
          contentPadding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingLg,
            vertical: DesignTokens.spacingLg,
          ),
          labelStyle: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          hintStyle: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          helperStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          errorStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
          counterStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        );
    }
  }
}

/// Input configuration for styling
class _InputConfig {
  final TextStyle textStyle;
  final bool filled;
  final Color fillColor;
  final EdgeInsets contentPadding;
  final InputBorder border;
  final InputBorder enabledBorder;
  final InputBorder focusedBorder;
  final InputBorder errorBorder;
  final InputBorder focusedErrorBorder;
  final InputBorder disabledBorder;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? helperStyle;
  final TextStyle? errorStyle;
  final TextStyle? counterStyle;

  _InputConfig({
    required this.textStyle,
    required this.filled,
    required this.fillColor,
    required this.contentPadding,
    required this.border,
    required this.enabledBorder,
    required this.focusedBorder,
    required this.errorBorder,
    required this.focusedErrorBorder,
    required this.disabledBorder,
    this.labelStyle,
    this.hintStyle,
    this.helperStyle,
    this.errorStyle,
    this.counterStyle,
  });
}

/// Size configuration for inputs
class _SizeConfig {
  final TextStyle textStyle;
  final EdgeInsets contentPadding;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? helperStyle;
  final TextStyle? errorStyle;
  final TextStyle? counterStyle;

  _SizeConfig({
    required this.textStyle,
    required this.contentPadding,
    this.labelStyle,
    this.hintStyle,
    this.helperStyle,
    this.errorStyle,
    this.counterStyle,
  });
}

/// Specialized input components for common use cases
class SearchInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final AppInputSize size;

  const SearchInput({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onClear,
    this.size = AppInputSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    return AppInput.filled(
      controller: controller,
      hintText: hintText,
      onChanged: onChanged,
      size: size,
      prefixIcon: const Icon(Icons.search),
      suffixIcon: controller?.text.isNotEmpty == true
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: onClear ?? () => controller?.clear(),
            )
          : null,
      textInputAction: TextInputAction.search,
    );
  }
}

/// Password input with visibility toggle
class PasswordInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final AppInputSize size;

  const PasswordInput({
    super.key,
    this.controller,
    this.labelText = 'Password',
    this.hintText,
    this.onChanged,
    this.validator,
    this.size = AppInputSize.medium,
  });

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AppInput.filled(
      controller: widget.controller,
      labelText: widget.labelText,
      hintText: widget.hintText,
      onChanged: widget.onChanged,
      validator: widget.validator,
      size: widget.size,
      obscureText: _obscureText,
      textInputAction: TextInputAction.done,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
        ),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      ),
    );
  }
} 