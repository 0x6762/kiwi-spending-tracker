import 'package:flutter/material.dart';

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
        padding: const EdgeInsets.only(
          left: 16,
          right: 10,
          top: 8,
          bottom: 8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon!,
              size: 18,
              color: iconColor ?? theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    );
  }
}
