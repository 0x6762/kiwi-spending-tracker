import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/account_repository.dart';
import '../providers/expense_state_manager.dart';
import '../widgets/common/app_bar.dart';
import '../widgets/dialogs/delete_confirmation_dialog.dart';
import '../utils/formatters.dart';
import '../utils/icons.dart';
import 'expense_detail_screen.dart';

class CategoryExpensesScreen extends StatefulWidget {
  final ExpenseRepository? repository; // Optional, for backward compatibility
  final CategoryRepository categoryRepo;
  final AccountRepository accountRepo;
  final String categoryId;
  final DateTime selectedMonth;

  const CategoryExpensesScreen({
    super.key,
    this.repository,
    required this.categoryRepo,
    required this.accountRepo,
    required this.categoryId,
    required this.selectedMonth,
  });

  @override
  State<CategoryExpensesScreen> createState() => _CategoryExpensesScreenState();
}

class _CategoryExpensesScreenState extends State<CategoryExpensesScreen> {
  ExpenseCategory? _category;
  bool _isLoadingCategory = true;
  final _dateFormat = DateFormat.yMMMd();

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  Future<void> _loadCategory() async {
    final category = await widget.categoryRepo.findCategoryById(widget.categoryId);
    setState(() {
      _category = category;
      _isLoadingCategory = false;
    });
  }

  /// Filter expenses from ExpenseStateManager
  List<Expense> _getFilteredExpenses(List<Expense> allExpenses) {
    final now = DateTime.now();
    return allExpenses
        .where((expense) =>
            expense.date.year == widget.selectedMonth.year &&
            expense.date.month == widget.selectedMonth.month &&
            expense.categoryId == widget.categoryId &&
            expense.status != ExpenseStatus.cancelled &&
            expense.date.isBefore(now.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Calculate total amount from filtered expenses
  double _calculateTotal(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final expenseDate = DateTime(date.year, date.month, date.day);

    if (expenseDate == today) {
      return 'Today';
    } else if (expenseDate == yesterday) {
      return 'Yesterday';
    } else if (expenseDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return _dateFormat.format(date);
    }
  }

  Future<void> _deleteExpense(Expense expense, ExpenseStateManager expenseStateManager) async {
    try {
      await expenseStateManager.deleteExpense(expense.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete expense: ${e.toString()}')),
        );
      }
    }
  }

  void _viewExpenseDetails(Expense expense, ExpenseStateManager expenseStateManager) async {
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
                  SnackBar(content: Text('Failed to update expense: ${e.toString()}')),
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

  Widget _buildExpenseItem(
      BuildContext context, Expense expense, ExpenseStateManager expenseStateManager) {
    final theme = Theme.of(context);
    
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
        return await DeleteConfirmationDialog.show(context) ?? false;
      },
      onDismissed: (_) => _deleteExpense(expense, expenseStateManager),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _viewExpenseDetails(expense, expenseStateManager),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _category?.icon ?? Icons.category_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatDate(expense.date),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (expense.notes != null && expense.notes!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          expense.notes!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                formatCurrency(expense.amount),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySummary(double totalAmount) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      color: theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      elevation: 0,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Expenses',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                formatCurrency(totalAmount),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: KiwiAppBar(
        title: _category?.name ?? 'Category Expenses',
        leading: const Icon(AppIcons.back),
      ),
      body: _isLoadingCategory
          ? const Center(child: CircularProgressIndicator())
          : Consumer<ExpenseStateManager>(
              builder: (context, expenseStateManager, child) {
                final allExpenses = expenseStateManager.allExpenses ?? [];
                final isLoading = expenseStateManager.isLoadingAll && allExpenses.isEmpty;
                
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredExpenses = _getFilteredExpenses(allExpenses);
                final totalAmount = _calculateTotal(filteredExpenses);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCategorySummary(totalAmount),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Expenses',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: filteredExpenses.isEmpty
                            ? Center(
                                child: Text(
                                  'No expenses in this category for ${DateFormat.yMMMM().format(widget.selectedMonth)}',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  color: theme.colorScheme.surfaceContainer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  elevation: 0,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    itemCount: filteredExpenses.length,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return _buildExpenseItem(
                                        context,
                                        filteredExpenses[index],
                                        expenseStateManager,
                                      );
                                    },
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
} 