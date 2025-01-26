import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../utils/formatters.dart';
import 'package:intl/intl.dart';

class InsightsScreen extends StatelessWidget {
  final List<Expense> expenses;
  final DateTime selectedMonth;
  final _monthFormat = DateFormat.yMMMM();

  InsightsScreen({
    super.key,
    required this.expenses,
    required this.selectedMonth,
  });

  List<Expense> get _monthlyExpenses {
    return expenses
        .where((expense) =>
            expense.date.year == selectedMonth.year &&
            expense.date.month == selectedMonth.month)
        .toList();
  }

  Map<String, double> _getCategoryTotals() {
    final Map<String, double> totals = {};
    final monthExpenses = _monthlyExpenses;
    final double totalSpent =
        monthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

    // First calculate raw totals
    for (final expense in monthExpenses) {
      if (expense.category != null) {
        totals[expense.category!] =
            (totals[expense.category!] ?? 0.0) + expense.amount;
      } else {
        totals['Uncategorized'] =
            (totals['Uncategorized'] ?? 0.0) + expense.amount;
      }
    }

    // Convert to percentages
    if (totalSpent > 0) {
      totals.forEach((category, amount) {
        totals[category] = (amount / totalSpent) * 100;
      });
    }

    // Sort by percentage (descending)
    final sortedEntries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  Widget _buildCategoryRow(
      BuildContext context, String category, double percentage, double amount) {
    final theme = Theme.of(context);
    final categoryInfo = category == 'Uncategorized'
        ? null
        : ExpenseCategories.findByName(category);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              categoryInfo?.icon ?? Icons.category_outlined,
              size: 24,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(amount),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryTotals = _getCategoryTotals();
    final monthlyTotal =
        _monthlyExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              title: Text(_monthFormat.format(selectedMonth)),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Spent',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatCurrency(monthlyTotal),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Spending by Category',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: categoryTotals.entries.map((entry) {
                          final amount = _monthlyExpenses
                              .where((e) =>
                                  e.category == entry.key ||
                                  (entry.key == 'Uncategorized' &&
                                      e.category == null))
                              .fold(0.0, (sum, e) => sum + e.amount);
                          return _buildCategoryRow(
                            context,
                            entry.key,
                            entry.value,
                            amount,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
