import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/subscription_service.dart';
import '../../utils/formatters.dart';
import '../../utils/icons.dart';
import '../../theme/theme.dart';
import '../../theme/design_tokens.dart';
import '../common/app_card.dart';
import '../common/icon_container.dart';

class SubscriptionPlansCard extends StatelessWidget {
  final SubscriptionSummary summary;
  final VoidCallback? onTap;

  const SubscriptionPlansCard({
    super.key,
    required this.summary,
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
            icon: Icons.repeat,
            iconColor: theme.colorScheme.subscriptionColor,
            backgroundColor: theme.colorScheme.subscriptionColor.withOpacity(0.1),
            size: IconContainerSize.medium,
          ),
          SizedBox(height: DesignTokens.spacingMd),
          Text(
            'Subscriptions',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: DesignTokens.spacingXs),
          Text(
            formatCurrency(summary.totalMonthlyAmount),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
} 