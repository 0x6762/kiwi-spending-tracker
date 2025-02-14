import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../repositories/category_repository.dart';
import '../widgets/expense_list.dart';

class AllExpensesScreen extends StatelessWidget {
  final List<Expense> expenses;
  final CategoryRepository categoryRepo;
  final void Function(Expense) onDelete;
  final void Function(Expense) onTap;

  const AllExpensesScreen({
    super.key,
    required this.expenses,
    required this.categoryRepo,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'All Expenses',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: Card(
        margin: const EdgeInsets.all(8),
        color: theme.colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 0,
        child: ExpenseList(
          expenses: expenses,
          categoryRepo: categoryRepo,
          onTap: onTap,
          onDelete: onDelete,
        ),
      ),
    );
  }
} 