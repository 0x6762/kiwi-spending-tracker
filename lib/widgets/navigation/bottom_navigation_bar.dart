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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left side: Navigation items with background (Expenses and Insights)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(56),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 25,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Row(
              children: [
                // Expenses tab
                _buildNavigationItem(
                  context,
                  items[0],
                  selectedIndex == 0,
                  () => onDestinationSelected(0),
                ),
                const SizedBox(width: 16),
                // Insights tab
                _buildNavigationItem(
                  context,
                  items[1],
                  selectedIndex == 1,
                  () => onDestinationSelected(1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16), // 20px spacing between groups
          // Right side: Add button (no background)
          _buildNavigationItem(
            context,
            items[2],
            selectedIndex == 2,
            () => onDestinationSelected(2),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    NavigationItem item,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: item.isSpecial ? 48 : 48,
        height: item.isSpecial ? 48 : 48,
        decoration: BoxDecoration(
          color: isSelected && !item.isSpecial
              ? theme.colorScheme.onSurface.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(item.isSpecial ? 56 : 56),
        ),
        child: Center(
          child: item.isSpecial
              ? Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(56),
                  ),
                  child: Center(
                    child: Icon(
                      size: 32,
                      isSelected ? item.selectedIcon : item.icon,
                      color: theme.colorScheme.surfaceContainerLow,
                    ),
                  ),
                )
              : Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  size: 24,
                  color: isSelected
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                ),
        ),
      ),
    );
  }
}
