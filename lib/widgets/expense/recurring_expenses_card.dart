import 'package:flutter/material.dart';
import '../../services/recurring_expense_service.dart';
import '../../utils/formatters.dart';
import '../../theme/theme.dart';

class RecurringExpensesCard extends StatelessWidget {
  final RecurringExpenseSummary summary;
  final VoidCallback? onTap;

  const RecurringExpensesCard({
    super.key,
    required this.summary,
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
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: _RecurringExpenseRow(
            label: 'Recurring Expenses',
            amount: summary.totalMonthlyAmount,
            context: context,
            icon: Icons.event_repeat_rounded,
            iconColor: theme.colorScheme.recurringExpenseColor,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

class _RecurringExpenseRow extends StatelessWidget {
  final String label;
  final double amount;
  final BuildContext context;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const _RecurringExpenseRow({
    required this.label,
    required this.amount,
    required this.context,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          formatCurrency(amount),
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
