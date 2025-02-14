import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../repositories/category_repository.dart';
import '../widgets/expense_list.dart';
import '../widgets/app_bar.dart';

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

  Map<DateTime, List<Expense>> _groupExpensesByDate() {
    final groupedExpenses = <DateTime, List<Expense>>{};
    final sortedExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (var expense in sortedExpenses) {
      final date = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      if (!groupedExpenses.containsKey(date)) {
        groupedExpenses[date] = [];
      }
      groupedExpenses[date]!.add(expense);
    }

    return groupedExpenses;
  }

  String _formatSectionTitle(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    
    if (date.year == now.year && 
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupedExpenses = _groupExpensesByDate();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: KiwiAppBar(
        title: 'All Expenses',
        leading: const Icon(Icons.arrow_back),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: groupedExpenses.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Text(
                    _formatSectionTitle(entry.key),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.zero,
                  color: theme.colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                  child: ExpenseList(
                    expenses: entry.value,
                    categoryRepo: categoryRepo,
                    onTap: onTap,
                    onDelete: onDelete,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
} 