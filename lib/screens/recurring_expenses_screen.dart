import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/account_repository.dart';
import '../providers/expense_state_manager.dart';
import '../services/recurring_expense_service.dart';
import '../widgets/common/app_bar.dart';
import '../widgets/dialogs/delete_confirmation_dialog.dart';
import '../utils/formatters.dart';
import 'expense_detail_screen.dart';

class RecurringExpensesScreen extends StatefulWidget {
  final ExpenseRepository
      repository; // Required for RecurringExpenseService initialization
  final CategoryRepository categoryRepo;
  final AccountRepository accountRepo;
  final DateTime selectedMonth;

  const RecurringExpensesScreen({
    super.key,
    required this.repository,
    required this.categoryRepo,
    required this.accountRepo,
    required this.selectedMonth,
  });

  @override
  State<RecurringExpensesScreen> createState() =>
      _RecurringExpensesScreenState();
}

class _RecurringExpensesScreenState extends State<RecurringExpensesScreen> {
  late RecurringExpenseService _recurringExpenseService;
  final _dateFormat = DateFormat.yMMMd();

  @override
  void initState() {
    super.initState();
    // RecurringExpenseService constructor requires repository, but the methods we use
    // (getRecurringExpensesFromExpenses, etc.) don't actually use the repository
    // They just process the expenses list from ExpenseStateManager
    _recurringExpenseService = RecurringExpenseService(
      widget.repository,
      null, // No ExpenseStateManager needed for read-only methods
    );
  }

  /// Get recurring expenses from ExpenseStateManager expenses
  List<RecurringExpenseData> _getRecurringExpenses(List<Expense> expenses) {
    return _recurringExpenseService.getRecurringExpensesFromExpenses(expenses);
  }

  /// Get recurring expense summary from ExpenseStateManager expenses
  RecurringExpenseSummary _getRecurringExpenseSummary(List<Expense> expenses) {
    return _recurringExpenseService
        .getRecurringExpenseSummaryForMonthFromExpenses(
            expenses, widget.selectedMonth);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final expenseDate = DateTime(date.year, date.month, date.day);

    if (expenseDate == today) {
      return 'Today';
    } else if (expenseDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return _dateFormat.format(date);
    }
  }

  Future<void> _deleteRecurringExpense(
      Expense expense, ExpenseStateManager expenseStateManager) async {
    try {
      await expenseStateManager.deleteExpense(expense.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to delete recurring expense: ${e.toString()}')),
        );
      }
    }
  }

  void _viewRecurringExpenseDetails(
      Expense expense, ExpenseStateManager expenseStateManager) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailScreen(
          expense: expense,
          categoryRepo: widget.categoryRepo,
          accountRepo: widget.accountRepo,
          onExpenseUpdated: (updatedExpense) async {
            try {
              await expenseStateManager.updateExpense(updatedExpense);
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Failed to update recurring expense: ${e.toString()}')),
                );
              }
            }
          },
        ),
        maintainState: true,
      ),
    );

    if (result == true) {
      await _deleteRecurringExpense(expense, expenseStateManager);
    }
  }

  Widget _buildRecurringExpenseItem(
      BuildContext context,
      RecurringExpenseData recurringExpense,
      ExpenseCategory? category,
      ExpenseStateManager expenseStateManager) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(recurringExpense.expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: theme.colorScheme.surfaceContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(
          Icons.delete,
          color: theme.colorScheme.error,
        ),
      ),
      confirmDismiss: (direction) async {
        return await DeleteConfirmationDialog.show(
              context,
              title: 'Delete Recurring Expense',
              message:
                  'Are you sure you want to delete this recurring expense?',
            ) ??
            false;
      },
      onDismissed: (_) => _deleteRecurringExpense(
          recurringExpense.expense, expenseStateManager),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            category?.icon ?? Icons.category_outlined,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                recurringExpense.expense.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    recurringExpense.nextBillingDate != null
                        ? 'Next payment: ${_formatDate(recurringExpense.nextBillingDate!)}'
                        : 'Paid on: ${_formatDate(recurringExpense.expense.date)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  recurringExpense.billingCycle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          formatCurrency(recurringExpense.expense.amount),
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        onTap: () => _viewRecurringExpenseDetails(
            recurringExpense.expense, expenseStateManager),
      ),
    );
  }

  Widget _buildRecurringExpenseSummary(RecurringExpenseSummary summary) {
    final theme = Theme.of(context);

    final totalMonthlyAmount = summary.totalMonthlyAmount;

    return Card(
      margin: const EdgeInsets.fromLTRB(8, 16, 8, 16),
      color: theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Monthly Cost',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatCurrency(totalMonthlyAmount),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${summary.totalRecurringExpenses} active recurring expenses',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Batch load all categories at once to avoid N+1 queries
  Future<Map<String, ExpenseCategory?>> _loadCategoriesBatch(
      List<RecurringExpenseData> recurringExpenses) async {
    final Map<String, ExpenseCategory?> categoriesMap = {};

    // Get unique category IDs
    final categoryIds = recurringExpenses
        .map(
            (re) => re.expense.categoryId ?? CategoryRepository.uncategorizedId)
        .toSet()
        .toList();

    // Load all categories in parallel
    final futures = categoryIds.map((id) async {
      final category = await widget.categoryRepo.findCategoryById(id);
      return MapEntry(id, category);
    });

    final results = await Future.wait(futures);
    for (final entry in results) {
      categoriesMap[entry.key] = entry.value;
    }

    return categoriesMap;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: KiwiAppBar(
        backgroundColor: theme.colorScheme.surface,
        title: 'Recurring Expenses',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ExpenseStateManager>(
        builder: (context, expenseStateManager, child) {
          final allExpenses = expenseStateManager.allExpenses ?? [];
          final isLoading =
              expenseStateManager.isLoadingAll && allExpenses.isEmpty;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final recurringExpenses = _getRecurringExpenses(allExpenses);
          final summary = _getRecurringExpenseSummary(allExpenses);

          if (recurringExpenses.isEmpty) {
            return Center(
              child: Text(
                'No recurring expenses found',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => expenseStateManager.refreshAll(),
            color: theme.colorScheme.primary,
            child: FutureBuilder<Map<String, ExpenseCategory?>>(
              future: _loadCategoriesBatch(recurringExpenses),
              builder: (context, categorySnapshot) {
                final categoriesMap = categorySnapshot.data ?? {};

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildRecurringExpenseSummary(summary),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Recurring Expenses',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: theme.colorScheme.surfaceContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: recurringExpenses.length,
                          itemBuilder: (context, index) {
                            final recurringExpense = recurringExpenses[index];
                            final categoryId =
                                recurringExpense.expense.categoryId ??
                                    CategoryRepository.uncategorizedId;
                            final category = categoriesMap[categoryId];
                            return _buildRecurringExpenseItem(
                              context,
                              recurringExpense,
                              category,
                              expenseStateManager,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
