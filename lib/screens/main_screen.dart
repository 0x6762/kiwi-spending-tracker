import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';
import '../services/expense_analytics_service.dart';
import '../widgets/expense_list.dart';
import '../widgets/add_expense_dialog.dart';
import '../widgets/expense_type_sheet.dart';
import '../widgets/voice_input_button.dart';
import '../widgets/today_spending_card.dart';
import '../widgets/app_bar.dart';
import 'settings_screen.dart';
import 'expense_detail_screen.dart';
import 'insights_screen.dart';
import 'all_expenses_screen.dart';

class MainScreen extends StatefulWidget {
  final ExpenseRepository repository;
  final CategoryRepository categoryRepo;
  final ExpenseAnalyticsService analyticsService;

  const MainScreen({
    super.key, 
    required this.repository,
    required this.categoryRepo,
    required this.analyticsService,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  List<Expense> _expenses = [];
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
    final expenses = await widget.repository.getAllExpenses();
    setState(() {
      _expenses = expenses;
    });
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

  Future<void> _deleteExpense(Expense expense) async {
    await widget.repository.deleteExpense(expense.id);
    _loadExpenses();
  }

  void _viewExpenseDetails(Expense expense) async {
    final shouldDelete = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailScreen(
          expense: expense,
          categoryRepo: widget.categoryRepo,
        ),
        maintainState: true,
      ),
    );

    if (shouldDelete == true) {
      await _deleteExpense(expense);
    } else {
      await _loadExpenses();
    }
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
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
                style: theme.textTheme.titleMedium?.copyWith(
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
                        onDelete: _deleteExpense,
                        onTap: _viewExpenseDetails,
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
          child: ExpenseList(
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
    final now = DateTime.now();
    final todayExpenses = _expenses
        .where((expense) =>
            expense.date.year == now.year &&
            expense.date.month == now.month &&
            expense.date.day == now.day)
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
        color: Theme.of(context).colorScheme.primary,
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
              TodaySpendingCard(
                expenses: _expenses,
              ),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                color: Theme.of(context).colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
                child: InkWell(
                  onTap: _showExpenseTypeSheet,
                  borderRadius: BorderRadius.circular(28),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Add new expense',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_expenses.isEmpty)
                _buildEmptyState()
              else
                _buildExpenseList(todayExpenses),
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
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 ? VoiceInputButton(
        repository: widget.repository,
        categoryRepo: widget.categoryRepo,
        onExpenseAdded: _loadExpenses,
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
        Icons.more_horiz,
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
