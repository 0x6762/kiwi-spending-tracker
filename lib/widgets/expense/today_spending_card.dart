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
  final VoidCallback? onSeeAllPressed;

  const TodaySpendingCard({
    super.key,
    required this.expenses,
    required this.analyticsService,
    this.onSeeAllPressed,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Spent today",
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onSeeAllPressed,
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurface,
                  padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spacingSmd,
                      vertical: DesignTokens.spacingSm),
                  backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        DesignTokens.borderRadius(DesignTokens.radiusChip),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'See all',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spacingSm),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color:
                          theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            formatCurrency(todayTotal),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (averageDaily > 0) ...[
            const SizedBox(height: DesignTokens.spacingLg),
            Row(
              children: [
                IconContainer.icon(
                  icon: AppIcons.insights,
                  iconColor: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                ),
                const SizedBox(width: DesignTokens.spacingMd),
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
            const SizedBox(height: DesignTokens.spacingLg),
            // Daily spending chart
            SizedBox(
              height: 80,
              child: Transform.translate(
                offset: const Offset(0, 0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: DailyExpenseChart(
                      expenses: expenses,
                      selectedMonth:
                          DateTime(DateTime.now().year, DateTime.now().month),
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
