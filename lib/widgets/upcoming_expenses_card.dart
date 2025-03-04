import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/expense_analytics_service.dart';
import '../utils/formatters.dart';
import '../utils/icons.dart';

class UpcomingExpensesCard extends StatelessWidget {
  final UpcomingExpensesAnalytics analytics;
  final VoidCallback? onTap;

  const UpcomingExpensesCard({
    super.key,
    required this.analytics,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d');
    
    // Get the next 3 upcoming expenses to display
    final upcomingPreview = analytics.upcomingExpenses.take(3).toList();

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    AppIcons.calendar,
                    size: 24,
                    color: const Color(0xFF4CAF50),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Upcoming Expenses',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    formatCurrency(analytics.totalAmount),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (upcomingPreview.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'No upcoming expenses',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ...upcomingPreview.map((expense) => _UpcomingExpenseItem(
                      expense: expense,
                      theme: theme,
                      dateFormat: dateFormat,
                    )),
              if (analytics.upcomingExpenses.length > 3) ...[
                const SizedBox(height: 8),
                Text(
                  '+ ${analytics.upcomingExpenses.length - 3} more',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingExpenseItem extends StatelessWidget {
  final Expense expense;
  final ThemeData theme;
  final DateFormat dateFormat;

  const _UpcomingExpenseItem({
    required this.expense,
    required this.theme,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              dateFormat.format(expense.date),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (expense.categoryId != null)
                  Text(
                    expense.categoryId!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            formatCurrency(expense.amount),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
} 