import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../models/expense_category.dart';
import '../../repositories/category_repository.dart';
import '../../services/expense_analytics_service.dart';
import '../../utils/formatters.dart';

class CategoryStatistics extends StatelessWidget {
  final List<Expense> expenses;
  final CategoryRepository categoryRepo;
  final ExpenseAnalyticsService analyticsService;

  const CategoryStatistics({
    super.key,
    required this.expenses,
    required this.categoryRepo,
    required this.analyticsService,
  });

  Widget _buildCategoryRow(
      BuildContext context, CategorySpending spending) {
    final theme = Theme.of(context);
    
    return FutureBuilder<ExpenseCategory?>(
      future: categoryRepo.findCategoryById(spending.categoryId),
      builder: (context, snapshot) {
        final categoryInfo = snapshot.data;
        final categoryName = categoryInfo?.name ?? 'Uncategorized';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: theme.colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
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
                      '${spending.percentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(spending.amount),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<CategorySpending>>(
      future: analyticsService.getCategorySpending(expenses),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No expenses this month',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        final categorySpending = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categorySpending.length,
          itemBuilder: (context, index) {
            final spending = categorySpending[index];
            return _buildCategoryRow(context, spending);
          },
        );
      },
    );
  }
} 