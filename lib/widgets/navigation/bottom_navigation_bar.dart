import 'package:flutter/material.dart';
import 'navigation_item.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final List<NavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const AppBottomNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: NavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          onDestinationSelected: onDestinationSelected,
          selectedIndex: selectedIndex,
          backgroundColor: Colors.transparent,
          indicatorColor: theme.colorScheme.primary.withOpacity(0.1),
          height: 72,
          destinations: items.map((item) {
            return NavigationDestination(
              icon: item.isSpecial
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.icon,
                        color: theme.colorScheme.surface,
                      ),
                    )
                  : Icon(
                      item.icon,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
              selectedIcon: item.isSpecial
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.selectedIcon,
                        color: theme.colorScheme.surface,
                      ),
                    )
                  : Icon(
                      item.selectedIcon,
                      color: theme.colorScheme.onSurface,
                    ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
} 