import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/account_repository.dart';
import '../services/expense_analytics_service.dart';
import '../widgets/expense/expense_list.dart';
import '../widgets/dialogs/add_expense_dialog.dart';
import '../widgets/sheets/expense_type_sheet.dart';
import '../widgets/forms/voice_input_button.dart';
import '../widgets/expense/today_spending_card.dart';
import '../widgets/common/app_bar.dart';
import '../widgets/expense/expense_summary.dart';
import '../widgets/expense/expense_filter_row.dart';
import '../utils/icons.dart';
import 'settings_screen.dart';
import 'expense_detail_screen.dart';
import 'insights_screen.dart';
import 'all_expenses_screen.dart';

class MainScreen extends StatefulWidget {
  final ExpenseRepository repository;
  final CategoryRepository categoryRepo;
  final AccountRepository accountRepo;
  final ExpenseAnalyticsService analyticsService;

  const MainScreen({
    super.key, 
    required this.repository,
    required this.categoryRepo,
    required this.accountRepo,
    required this.analyticsService,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  List<Expense> _expenses = [];
  bool _isLoading = true;
  late AnimationController _arrowAnimationController;
  late Animation<double> _arrowAnimation;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 18) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadExpenses();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _arrowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _arrowAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _arrowAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _arrowAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);
    try {
      final expenses = await widget.repository.getAllExpenses();
      setState(() {
        _expenses = expenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load expenses: ${e.toString()}')),
        );
      }
    }
  }

  void _showExpenseTypeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpenseTypeSheet(
        onTypeSelected: (type) {
          Navigator.pop(context);
          _showAddExpenseDialog(type: type);
        },
        repository: widget.repository,
        categoryRepo: widget.categoryRepo,
        onExpenseAdded: _loadExpenses,
      ),
    );
  }

  void _showAddExpenseDialog({required ExpenseType type}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => AddExpenseDialog(
        type: type,
        categoryRepo: widget.categoryRepo,
        accountRepo: widget.accountRepo,
        onExpenseAdded: (expense) async {
          await widget.repository.addExpense(expense);
          _loadExpenses();
        },
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  void _viewExpenseDetails(Expense expense) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailScreen(
          expense: expense,
          categoryRepo: widget.categoryRepo,
          accountRepo: widget.accountRepo,
          onExpenseUpdated: (updatedExpense) async {
            await widget.repository.updateExpense(updatedExpense);
            setState(() {
              final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
              if (index != -1) {
                _expenses[index] = updatedExpense;
              }
            });
          },
        ),
        maintainState: true,
      ),
    );

    if (result == true) {
      await _deleteExpense(expense);
    }
  }

  Future<void> _deleteExpense(Expense expense) async {
    await widget.repository.deleteExpense(expense.id);
    setState(() {
      _expenses.removeWhere((e) => e.id == expense.id);
    });
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 32),
      child: Column(
        children: [
          Text(
            'Start by adding an expense',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    );
  }

  Widget _buildExpenseList(List<Expense> filteredExpenses) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            children: [
              Text(
                'Recent expenses',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllExpensesScreen(
                        expenses: _expenses,
                        categoryRepo: widget.categoryRepo,
                        repository: widget.repository,
                        accountRepo: widget.accountRepo,
                        onDelete: _deleteExpense,
                        onExpenseUpdated: _loadExpenses,
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
                child: Text(
                  'See all',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          color: theme.colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
          child: _isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : ExpenseList(
                  expenses: filteredExpenses,
                  categoryRepo: widget.categoryRepo,
                  onTap: _viewExpenseDetails,
                  onDelete: _deleteExpense,
                ),
        ),
      ],
    );
  }

  Widget _buildExpensesScreen() {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final todayExpenses = _expenses
        .where((expense) =>
            expense.date.year == now.year &&
            expense.date.month == now.month &&
            expense.date.day == now.day)
        .toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      extendBody: true,
      appBar: KiwiAppBar(
        title: _greeting,
        actions: [
          _SettingsButton(
            categoryRepo: widget.categoryRepo,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadExpenses,
        color: theme.colorScheme.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
            bottom: 104,
            top: 8,
          ),
          clipBehavior: Clip.none,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : TodaySpendingCard(
                      expenses: _expenses,
                      analyticsService: widget.analyticsService,
                    ),
              const SizedBox(height: 8),
              if (!_isLoading) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'Recent expenses',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllExpensesScreen(
                                expenses: _expenses,
                                categoryRepo: widget.categoryRepo,
                                repository: widget.repository,
                                accountRepo: widget.accountRepo,
                                onDelete: _deleteExpense,
                                onExpenseUpdated: _loadExpenses,
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                        child: Text(
                          'See all',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_expenses.isEmpty)
                  _buildEmptyState()
                else
                  Card(
                    margin: EdgeInsets.zero,
                    color: theme.colorScheme.surfaceContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                    child: ExpenseList(
                      expenses: todayExpenses,
                      categoryRepo: widget.categoryRepo,
                      onTap: _viewExpenseDetails,
                      onDelete: _deleteExpense,
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
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildExpensesScreen(),
          InsightsScreen(
            expenses: _expenses,
            categoryRepo: widget.categoryRepo,
            analyticsService: widget.analyticsService,
            repository: widget.repository,
            accountRepo: widget.accountRepo,
          ),
        ],
      ),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (index == 1) {
            _showExpenseTypeSheet();
          } else {
            setState(() {
              _selectedIndex = index > 1 ? index - 1 : index;
            });

            if (index == 0) {
              _loadExpenses();
            }
          }
        },
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _BottomNavBar({
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
          selectedIndex: selectedIndex > 0 ? selectedIndex + 1 : selectedIndex,
          backgroundColor: Colors.transparent,
          indicatorColor: theme.colorScheme.primary.withOpacity(0.1),
          height: 72,
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.wallet_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              selectedIcon: Icon(
                Icons.wallet,
                color: theme.colorScheme.onSurface,
              ),
              label: '',
            ),
            NavigationDestination(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: theme.colorScheme.surface,
                ),
              ),
              label: '',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.insights_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              selectedIcon: Icon(
                Icons.insights,
                color: theme.colorScheme.onSurface,
              ),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final CategoryRepository categoryRepo;

  const _SettingsButton({
    required this.categoryRepo,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        AppIcons.more,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsScreen(
              categoryRepo: categoryRepo,
            ),
          ),
        );
      },
    );
  }
}
