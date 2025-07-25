import 'package:flutter/material.dart';
import '../widgets/navigation/navigation_item.dart';

class NavigationService extends ChangeNotifier {
  int _selectedIndex = 0;
  
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
      icon: Icons.add,
      selectedIcon: Icons.add,
      label: 'Add Expense',
      action: NavigationAction.showDialog,
      isSpecial: true,
    ),
    NavigationItem(
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
      label: 'Insights',
      action: NavigationAction.navigate,
    ),
  ];

  void selectIndex(int index) {
    if (index != _selectedIndex) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void resetToExpenses() {
    _selectedIndex = 0;
    notifyListeners();
  }

  // Get the actual screen index (accounting for the special add button)
  int get screenIndex {
    return _selectedIndex > 1 ? _selectedIndex - 1 : _selectedIndex;
  }

  // Check if the selected item is the add button
  bool get isAddButtonSelected => _selectedIndex == 1;
} 