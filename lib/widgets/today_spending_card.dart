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

  ({
    double todayTotal,
    double todayCreditCardTotal,
    double averageDaily,
  }) _calculateExpenseMetrics() {
    if (expenses.isEmpty) {
      return (
        todayTotal: 0.0,
        todayCreditCardTotal: 0.0,
        averageDaily: 0.0,
      );
    }

    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    
    double todayTotal = 0.0;
    double todayCreditCardTotal = 0.0;
    double monthlyTotal = 0.0;
    var daysWithExpenses = <int>{};  // Using int for day of month instead of DateTime

    for (final expense in expenses) {
      // Skip expenses from other months early
      if (expense.date.year != now.year || expense.date.month != now.month) {
        continue;
      }

      final amount = expense.amount;
      monthlyTotal += amount;
      daysWithExpenses.add(expense.date.day);

      // Check if expense is from today
      if (expense.date.day == now.day) {
        todayTotal += amount;
        if (expense.accountId == DefaultAccounts.creditCard.id) {
          todayCreditCardTotal += amount;
        }
      }
    }

    final averageDaily = daysWithExpenses.isEmpty ? 0.0 : monthlyTotal / daysWithExpenses.length;

    return (
      todayTotal: todayTotal,
      todayCreditCardTotal: todayCreditCardTotal,
      averageDaily: averageDaily,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = _calculateExpenseMetrics();
    final todayTotal = metrics.todayTotal;
    final creditCardTotal = metrics.todayCreditCardTotal;
    final averageDaily = metrics.averageDaily;

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