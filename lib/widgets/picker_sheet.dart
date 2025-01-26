import 'package:flutter/material.dart';

class PickerSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const PickerSheet({
    super.key,
    required this.title,
    required this.children,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PickerSheet(
        title: title,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              title,
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
