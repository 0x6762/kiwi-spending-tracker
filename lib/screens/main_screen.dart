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
import 'expense_detail_screen.dart';
import 'insights_screen.dart';

class MainScreen extends StatefulWidget {
  final ExpenseRepository repository;

  const MainScreen({super.key, required this.repository});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  List<Expense> _expenses = [];
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  late AnimationController _arrowAnimationController;
  late Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _arrowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _arrowAnimation = Tween<double>(
      begin: 0.0,
      end: 12.0,
    ).animate(CurvedAnimation(
      parent: _arrowAnimationController,
      curve: Curves.easeInOut,
    ));

    _arrowAnimationController.repeat(reverse: true);
    _loadExpenses();
  }

  @override
  void dispose() {
    _arrowAnimationController.dispose();
    super.dispose();
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
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          maintainState: true,
          fullscreenDialog: true,
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

  void _viewExpenseDetails(Expense expense) async {
    final shouldDelete = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailScreen(expense: expense),
        maintainState: true,
      ),
    );

    if (shouldDelete == true) {
      await _deleteExpense(expense);
    } else {
      // Refresh expenses when returning from detail screen
      // to ensure category changes are reflected
      await _loadExpenses();
    }
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _loadExpenses,
        color: Theme.of(context).colorScheme.primary,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 80),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                    16, MediaQuery.of(context).padding.top + 8, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kiwi Spending',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.settings_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              ExpenseSummary(
                expenses: _expenses,
                selectedMonth: _selectedMonth,
                onMonthSelected: _onMonthSelected,
              ),
              if (filteredExpenses.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Column(
                    children: [
                      Text(
                        'Start by adding an expense',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedBuilder(
                        animation: _arrowAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _arrowAnimation.value),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Recent transactions',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildExpensesScreen(),
          CategoriesScreen(
            expenses: _expenses,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          onDestinationSelected: (index) {
            if (index == 1) {
              _addExpense();
            } else {
              setState(() {
                _selectedIndex = index > 1 ? index - 1 : index;
              });

              // Refresh expenses when returning to main screen
              if (index == 0) {
                _loadExpenses();
              }
            }
          },
          selectedIndex:
              _selectedIndex > 0 ? _selectedIndex + 1 : _selectedIndex,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          indicatorColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
          height: 72,
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.wallet_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              selectedIcon: Icon(
                Icons.wallet,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              label: 'Spending',
            ),
            NavigationDestination(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
              label: 'Add',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.insights_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              selectedIcon: Icon(
                Icons.insights,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              label: 'Insights',
            ),
          ],
        ),
      ),
    );
  }
}
