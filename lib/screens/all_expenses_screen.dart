import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_list_provider.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/account_repository.dart';
import '../widgets/expense/expense_list.dart';
import '../widgets/common/app_bar.dart';
import '../utils/formatters.dart';
import '../utils/scroll_aware_button_controller.dart';
import '../providers/expense_state_manager.dart';
import '../services/upcoming_expense_service.dart';
import 'expense_detail_screen.dart';
import 'multi_step_expense/multi_step_expense_screen.dart';

class AllExpensesScreen extends StatefulWidget {
  final ExpenseRepository repository;
  final CategoryRepository categoryRepo;
  final AccountRepository accountRepo;

  const AllExpensesScreen({
    super.key,
    required this.repository,
    required this.categoryRepo,
    required this.accountRepo,
  });

  @override
  State<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends State<AllExpensesScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late ExpenseListProvider _provider;
  late AnimationController _buttonAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late ScrollAwareButtonController _buttonController;
  Map<DateTime, List<Expense>>? _cachedGroupedExpenses;
  List<Expense>? _lastExpensesForGrouping;
  List<Expense>? _lastUpcomingExpensesForGrouping;
  List<Expense> _upcomingExpenses = [];

  static const Duration _animationDuration = Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _buttonAnimationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    // Initialize animations (same as nav bar)
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Initialize scroll controller and button controller
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _buttonController = ScrollAwareButtonController(
      animationController: _buttonAnimationController,
      minScrollOffset: 100.0,
      scrollThreshold: 10.0,
    );

    _provider = ExpenseListProvider(widget.repository);
    _provider.loadExpenses();
    _loadUpcomingExpenses();
  }

  Future<void> _loadUpcomingExpenses() async {
    try {
      final upcomingService = Provider.of<UpcomingExpenseService>(context, listen: false);
      final upcomingItems = await upcomingService.getUpcomingExpenses(
        daysAhead: 90, // Show upcoming expenses for next 90 days
        includeRecurringTemplates: true,
        includeManualExpenses: true,
        includeGeneratedInstances: true,
      );
      // Convert UpcomingExpenseItem to Expense, using effectiveDate
      if (mounted) {
        setState(() {
          _upcomingExpenses = upcomingItems.map((item) {
            // For recurring templates, create a temporary expense with the next occurrence date
            if (item.isRecurringTemplate && item.nextOccurrenceDate != null) {
              return item.expense.copyWith(date: item.nextOccurrenceDate!);
            }
            return item.expense;
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading upcoming expenses: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _buttonAnimationController.dispose();
    _provider.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Handle pagination
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _provider.loadMore();
    }

    // Handle button visibility
    if (_scrollController.hasClients) {
      _buttonController.handleScroll(_scrollController.position);
    }
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
            try {
              final expenseStateManager = Provider.of<ExpenseStateManager>(context, listen: false);
              // Save via ExpenseStateManager (single source of truth)
              await expenseStateManager.updateExpense(updatedExpense);
              // Update local provider list
              _provider.updateExpenseInList(updatedExpense);
              // Reload upcoming expenses
              _loadUpcomingExpenses();
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update expense: $e')),
                );
              }
            }
          },
        ),
      ),
    );

    if (result == true) {
      try {
        final expenseStateManager = Provider.of<ExpenseStateManager>(context, listen: false);
        // Save via ExpenseStateManager (single source of truth)
        await expenseStateManager.deleteExpense(expense.id);
        // Update local provider list without saving again
        _provider.removeExpenseFromList(expense.id);
        // Reload upcoming expenses
        _loadUpcomingExpenses();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete expense: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleDelete(Expense expense) async {
    try {
      final expenseStateManager = Provider.of<ExpenseStateManager>(context, listen: false);
      // Save via ExpenseStateManager (single source of truth)
      await expenseStateManager.deleteExpense(expense.id);
      // Update local provider list without saving again
      _provider.removeExpenseFromList(expense.id);
      // Reload upcoming expenses
      _loadUpcomingExpenses();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete expense: $e')),
        );
      }
    }
  }

  Map<DateTime, List<Expense>> _groupExpensesByDate(List<Expense> expenses) {
    // Merge with upcoming expenses, avoiding duplicates
    final allExpenses = <Expense>[];
    final existingIds = expenses.map((e) => e.id).toSet();
    
    // Add regular expenses
    allExpenses.addAll(expenses);
    
    // Add upcoming expenses that aren't already in the list
    // Note: Recurring templates might have the same ID as the template in regular expenses,
    // but we want to show them in upcoming with their nextBillingDate
    for (var upcoming in _upcomingExpenses) {
      // Check if this is a recurring template (has isRecurring flag)
      // If it is, we should add it even if ID matches, because it represents the future occurrence
      final isRecurringTemplate = upcoming.isRecurring == true && 
                                   upcoming.type == ExpenseType.subscription;
      
      if (!existingIds.contains(upcoming.id) || isRecurringTemplate) {
        // For recurring templates, we want to show them in upcoming even if template exists
        // Remove the template from regular expenses if it's a recurring template
        if (isRecurringTemplate && existingIds.contains(upcoming.id)) {
          allExpenses.removeWhere((e) => e.id == upcoming.id && e.isRecurring == true);
        }
        allExpenses.add(upcoming);
      }
    }

    // Use cache if expenses haven't changed
    if (_cachedGroupedExpenses != null && 
        _lastExpensesForGrouping == expenses && 
        _lastUpcomingExpensesForGrouping == _upcomingExpenses) {
      return _cachedGroupedExpenses!;
    }

    final groupedExpenses = <DateTime, List<Expense>>{};
    final sortedExpenses = List<Expense>.from(allExpenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Special key for upcoming expenses
    final upcomingKey = DateTime(9999, 12, 31);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var expense in sortedExpenses) {
      final date = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );

      if (date.isAfter(today)) {
        groupedExpenses[upcomingKey] ??= [];
        groupedExpenses[upcomingKey]!.add(expense);
      } else {
        groupedExpenses[date] ??= [];
        groupedExpenses[date]!.add(expense);
      }
    }

    _cachedGroupedExpenses = groupedExpenses;
    _lastExpensesForGrouping = expenses;
    _lastUpcomingExpensesForGrouping = List.from(_upcomingExpenses);
    return groupedExpenses;
  }

  String _formatSectionTitle(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final specialUpcomingKey = DateTime(9999, 12, 31);

    if (date == specialUpcomingKey) {
      return 'Upcoming';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return DateFormat.MMMd().format(date);
    }
  }

  void _showAddExpenseDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel:
          MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) =>
          MultiStepExpenseScreen(
        type: ExpenseType.variable,
        categoryRepo: widget.categoryRepo,
        accountRepo: widget.accountRepo,
        onExpenseAdded: (expense) async {
          try {
            final expenseStateManager = Provider.of<ExpenseStateManager>(context, listen: false);
            // Save via ExpenseStateManager (single source of truth)
            await expenseStateManager.addExpense(expense);
            // Update local provider list without saving again
            _provider.addExpenseToList(expense);
            // Reload upcoming expenses
            _loadUpcomingExpenses();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to add expense: $e')),
              );
            }
          }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: KiwiAppBar(
          title: 'All Expenses',
          leading: const Icon(Icons.arrow_back),
        ),
        body: Stack(
          children: [
            // Main content
            Consumer<ExpenseListProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${provider.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.refresh(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.expenses.isEmpty) {
                  return const Center(
                    child: Text('No expenses found'),
                  );
                }

                final groupedExpenses = _groupExpensesByDate(provider.expenses);

                // Sort the entries to ensure upcoming is first, then by date descending
                final sortedEntries = groupedExpenses.entries.toList()
                  ..sort((a, b) {
                    if (a.key == DateTime(9999, 12, 31)) return -1;
                    if (b.key == DateTime(9999, 12, 31)) return 1;
                    return b.key.compareTo(a.key);
                  });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: sortedEntries.length + (provider.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Load more indicator
                    if (index == sortedEntries.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: provider.isLoadingMore
                            ? const Center(child: CircularProgressIndicator())
                            : const SizedBox.shrink(),
                      );
                    }

                    final entry = sortedEntries[index];
                    final dayTotal = entry.value.fold<double>(
                        0, (sum, expense) => sum + expense.amount);

                    return RepaintBoundary(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatSectionTitle(entry.key),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  'Total: ${formatCurrency(dayTotal)}',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ExpenseList(
                            expenses: entry.value,
                            categoryRepo: widget.categoryRepo,
                            onTap: _viewExpenseDetails,
                            onDelete: _handleDelete,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            // Add expense button - styled like nav bar button with animations
            Positioned(
              bottom: 24,
              right: 16,
              child: AnimatedBuilder(
                animation: _buttonAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: child,
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: 'add_expense_button',
                  child: GestureDetector(
                    onTap: _showAddExpenseDialog,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(56),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 25,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add_rounded,
                          size: 32,
                          color: theme.colorScheme.surfaceContainerLow,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
