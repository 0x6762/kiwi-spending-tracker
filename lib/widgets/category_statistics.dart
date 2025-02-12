import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../repositories/category_repository.dart';
import '../utils/formatters.dart';

class CategoryStatistics extends StatelessWidget {
  final List<Expense> expenses;
  final CategoryRepository categoryRepo;

  const CategoryStatistics({
    super.key,
    required this.expenses,
    required this.categoryRepo,
  });

  Map<String, double> _getCategoryTotals() {
    final Map<String, double> totals = {};
    final double totalSpent =
        expenses.fold(0.0, (sum, expense) => sum + expense.amount);

    // First calculate raw totals
    for (final expense in expenses) {
      if (expense.categoryId != null) {
        totals[expense.categoryId!] =
            (totals[expense.categoryId!] ?? 0.0) + expense.amount;
      } else {
        totals['uncategorized'] =
            (totals['uncategorized'] ?? 0.0) + expense.amount;
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
      BuildContext context, String categoryId, double percentage, double amount) {
    final theme = Theme.of(context);
    
    return FutureBuilder<ExpenseCategory?>(
      future: categoryRepo.findCategoryById(categoryId),
      builder: (context, snapshot) {
        final categoryInfo = snapshot.data;
        final categoryName = categoryInfo?.name ?? 'Uncategorized';
        
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
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
              child: Text(
                categoryName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
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
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryTotals = _getCategoryTotals();

    if (categoryTotals.isEmpty) {
      return Center(
        child: Text(
          'No expenses this month',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categoryTotals.length,
      itemBuilder: (context, index) {
        final entry = categoryTotals.entries.elementAt(index);
        final amount = expenses
            .where((e) =>
                e.categoryId == entry.key ||
                (entry.key == 'uncategorized' && e.categoryId == null))
            .fold(0.0, (sum, e) => sum + e.amount);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            margin: EdgeInsets.zero,
            color: theme.colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildCategoryRow(
                context,
                entry.key,
                entry.value,
                amount,
              ),
            ),
          ),
        );
      },
    );
  }
} 