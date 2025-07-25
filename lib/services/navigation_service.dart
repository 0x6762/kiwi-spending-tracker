import 'package:flutter/material.dart';
import '../widgets/navigation/navigation_item.dart';

class NavigationService extends ChangeNotifier {
  int _selectedIndex = 0;
  int _previousIndex = 0; // Track previous navigation state
  
  int get selectedIndex => _selectedIndex;

  // Define navigation items
  static const List<NavigationItem> items = [
    NavigationItem(
      icon: Icons.wallet_outlined,
      selectedIcon: Icons.wallet,
      label: 'Expenses',
      action: NavigationAction.navigate,
    ),
    NavigationItem(
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
      label: 'Insights',
      action: NavigationAction.navigate,
    ),
    NavigationItem(
      icon: Icons.arrow_outward_rounded,
      selectedIcon: Icons.arrow_outward_rounded,
      label: 'Add Expense',
      action: NavigationAction.showDialog,
      isSpecial: true,
    ),
  ];

  void selectIndex(int index) {
    if (index != _selectedIndex) {
      _previousIndex = _selectedIndex; // Store previous state
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void resetToExpenses() {
    _selectedIndex = 0;
    _previousIndex = 0;
    notifyListeners();
  }

  // Restore previous navigation state (used when add dialog closes)
  void restorePreviousState() {
    _selectedIndex = _previousIndex;
    notifyListeners();
  }

  // Get the actual screen index (accounting for the special add button)
  int get screenIndex {
    // If add button is selected (index 2), stay on current screen
    if (_selectedIndex == 2) {
      return _previousIndex;
    }
    return _selectedIndex;
  }

  // Check if the selected item is the add button
  bool get isAddButtonSelected => _selectedIndex == 2;
} 