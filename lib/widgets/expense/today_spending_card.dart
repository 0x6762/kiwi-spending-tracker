import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../models/account.dart';
import '../../utils/formatters.dart';
import '../../utils/icons.dart';
import '../../services/expense_analytics_service.dart';
import '../../theme/design_tokens.dart';
import '../charts/daily_expense_chart.dart';
import '../common/app_card.dart';
import '../common/icon_container.dart';

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

    return AppCard.surface(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      margin: EdgeInsets.zero,
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
                padding: DesignTokens.paddingSymmetric(
                  horizontal: DesignTokens.spacingMd,
                  vertical: DesignTokens.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: DesignTokens.borderRadius(DesignTokens.radiusChip),
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
            SizedBox(height: DesignTokens.spacingXs),
            Text(
              formatCurrency(todayTotal),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (averageDaily > 0) ...[
              SizedBox(height: DesignTokens.spacingLg),
              Row(
                children: [
                  IconContainer.icon(
                    icon: AppIcons.insights,
                    iconColor: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                  SizedBox(width: DesignTokens.spacingMd),
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
              SizedBox(height: DesignTokens.spacingXl + DesignTokens.spacingSm),
              // Daily spending chart
              SizedBox(
                height: 80,
                child: Transform.translate(
                  offset: const Offset(0, -8),
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
      );
  }
} 