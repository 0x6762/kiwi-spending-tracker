import 'package:flutter/material.dart';
import '../../services/expense_analytics_service.dart';
import '../../utils/formatters.dart';
import '../../utils/icons.dart';
import '../../theme/theme.dart';
import '../../theme/design_tokens.dart';
import '../common/app_card.dart';
import '../common/icon_container.dart';

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
    
    return AppCard.standard(
      margin: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconContainer.icon(
            icon: Icons.schedule,
            iconColor: theme.colorScheme.upcomingExpenseColor,
            backgroundColor: theme.colorScheme.upcomingExpenseColor.withOpacity(0.1),
            size: IconContainerSize.medium,
          ),
          SizedBox(height: DesignTokens.spacingMd),
              Text(
                'Upcoming',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: DesignTokens.spacingXs),
              Text(
                formatCurrency(analytics.totalAmount),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
          ],
        ),
    );
  }
} 