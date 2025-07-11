import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../models/account.dart';
import '../../utils/formatters.dart';
import '../../utils/icons.dart';
import '../../services/expense_analytics_service.dart';
import '../charts/daily_expense_chart.dart';

class TodaySpendingCard extends StatelessWidget {
  final List<Expense> expenses;
  final ExpenseAnalyticsService analyticsService;

  const TodaySpendingCard({
    super.key,
    required this.expenses,
    required this.analyticsService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = analyticsService.getDailyMetrics(expenses);
    final todayTotal = metrics.todayTotal;
    final creditCardTotal = metrics.todayCreditCardTotal;
    final averageDaily = metrics.averageDaily;

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Spent today",
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Today',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              formatCurrency(todayTotal),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (averageDaily > 0) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      AppIcons.insights,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily average',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        formatCurrency(averageDaily),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
            if (averageDaily > 0) ...[
              const SizedBox(height: 40),
              // Daily spending chart
              SizedBox(
                height: 60,
                child: Transform.translate(
                  offset: const Offset(0, -16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: DailyExpenseChart(
                        expenses: expenses,
                        selectedMonth: DateTime(DateTime.now().year, DateTime.now().month),
                        analyticsService: analyticsService,
                        isCompact: true,
                        dailyAverage: averageDaily,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 