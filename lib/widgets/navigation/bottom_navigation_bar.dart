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
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Row(
        children: [
          // Left side: Navigation items with background (Expenses and Insights)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(56),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
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
          // Spacer to push add button to the right
          const Spacer(),
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
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected && !item.isSpecial
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Center(
          child: item.isSpecial
              ? Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      size: 28,
                      isSelected ? item.selectedIcon : item.icon,
                      color: theme.colorScheme.surface,
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