import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';

class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final void Function(Expense expense)? onTap;

  ExpenseList({
    super.key,
    required this.expenses,
    this.onTap,
  });

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

  @override
  Widget build(BuildContext context) {
    final sortedExpenses = _sortedExpenses;

    return ListView.builder(
      itemCount: sortedExpenses.length,
      itemBuilder: (context, index) {
        final expense = sortedExpenses[index];
        final category = expense.category != null
            ? ExpenseCategories.findByName(expense.category!)
            : null;

        return ListTile(
          leading: CircleAvatar(
            child: Icon(category?.icon ?? Icons.receipt_long),
          ),
          title: Text(expense.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_formatDate(expense.date)),
              if (category != null)
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          trailing: Text(
            '\$${expense.amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          onTap: onTap != null ? () => onTap!(expense) : null,
        );
      },
    );
  }
}
