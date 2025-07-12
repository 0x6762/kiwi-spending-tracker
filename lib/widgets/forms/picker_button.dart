import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../common/icon_container.dart';

class PickerButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? iconColor;

  const PickerButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: theme.colorScheme.surfaceContainer,
        foregroundColor: theme.colorScheme.onSurfaceVariant,
        padding: DesignTokens.paddingSymmetric(
          horizontal: DesignTokens.spacingMd,
          vertical: DesignTokens.spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.borderRadius(DesignTokens.radiusInput),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconContainer.icon(
            icon: icon ?? Icons.category_outlined,
            iconColor: iconColor ?? theme.colorScheme.primary,
            backgroundColor: (iconColor ?? theme.colorScheme.primary).withOpacity(0.1),
          ),
          SizedBox(width: DesignTokens.spacingMd),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: theme.colorScheme.onSurfaceVariant,
            size: DesignTokens.iconButton,
          ),
        ],
      ),
    );
  }
}
