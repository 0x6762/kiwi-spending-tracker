import 'package:flutter/material.dart';
import '../../services/upcoming_expense_service.dart';
import '../../utils/formatters.dart';

class UpcomingExpensesCard extends StatelessWidget {
  final UpcomingExpensesSummary summary;
  final VoidCallback? onTap;

  const UpcomingExpensesCard({
    super.key,
    required this.summary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      elevation: 0,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _UpcomingExpensesRow(
            label: 'Upcoming',
            amount: summary.totalAmount,
            count: summary.totalCount,
            context: context,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

class _UpcomingExpensesRow extends StatelessWidget {
  final String label;
  final double amount;
  final int count;
  final BuildContext context;
  final VoidCallback? onTap;

  const _UpcomingExpensesRow({
    required this.label,
    required this.amount,
    required this.count,
    required this.context,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.schedule,
          size: 24,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (count > 0)
                Text(
                  '$count ${count == 1 ? 'expense' : 'expenses'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
            ],
          ),
        ),
        Text(
          formatCurrency(amount),
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (onTap != null) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ],
    );
  }
}
