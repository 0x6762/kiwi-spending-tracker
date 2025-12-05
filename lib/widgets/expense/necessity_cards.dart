import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../utils/formatters.dart';
import '../../theme/theme.dart';

class NecessityCards extends StatelessWidget {
  final List<Expense> expenses;
  final DateTime selectedMonth;

  const NecessityCards({
    super.key,
    required this.expenses,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter expenses by selected month
    final filteredExpenses = expenses
        .where((expense) =>
            expense.date.year == selectedMonth.year &&
            expense.date.month == selectedMonth.month)
        .toList();

    // Calculate totals for Essential and Extra expenses
    final essentialTotal = filteredExpenses
        .where((e) => e.necessity == ExpenseNecessity.essential)
        .fold<double>(0.0, (sum, expense) => sum + expense.amount);

    final extraTotal = filteredExpenses
        .where((e) => e.necessity == ExpenseNecessity.extra)
        .fold<double>(0.0, (sum, expense) => sum + expense.amount);

    return Row(
      children: [
        Expanded(
          child: _NecessityCard(
            label: 'Essential',
            amount: essentialTotal,
            icon: Icons.favorite_outline_rounded,
            iconColor: theme.colorScheme.error,
            backgroundColor: theme.colorScheme.error.withOpacity(0.1),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _NecessityCard(
            label: 'Extra',
            amount: extraTotal,
            icon: Icons.mood_rounded,
            iconColor: theme.colorScheme.extraExpenseColor,
            backgroundColor:
                theme.colorScheme.extraExpenseColor.withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}

class _NecessityCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const _NecessityCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              formatCurrency(amount),
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
