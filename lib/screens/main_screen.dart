import 'package:flutter/material.dart';
import '../repositories/expense_repository.dart';
import 'expense_list_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  final ExpenseRepository repository;

  const MainScreen({super.key, required this.repository});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          ExpenseListScreen(repository: widget.repository),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.surfaceVariant,
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedIndex: _selectedIndex,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          elevation: 0,
          height: 80,
          indicatorColor: Theme.of(context).colorScheme.outlineVariant,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.receipt_outlined,
                color: _selectedIndex == 0
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              selectedIcon: Icon(
                Icons.receipt,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: 'Expenses',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.settings_outlined,
                color: _selectedIndex == 1
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              selectedIcon: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
