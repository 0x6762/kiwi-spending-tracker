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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
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
              Text(_dateFormat.format(expense.date)),
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
