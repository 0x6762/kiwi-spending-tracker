import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../common/app_button.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cancelText;
  final String deleteText;

  const DeleteConfirmationDialog({
    super.key,
    this.title = 'Delete Expense',
    this.message = 'Are you sure you want to delete this expense?',
    this.cancelText = 'Cancel',
    this.deleteText = 'Delete',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.colorScheme.surfaceContainer,
      titlePadding: DesignTokens.paddingOnly(
        left: DesignTokens.spacingLg,
        top: DesignTokens.spacingLg,
        right: DesignTokens.spacingLg,
        bottom: DesignTokens.spacingMd,
      ),
      contentPadding: DesignTokens.paddingOnly(
        left: DesignTokens.spacingLg,
        top: 0,
        right: DesignTokens.spacingLg,
        bottom: DesignTokens.spacingLg,
      ),
      actionsPadding: DesignTokens.paddingOnly(
        left: DesignTokens.spacingLg,
        top: 0,
        right: DesignTokens.spacingLg,
        bottom: DesignTokens.spacingMd,
      ),
      title: Text(title, style: theme.textTheme.titleMedium),
      content: Text(message, style: theme.textTheme.bodyLarge),
      shape: RoundedRectangleBorder(
        borderRadius: DesignTokens.borderRadius(DesignTokens.radiusCard),
      ),
      actions: [
        AppButton.text(
          text: cancelText,
          onPressed: () => Navigator.pop(context, false),
        ),
        SizedBox(width: DesignTokens.spacingSm),
        AppButton.destructive(
          text: deleteText,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }

  static Future<bool?> show(BuildContext context, {
    String? title,
    String? message,
    String? cancelText,
    String? deleteText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: title ?? 'Delete Expense',
        message: message ?? 'Are you sure you want to delete this expense?',
        cancelText: cancelText ?? 'Cancel',
        deleteText: deleteText ?? 'Delete',
      ),
    );
  }
} 