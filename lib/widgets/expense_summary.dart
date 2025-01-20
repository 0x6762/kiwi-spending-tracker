import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseSummary extends StatelessWidget {
  final List<Expense> expenses;

  const ExpenseSummary({
    super.key,
    required this.expenses,
  });

  double get totalExpenses => expenses.fold(
        0,
        (sum, expense) => sum + expense.amount,
      );

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Expenses',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '\$${totalExpenses.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
