import 'package:flutter/material.dart';

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
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      title: Text(title, style: theme.textTheme.titleMedium),
      content: Text(message, style: theme.textTheme.bodyLarge),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurfaceVariant,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text(
            cancelText,
            style: theme.textTheme.labelMedium?.copyWith(
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text(
            deleteText,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
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