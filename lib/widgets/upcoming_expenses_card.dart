import 'package:flutter/material.dart';
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
          padding: const EdgeInsets.all(28),
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
              const SizedBox(height: 8),
              Text(
                '${analytics.upcomingExpenses.length} upcoming expenses',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 