import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../repositories/category_repository.dart';
import '../repositories/expense_repository.dart';
import '../repositories/account_repository.dart';
import '../services/expense_analytics_service.dart';
import '../providers/expense_state_manager.dart';
import '../widgets/expense/category_statistics.dart';
import '../widgets/expense/expense_summary.dart';
import '../widgets/common/app_bar.dart';
import '../utils/icons.dart';
import '../utils/scroll_aware_button_controller.dart';
import 'settings_screen.dart';

class InsightsScreen extends StatefulWidget {
  final CategoryRepository categoryRepo;
  final ExpenseAnalyticsService analyticsService;
  final ExpenseRepository repository;
  final AccountRepository accountRepo;
  final VoidCallback? onShowNavigation;
  final VoidCallback? onHideNavigation;

  const InsightsScreen({
    super.key,
    required this.categoryRepo,
    required this.analyticsService,
    required this.repository,
    required this.accountRepo,
    this.onShowNavigation,
    this.onHideNavigation,
  });

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with SingleTickerProviderStateMixin {
  late DateTime _selectedMonth;
  final _monthFormat = DateFormat.yMMMM();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _navAnimationController;
  late ScrollAwareButtonController _navController;
  List<DateTime>? _cachedAvailableMonths;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

    // Initialize animation controller for nav bar hide/show
    _navAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    // Initialize scroll-aware controller
    _navController = ScrollAwareButtonController(
      animationController: _navAnimationController,
      minScrollOffset: 100.0,
      scrollThreshold: 10.0,
      onShow: _showNavigation,
      onHide: _hideNavigation,
    );

    // Add scroll listener
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      _navController.handleScroll(_scrollController.position);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _navAnimationController.dispose();
    super.dispose();
  }

  List<Expense> _filteredExpenses(List<Expense> expenses) {
    return expenses
        .where((expense) =>
            expense.date.year == _selectedMonth.year &&
            expense.date.month == _selectedMonth.month)
        .toList();
  }

  /// Get available months from expenses, with caching
  List<DateTime> _getAvailableMonths(List<Expense> expenses) {
    if (_cachedAvailableMonths != null) {
      return _cachedAvailableMonths!;
    }

    final months = expenses
        .map((e) => DateTime(e.date.year, e.date.month))
        .toSet()
        .toList();
    months.sort((a, b) => b.compareTo(a)); // Most recent first

    _cachedAvailableMonths = months;
    return months;
  }

  void _showMonthPicker(List<Expense> expenses) async {
    final availableMonths = _getAvailableMonths(expenses);

    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return MonthPickerDialog(
          selectedMonth: _selectedMonth,
          availableMonths: availableMonths,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = picked;
      });
    }
  }

  void _showNavigation() {
    widget.onShowNavigation?.call();
  }

  void _hideNavigation() {
    widget.onHideNavigation?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ExpenseStateManager>(
      builder: (context, expenseStateManager, child) {
        final expenses = expenseStateManager.allExpenses ?? [];
        final isLoading = expenseStateManager.isLoadingAll;

        // Invalidate cache when expenses change
        if (_cachedAvailableMonths != null && expenses.isNotEmpty) {
          final currentMonths = expenses
              .map((e) => DateTime(e.date.year, e.date.month))
              .toSet()
              .toList();
          currentMonths.sort((a, b) => b.compareTo(a));

          // Only invalidate if months actually changed
          if (_cachedAvailableMonths!.length != currentMonths.length ||
              !_cachedAvailableMonths!.every((m) => currentMonths
                  .any((cm) => cm.year == m.year && cm.month == m.month))) {
            _cachedAvailableMonths = null;
          }
        }

        // Show loading state
        if (isLoading && expenses.isEmpty) {
          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: KiwiAppBar(
              titleWidget: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: theme.colorScheme.surface,
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 10,
                    top: 12,
                    bottom: 12,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _monthFormat.format(_selectedMonth),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ),
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: Icon(
                    AppIcons.more,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsScreen(
                          categoryRepo: widget.categoryRepo,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: KiwiAppBar(
            titleWidget: TextButton(
              onPressed: () => _showMonthPicker(expenses),
              style: TextButton.styleFrom(
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.surface,
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 10,
                  top: 12,
                  bottom: 12,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _monthFormat.format(_selectedMonth),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: Icon(
                  AppIcons.more,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(
                        categoryRepo: widget.categoryRepo,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Wrap expensive widgets in RepaintBoundary for better performance
                RepaintBoundary(
                  child: ExpenseSummary(
                    expenses: expenses,
                    selectedMonth: _selectedMonth,
                    onMonthSelected: (month) {
                      setState(() {
                        _selectedMonth = month;
                      });
                    },
                    analyticsService: widget.analyticsService,
                    repository: widget.repository,
                    categoryRepo: widget.categoryRepo,
                    accountRepo: widget.accountRepo,
                    showChart: true,
                    showMonthlyChart: expenses.isNotEmpty,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Text(
                    'Spending by Category',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                // Wrap expensive widgets in RepaintBoundary for better performance
                RepaintBoundary(
                  child: CategoryStatistics(
                    expenses: _filteredExpenses(expenses),
                    categoryRepo: widget.categoryRepo,
                    analyticsService: widget.analyticsService,
                    selectedMonth: _selectedMonth,
                    accountRepo: widget.accountRepo,
                    repository: widget.repository,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MonthPickerDialog extends StatelessWidget {
  final DateTime selectedMonth;
  final List<DateTime> availableMonths;

  const MonthPickerDialog({
    super.key,
    required this.selectedMonth,
    required this.availableMonths,
  });

  @override
  Widget build(BuildContext context) {
    final monthFormat = DateFormat.yMMMM();
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Month',
                    style: theme.textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: availableMonths.length,
                itemBuilder: (context, index) {
                  final month = availableMonths[index];
                  final isSelected = month.year == selectedMonth.year &&
                      month.month == selectedMonth.month;

                  return ListTile(
                    title: Text(monthFormat.format(month)),
                    selected: isSelected,
                    onTap: () => Navigator.pop(context, month),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
