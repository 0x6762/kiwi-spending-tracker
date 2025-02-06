import 'package:flutter/material.dart';

class AppBottomSheet extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final EdgeInsets? contentPadding;

  const AppBottomSheet({
    super.key,
    this.title,
    required this.children,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    title!,
                    style: theme.textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (contentPadding != null)
            Padding(
              padding: contentPadding!,
              child: Column(children: children),
            )
          else
            ...children,
        ],
      ),
    );
  }
} 