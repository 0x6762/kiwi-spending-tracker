import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

class KiwiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool centerTitle;
  final Widget? leading;
  final VoidCallback? onLeadingPressed;
  final double toolbarHeight;
  final Color? backgroundColor;

  const KiwiAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.centerTitle = false,
    this.leading,
    this.onLeadingPressed,
    this.toolbarHeight = DesignTokens.appBarHeight,
    this.backgroundColor,
  }) : assert(title != null || titleWidget != null,
            'Either title or titleWidget must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      centerTitle: centerTitle,
      titleSpacing: DesignTokens.spacingMd,
      toolbarHeight: toolbarHeight,
      leading: leading != null
          ? IconButton(
              icon: leading!,
              onPressed: onLeadingPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: titleWidget ??
            Text(
              title!,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
      ),
      actions: actions != null
          ? [
              Padding(
                padding: EdgeInsets.only(
                  top: DesignTokens.spacingSm,
                  right: DesignTokens.spacingSm,
                ),
                child: Row(children: actions!),
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}
