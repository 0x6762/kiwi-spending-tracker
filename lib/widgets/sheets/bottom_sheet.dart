import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

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
      padding: EdgeInsets.symmetric(vertical: DesignTokens.spacingLg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: DesignTokens.borderRadiusTop(DesignTokens.radiusCard),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingLg),
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
            SizedBox(height: DesignTokens.spacingSm),
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