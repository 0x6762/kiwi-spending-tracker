import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/account.dart';
import '../utils/formatters.dart';
import '../repositories/category_repository.dart';

class ExpenseList extends StatefulWidget {
  final List<Expense> expenses;
  final CategoryRepository categoryRepo;
  final void Function(Expense expense)? onTap;
  final void Function(Expense expense)? onDelete;
  final ScrollController? scrollController;
  final bool shrinkWrap;

  const ExpenseList({
    super.key,
    required this.expenses,
    required this.categoryRepo,
    this.onTap,
    this.onDelete,
    this.scrollController,
    this.shrinkWrap = false,
  });

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  final _dateFormat = DateFormat.yMMMd();

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final expenseDate = DateTime(date.year, date.month, date.day);

    if (expenseDate == today) {
      return 'Today';
    } else if (expenseDate == yesterday) {
      return 'Yesterday';
    } else {
      return _dateFormat.format(date);
    }
  }

  List<Expense> get _sortedExpenses {
    return [...widget.expenses]..sort((a, b) {
        // First compare by date
        final dateComparison = b.date.compareTo(a.date);
        if (dateComparison != 0) {
          return dateComparison;
        }
        // If same date, compare by creation time
        return b.createdAt.compareTo(a.createdAt);
      });
  }

  Widget _buildExpenseItem(BuildContext context, Expense expense) {
    return FutureBuilder<ExpenseCategory?>(
      future: widget.categoryRepo.findCategoryById(expense.categoryId ?? CategoryRepository.uncategorizedId),
      builder: (context, snapshot) {
        final category = snapshot.data;
        final account = DefaultAccounts.defaultAccounts
            .firstWhere(
              (a) => a.id == expense.accountId,
              orElse: () => DefaultAccounts.checking,
            );

        final theme = Theme.of(context);
        final typeIcon = _getExpenseTypeIcon(expense.type);
        final typeColor = _getExpenseTypeColor(expense.type);

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
            return await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Expense'),
                    content:
                        const Text('Are you sure you want to delete this expense?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ) ??
                false;
          },
          onDismissed: (_) {
            if (widget.onDelete != null) {
              widget.onDelete!(expense);
            }
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap != null ? () => widget.onTap!(expense) : null,
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
                      category?.icon ?? Icons.category_outlined,
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
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    typeIcon,
                                    size: 16,
                                    color: typeColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getExpenseTypeLabel(expense.type),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: typeColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(expense.date),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    formatCurrency(expense.amount),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getExpenseTypeIcon(ExpenseType type) {
    switch (type) {
      case ExpenseType.subscription:
        return Icons.subscriptions_outlined;
      case ExpenseType.fixed:
        return Icons.calendar_month_outlined;
      case ExpenseType.variable:
        return Icons.shopping_bag_outlined;
    }
  }

  Color _getExpenseTypeColor(ExpenseType type) {
    switch (type) {
      case ExpenseType.subscription:
        return const Color(0xFF2196F3); // Blue
      case ExpenseType.fixed:
        return const Color(0xFFCF5825); // Orange
      case ExpenseType.variable:
        return const Color(0xFF8056E4); // Purple
    }
  }

  String _getExpenseTypeLabel(ExpenseType type) {
    switch (type) {
      case ExpenseType.subscription:
        return 'Sub';
      case ExpenseType.fixed:
        return 'Fixed';
      case ExpenseType.variable:
        return 'Var';
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenses = _sortedExpenses;

    if (expenses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text('No expenses yet'),
        ),
      );
    }

    return ListView.builder(
      controller: widget.scrollController,
      shrinkWrap: true, // This ensures the list takes only the space it needs
      physics: const NeverScrollableScrollPhysics(), // Disable scrolling within the list
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return _buildExpenseItem(context, expense);
      },
    );
  }
}
