import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../repositories/expense_repository.dart';
import '../widgets/expense_list.dart';
import '../widgets/expense_summary.dart';
import '../widgets/add_expense_dialog.dart';
import '../widgets/expense_type_sheet.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  final ExpenseRepository repository;

  const MainScreen({super.key, required this.repository});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Expense> _expenses = [];
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final expenses = await widget.repository.getAllExpenses();
    setState(() {
      _expenses = expenses;
    });
  }

  Future<void> _addExpense() async {
    final isFixed = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => const ExpenseTypeSheet(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );

    if (isFixed != null) {
      final result = await Navigator.of(context).push<Expense>(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              AddExpenseDialog(
            isFixed: isFixed,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );

      if (result != null) {
        await widget.repository.addExpense(result);
        _loadExpenses();
      }
    }
  }

  Future<void> _deleteExpense(Expense expense) async {
    await widget.repository.deleteExpense(expense.id);
    _loadExpenses();
  }

  void _viewExpenseDetails(Expense expense) {
    // TODO: Implement expense details/edit
  }

  void _onMonthSelected(DateTime month) {
    setState(() {
      _selectedMonth = month;
    });
  }

  Widget _buildExpensesScreen() {
    final filteredExpenses = _expenses
        .where((expense) =>
            expense.date.year == _selectedMonth.year &&
            expense.date.month == _selectedMonth.month)
        .toList();

    return Scaffold(
      backgroundColor:
          Theme.of(context).colorScheme.surface, //main screen background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ExpenseSummary(
                expenses: _expenses,
                selectedMonth: _selectedMonth,
                onMonthSelected: _onMonthSelected,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Recent transactions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface, //expenses list background
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: ExpenseList(
                  expenses: filteredExpenses,
                  onDelete: _deleteExpense,
                  onTap: _viewExpenseDetails,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        foregroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildExpensesScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedIndex: _selectedIndex,
        backgroundColor: Theme.of(context)
            .colorScheme
            .surfaceContainer, // Navigation bar background
        indicatorColor: Theme.of(context)
            .colorScheme
            .primary //Navigation bar background indicator
            .withOpacity(0.2),
        height: 72,
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.receipt_outlined,
              color: Theme.of(context).colorScheme.onSurface,
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
              color: Theme.of(context).colorScheme.onSurface,
            ),
            selectedIcon: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
