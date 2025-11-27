import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../models/expense_category.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/account_repository.dart';
import '../../repositories/expense_repository.dart';
import '../../services/expense_analytics_service.dart';
import '../../utils/formatters.dart';
import '../../screens/category_expenses_screen.dart';

class CategoryStatistics extends StatelessWidget {
  final List<Expense> expenses;
  final CategoryRepository categoryRepo;
  final ExpenseAnalyticsService analyticsService;
  final DateTime selectedMonth;
  final AccountRepository? accountRepo;
  final ExpenseRepository? repository;

  const CategoryStatistics({
    super.key,
    required this.expenses,
    required this.categoryRepo,
    required this.analyticsService,
    required this.selectedMonth,
    this.accountRepo,
    this.repository,
  });

  Widget _buildCategoryRow(
      BuildContext context, CategorySpending spending, ExpenseCategory? category) {
    final theme = Theme.of(context);
    final categoryName = category?.name ?? 'Uncategorized';

    return GestureDetector(
          onTap: (repository != null && accountRepo != null)
              ? () => _navigateToCategoryDetails(
                  context, spending.categoryId, categoryName)
              : null,
          child: Card(
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
                      category?.icon ?? Icons.category_outlined,
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
          ),
        );
  }

  void _navigateToCategoryDetails(
      BuildContext context, String categoryId, String categoryName) {
    if (repository == null || accountRepo == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryExpensesScreen(
          categoryRepo: categoryRepo,
          accountRepo: accountRepo!,
          categoryId: categoryId,
          selectedMonth: selectedMonth,
        ),
      ),
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
        
        // Batch load all categories at once
        final categoryIds = categorySpending
            .map((spending) => spending.categoryId)
            .toSet()
            .toList();
        
        return FutureBuilder<Map<String, ExpenseCategory?>>(
          future: _loadCategoriesBatch(categoryIds),
          builder: (context, categorySnapshot) {
            final categoriesMap = categorySnapshot.data ?? {};

            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categorySpending.length,
              itemBuilder: (context, index) {
                final spending = categorySpending[index];
                final category = categoriesMap[spending.categoryId];
                return RepaintBoundary(
                  child: _buildCategoryRow(context, spending, category),
                );
              },
            );
          },
        );
      },
    );
  }

  /// Batch load all categories at once to avoid N+1 queries
  Future<Map<String, ExpenseCategory?>> _loadCategoriesBatch(
      List<String> categoryIds) async {
    final Map<String, ExpenseCategory?> categoriesMap = {};
    
    // Load all categories in parallel
    final futures = categoryIds.map((id) async {
      final category = await categoryRepo.findCategoryById(id);
      return MapEntry(id, category);
    });
    
    final results = await Future.wait(futures);
    for (final entry in results) {
      categoriesMap[entry.key] = entry.value;
    }
    
    return categoriesMap;
  }
}
