import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/account.dart';
import '../utils/formatters.dart';
import '../utils/icons.dart';

class TodaySpendingCard extends StatelessWidget {
  final List<Expense> expenses;

  const TodaySpendingCard({
    super.key,
    required this.expenses,
  });

  double get _todayTotal {
    final now = DateTime.now();
    return expenses
        .where((expense) =>
            expense.date.year == now.year &&
            expense.date.month == now.month &&
            expense.date.day == now.day)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  double get _todayCreditCardTotal {
    final now = DateTime.now();
    return expenses
        .where((expense) =>
            expense.date.year == now.year &&
            expense.date.month == now.month &&
            expense.date.day == now.day &&
            expense.accountId == DefaultAccounts.creditCard.id)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  double get _averageDailySpend {
    if (expenses.isEmpty) return 0;
    
    final now = DateTime.now();
    final thisMonthExpenses = expenses.where((expense) =>
        expense.date.year == now.year &&
        expense.date.month == now.month);
    
    if (thisMonthExpenses.isEmpty) return 0;
    
    final totalSpent = thisMonthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    return totalSpent / now.day; // Divide by current day of month to get daily average
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todayTotal = _todayTotal;
    final creditCardTotal = _todayCreditCardTotal;
    final averageDaily = _averageDailySpend;

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
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
            const SizedBox(height: 4),
            Text(
              formatCurrency(todayTotal),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (todayTotal > 0 || averageDaily > 0) ...[
              const SizedBox(height: 16),
              if (creditCardTotal > 0)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: DefaultAccounts.creditCard.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        DefaultAccounts.creditCard.icon,
                        size: 20,
                        color: DefaultAccounts.creditCard.color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Credit card spending',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          formatCurrency(creditCardTotal),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              if (averageDaily > 0) ...[
                if (creditCardTotal > 0) ...[
                  const SizedBox(height: 0),
                  Divider(
                    color: theme.colorScheme.outlineVariant,
                    height: 40,
                  ),
                ],
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        AppIcons.insights,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
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
            ],
          ],
        ),
      ),
    );
  }
} 