import 'package:flutter/material.dart';
import '../../services/expense_analytics_service.dart';
import '../../utils/formatters.dart';
import '../../utils/icons.dart';
import '../../theme/theme.dart';

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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.upcomingExpenseColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.schedule,
                  color: theme.colorScheme.upcomingExpenseColor,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Upcoming',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                formatCurrency(analytics.totalAmount),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 