import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

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
    final maxHeight = MediaQuery.of(context).size.height * 0.7;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: DesignTokens.borderRadiusTop(DesignTokens.radiusSheet),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(DesignTokens.spacingMd),
            child: Text(
              title,
              style: theme.textTheme.titleMedium,
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, DesignTokens.spacingMd),
                child: Column(
                  children: children,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
