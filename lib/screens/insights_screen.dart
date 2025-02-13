import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../repositories/category_repository.dart';
import '../services/expense_analytics_service.dart';
import '../widgets/category_statistics.dart';

class InsightsScreen extends StatelessWidget {
  final List<Expense> expenses;
  final CategoryRepository categoryRepo;
  final ExpenseAnalyticsService analyticsService;

  const InsightsScreen({
    super.key,
    required this.expenses,
    required this.categoryRepo,
    required this.analyticsService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'Insights',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              margin: EdgeInsets.zero,
              color: theme.colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CategoryStatistics(
                  expenses: expenses,
                  categoryRepo: categoryRepo,
                  analyticsService: analyticsService,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
