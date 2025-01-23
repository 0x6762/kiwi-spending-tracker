import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/account.dart';

class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final void Function(Expense expense)? onTap;
  final void Function(Expense expense)? onDelete;
  final ScrollController? scrollController;
  final bool shrinkWrap;
  final _dateFormat = DateFormat.yMMMd();

  ExpenseList({
    super.key,
    required this.expenses,
    this.onTap,
    this.onDelete,
    this.scrollController,
    this.shrinkWrap = false,
  });

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
    return [...expenses]..sort((a, b) {
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
    final category = expense.category != null
        ? ExpenseCategories.findByName(expense.category!)
        : null;
    final account = DefaultAccounts.defaultAccounts
        .firstWhere((a) => a.id == expense.accountId);

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.surfaceContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.error,
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
      onDismissed: (direction) {
        if (onDelete != null) {
          onDelete!(expense);
        }
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context)
              .colorScheme
              .surfaceContainer, //List item icon background color
          child: Icon(
            category?.icon ?? Icons.receipt_long,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant, //List item icon color
          ),
        ),
        title: Text(expense.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                )),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: account.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: account.color.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      account.icon,
                      size: 12,
                      color: account.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      account.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: account.color,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${expense.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDate(expense.date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        onTap: onTap != null ? () => onTap!(expense) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedExpenses = _sortedExpenses;

    return Column(
      children: sortedExpenses
          .map((expense) => _buildExpenseItem(context, expense))
          .toList(),
    );
  }
}
