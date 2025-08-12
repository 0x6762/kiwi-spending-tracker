import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/account_repository.dart';
import '../services/expense_analytics_service.dart';
import '../services/navigation_service.dart';
import '../widgets/expense/expense_list.dart';
import '../widgets/navigation/bottom_navigation.dart';
import '../widgets/navigation/scroll_direction_detector.dart';
import 'multi_step_expense/multi_step_expense_screen.dart';

import '../widgets/expense/today_spending_card.dart';
import '../widgets/common/app_bar.dart';
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
  List<Expense> _expenses = [];
  bool _isLoading = true;
  late AnimationController _arrowAnimationController;
  late Animation<double> _arrowAnimation;
  final GlobalKey<BottomNavigationState> _navigationKey =
      GlobalKey<BottomNavigationState>();

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

  void _showNavigation() {
    _navigationKey.currentState?.showNavigation();
  }

  void _hideNavigation() {
    _navigationKey.currentState?.hideNavigation();
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

  void _showAddExpenseDialog() {
    _showAddExpenseDialogWithType(type: ExpenseType.variable);
  }

  void _showAddExpenseDialogWithType({required ExpenseType type}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) =>
          MultiStepExpenseScreen(
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
    ).then((_) {
      // Restore previous navigation state when dialog closes
      final navigationService =
          Provider.of<NavigationService>(context, listen: false);
      navigationService.restorePreviousState();
    });
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
              final index =
                  _expenses.indexWhere((e) => e.id == updatedExpense.id);
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
      padding: const EdgeInsets.only(top: 56, bottom: 32),
      child: Column(
        children: [
          Opacity(
            opacity: 0.7,
            child: Image.asset(
              'assets/imgs/empty-state.png',
              width: 300,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 56),
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
        child: ScrollDirectionDetector(
          onScrollDirectionChanged: (isScrollingUp) {
            // Control navigation visibility based on scroll direction
            if (isScrollingUp) {
              // Scrolling up - show navigation
              _showNavigation();
            } else {
              // Scrolling down - hide navigation
              _hideNavigation();
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
              bottom: 120,
              top: 0,
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
                        onSeeAllPressed: () {
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
                      ),
                const SizedBox(height: 8),
                if (!_isLoading) ...[
                  if (_expenses.isEmpty)
                    _buildEmptyState()
                  else
                    ExpenseList(
                      expenses: todayExpenses,
                      categoryRepo: widget.categoryRepo,
                      onTap: _viewExpenseDetails,
                      onDelete: _deleteExpense,
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationService>(
      builder: (context, navigationService, child) {
        return Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          body: IndexedStack(
            index: navigationService.screenIndex,
            children: [
              _buildExpensesScreen(),
              InsightsScreen(
                expenses: _expenses,
                categoryRepo: widget.categoryRepo,
                analyticsService: widget.analyticsService,
                repository: widget.repository,
                accountRepo: widget.accountRepo,
                onShowNavigation: _showNavigation,
                onHideNavigation: _hideNavigation,
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigation(
            key: _navigationKey,
            items: NavigationService.items,
            selectedIndex: navigationService.selectedIndex,
            onDestinationSelected: (index) {
              navigationService.selectIndex(index);

              // Handle special actions
              if (navigationService.isAddButtonSelected) {
                _showAddExpenseDialog();
              } else if (index == 0) {
                _loadExpenses();
              }
            },
          ),
        );
      },
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
