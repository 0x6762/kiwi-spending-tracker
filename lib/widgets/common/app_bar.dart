import 'package:flutter/material.dart';

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
    this.toolbarHeight = 72,
    this.backgroundColor,
  }) : assert(title != null || titleWidget != null, 'Either title or titleWidget must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      centerTitle: centerTitle,
      titleSpacing: 16,
      toolbarHeight: toolbarHeight,
      leading: leading != null
        ? IconButton(
            icon: leading!,
            onPressed: onLeadingPressed ?? () => Navigator.of(context).pop(),
          )
        : null,
      title: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: titleWidget ?? Text(
          title!,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      actions: actions != null
        ? [
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: Row(children: actions!),
            ),
          ]
        : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
} 