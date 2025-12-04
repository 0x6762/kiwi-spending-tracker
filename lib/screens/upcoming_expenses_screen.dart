import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/account_repository.dart';
import '../providers/expense_state_manager.dart';
import '../services/upcoming_expense_service.dart';
import '../services/recurring_expense_service.dart';
import '../widgets/common/app_bar.dart';
import '../widgets/dialogs/delete_confirmation_dialog.dart';
import '../utils/formatters.dart';
import 'expense_detail_screen.dart';

class UpcomingExpensesScreen extends StatefulWidget {
  final ExpenseRepository repository;
  final CategoryRepository categoryRepo;
  final AccountRepository accountRepo;

  const UpcomingExpensesScreen({
    super.key,
    required this.repository,
    required this.categoryRepo,
    required this.accountRepo,
  });

  @override
  State<UpcomingExpensesScreen> createState() => _UpcomingExpensesScreenState();
}

class _UpcomingExpensesScreenState extends State<UpcomingExpensesScreen> {
  late UpcomingExpenseService _upcomingExpenseService;
  final _dateFormat = DateFormat.yMMMd();
  List<UpcomingExpenseItem> _upcomingExpenses = [];
  UpcomingExpensesSummary? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final expenseStateManager =
        Provider.of<ExpenseStateManager>(context, listen: false);
    final recurringService = RecurringExpenseService(
      widget.repository,
      expenseStateManager,
    );
    _upcomingExpenseService = UpcomingExpenseService(
      widget.repository,
      recurringService,
      expenseStateManager,
    );
    _loadUpcomingExpenses();
  }

  Future<void> _loadUpcomingExpenses() async {
    setState(() => _isLoading = true);
    try {
      final items = await _upcomingExpenseService.getUpcomingExpenses(
        daysAhead: 30,
        includeRecurringTemplates: true,
        includeManualExpenses: true,
        includeGeneratedInstances: true,
      );
      final summary = await _upcomingExpenseService.getUpcomingExpensesSummary(
        daysAhead: 30,
      );
      if (mounted) {
        setState(() {
          _upcomingExpenses = items;
          _summary = summary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load upcoming expenses: $e')),
        );
      }
    }
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

  Future<void> _deleteExpense(
      Expense expense, ExpenseStateManager expenseStateManager) async {
    try {
      await expenseStateManager.deleteExpense(expense.id);
      _loadUpcomingExpenses();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete expense: ${e.toString()}')),
        );
      }
    }
  }

  void _viewExpenseDetails(
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
              _loadUpcomingExpenses();
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Failed to update expense: ${e.toString()}')),
                );
              }
            }
          },
        ),
        maintainState: true,
      ),
    );

    if (result == true) {
      await _deleteExpense(expense, expenseStateManager);
    }
  }

  Widget _buildUpcomingExpenseItem(
    BuildContext context,
    UpcomingExpenseItem item,
    ExpenseCategory? category,
    ExpenseStateManager expenseStateManager,
  ) {
    final theme = Theme.of(context);
    final expense = item.expense;
    final displayDate = item.effectiveDate;

    return Dismissible(
      key: Key(expense.id),
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
              title: 'Delete Expense',
              message: 'Are you sure you want to delete this expense?',
            ) ??
            false;
      },
      onDismissed: (_) => _deleteExpense(expense, expenseStateManager),
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
                expense.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            item.isRecurringTemplate
                ? 'Next payment: ${_formatDate(displayDate)}'
                : 'Due: ${_formatDate(displayDate)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        trailing: Text(
          formatCurrency(expense.amount),
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        onTap: () => _viewExpenseDetails(expense, expenseStateManager),
      ),
    );
  }

  Widget _buildUpcomingExpensesSummary(UpcomingExpensesSummary summary) {
    final theme = Theme.of(context);

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
              'Total Upcoming Amount',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatCurrency(summary.totalAmount),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${summary.totalCount} ${summary.totalCount == 1 ? 'expense' : 'expenses'}',
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
      List<UpcomingExpenseItem> items) async {
    final Map<String, ExpenseCategory?> categoriesMap = {};

    // Get unique category IDs
    final categoryIds = items
        .map((item) =>
            item.expense.categoryId ?? CategoryRepository.uncategorizedId)
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
        title: 'Upcoming Expenses',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<ExpenseStateManager>(
              builder: (context, expenseStateManager, child) {
                if (_upcomingExpenses.isEmpty) {
                  return Center(
                    child: Text(
                      'No upcoming expenses found',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await expenseStateManager.refreshAll();
                    _loadUpcomingExpenses();
                  },
                  color: theme.colorScheme.primary,
                  child: FutureBuilder<Map<String, ExpenseCategory?>>(
                    future: _loadCategoriesBatch(_upcomingExpenses),
                    builder: (context, categorySnapshot) {
                      final categoriesMap = categorySnapshot.data ?? {};

                      return SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_summary != null)
                              _buildUpcomingExpensesSummary(_summary!),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Upcoming Expenses',
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                itemCount: _upcomingExpenses.length,
                                itemBuilder: (context, index) {
                                  final item = _upcomingExpenses[index];
                                  final categoryId = item.expense.categoryId ??
                                      CategoryRepository.uncategorizedId;
                                  final category = categoriesMap[categoryId];
                                  return _buildUpcomingExpenseItem(
                                    context,
                                    item,
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
