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
import '../widgets/expense/upcoming_expenses_card.dart';
import 'expense_detail_screen.dart';
import 'upcoming_expenses_screen.dart';
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
  UpcomingExpensesSummary? _upcomingSummary;

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
      final upcomingService =
          Provider.of<UpcomingExpenseService>(context, listen: false);
      final upcomingItems = await upcomingService.getUpcomingExpenses(
        daysAhead: 30, // Show upcoming expenses for next 30 days
        includeRecurringTemplates: true,
        includeManualExpenses: true,
        includeGeneratedInstances: true,
      );
      // Get summary for the card
      final summary = await upcomingService.getUpcomingExpensesSummary(
        daysAhead: 30,
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
          _upcomingSummary = summary;
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
              final expenseStateManager =
                  Provider.of<ExpenseStateManager>(context, listen: false);
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
        final expenseStateManager =
            Provider.of<ExpenseStateManager>(context, listen: false);
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
      final expenseStateManager =
          Provider.of<ExpenseStateManager>(context, listen: false);
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
    // Separate upcoming expenses from regular expenses

    // Separate upcoming expenses from regular expenses
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcomingExpensesList = <Expense>[];
    final regularExpensesList = <Expense>[];

    // Add regular expenses (past and today)
    for (var expense in expenses) {
      final date = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      if (date.isAfter(today)) {
        upcomingExpensesList.add(expense);
      } else {
        regularExpensesList.add(expense);
      }
    }

    // Add upcoming expenses that aren't already in the list
    // Note: Recurring templates might have the same ID as the template in regular expenses,
    // but we want to show them in upcoming with their nextBillingDate
    for (var upcoming in _upcomingExpenses) {
      // Check if this is a recurring template (has isRecurring flag)
      // If it is, we should add it even if ID matches, because it represents the future occurrence
      final isRecurringTemplate = upcoming.isRecurring == true;

      final upcomingDate = DateTime(
        upcoming.date.year,
        upcoming.date.month,
        upcoming.date.day,
      );

      // Only add if it's actually in the future
      if (upcomingDate.isAfter(today)) {
        // Check if already in upcoming list (by ID)
        final alreadyInUpcoming =
            upcomingExpensesList.any((e) => e.id == upcoming.id);

        if (!alreadyInUpcoming || isRecurringTemplate) {
          // For recurring templates, remove the template from upcoming if it exists
          if (isRecurringTemplate && alreadyInUpcoming) {
            upcomingExpensesList.removeWhere(
                (e) => e.id == upcoming.id && e.isRecurring == true);
          }
          upcomingExpensesList.add(upcoming);
        }
      }
    }

    // Use cache if expenses haven't changed
    if (_cachedGroupedExpenses != null &&
        _lastExpensesForGrouping == expenses &&
        _lastUpcomingExpensesForGrouping == _upcomingExpenses) {
      return _cachedGroupedExpenses!;
    }

    final groupedExpenses = <DateTime, List<Expense>>{};

    // Special key for upcoming expenses
    final upcomingKey = DateTime(9999, 12, 31);

    // Sort upcoming expenses by date (earliest first) - all types together
    upcomingExpensesList.sort((a, b) => a.date.compareTo(b.date));
    if (upcomingExpensesList.isNotEmpty) {
      groupedExpenses[upcomingKey] = upcomingExpensesList;
    }

    // Sort regular expenses by date (newest first)
    regularExpensesList.sort((a, b) => b.date.compareTo(a.date));
    for (var expense in regularExpensesList) {
      final date = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      groupedExpenses[date] ??= [];
      groupedExpenses[date]!.add(expense);
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
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) =>
          MultiStepExpenseScreen(
        categoryRepo: widget.categoryRepo,
        accountRepo: widget.accountRepo,
        onExpenseAdded: (expense) async {
          try {
            final expenseStateManager =
                Provider.of<ExpenseStateManager>(context, listen: false);
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
                final upcomingKey = DateTime(9999, 12, 31);
                final hasUpcoming = groupedExpenses.containsKey(upcomingKey);

                // Sort the entries to ensure upcoming is first, then by date descending
                final sortedEntries = groupedExpenses.entries.toList()
                  ..sort((a, b) {
                    if (a.key == upcomingKey) return -1;
                    if (b.key == upcomingKey) return 1;
                    return b.key.compareTo(a.key);
                  });

                // Calculate item count: upcoming card (if exists) + regular entries + load more
                final regularEntriesCount =
                    sortedEntries.where((e) => e.key != upcomingKey).length;
                final itemCount =
                    (hasUpcoming && _upcomingSummary != null ? 1 : 0) +
                        regularEntriesCount +
                        (provider.hasMore ? 1 : 0);

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    // Show upcoming card first if available
                    if (hasUpcoming && _upcomingSummary != null && index == 0) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
                        child: UpcomingExpensesCard(
                          summary: _upcomingSummary!,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpcomingExpensesScreen(
                                  repository: widget.repository,
                                  categoryRepo: widget.categoryRepo,
                                  accountRepo: widget.accountRepo,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }

                    // Adjust index if we showed the upcoming card
                    final adjustedIndex =
                        (hasUpcoming && _upcomingSummary != null)
                            ? index - 1
                            : index;

                    // Load more indicator
                    if (adjustedIndex >= regularEntriesCount) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: provider.isLoadingMore
                            ? const Center(child: CircularProgressIndicator())
                            : const SizedBox.shrink(),
                      );
                    }

                    // Get regular entries (excluding upcoming)
                    final regularEntries = sortedEntries
                        .where((e) => e.key != upcomingKey)
                        .toList();
                    final entry = regularEntries[adjustedIndex];

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
