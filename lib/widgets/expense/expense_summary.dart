import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../repositories/category_repository.dart';
import '../../utils/formatters.dart';
import '../../services/expense_analytics_service.dart';
import '../../services/recurring_expense_service.dart';
import '../../repositories/expense_repository.dart';
import '../../repositories/account_repository.dart';
import '../../screens/recurring_expenses_screen.dart';
import '../charts/monthly_expense_chart.dart';
import '../common/icon_container.dart';
import '../../utils/icons.dart';
import 'recurring_expenses_card.dart';
import 'necessity_cards.dart';

class ExpenseSummary extends StatefulWidget {
  final List<Expense> expenses;
  final void Function(DateTime selectedMonth) onMonthSelected;
  final DateTime selectedMonth;
  final bool showChart;
  final bool showMonthlyChart;
  final ExpenseAnalyticsService analyticsService;
  final ExpenseRepository? repository;
  final CategoryRepository? categoryRepo;
  final AccountRepository? accountRepo;

  const ExpenseSummary({
    super.key,
    required this.expenses,
    required this.onMonthSelected,
    required this.selectedMonth,
    required this.analyticsService,
    this.showChart = true,
    this.showMonthlyChart = true,
    this.repository,
    this.categoryRepo,
    this.accountRepo,
  });

  @override
  State<ExpenseSummary> createState() => _ExpenseSummaryState();
}

class _ExpenseSummaryState extends State<ExpenseSummary> {
  late RecurringExpenseService _recurringExpenseService;

  @override
  void initState() {
    super.initState();
    if (widget.repository != null) {
      _recurringExpenseService =
          RecurringExpenseService(widget.repository!, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use synchronous method with provided expenses
    final analytics = widget.analyticsService
        .getMonthlyAnalyticsFromExpenses(widget.expenses, widget.selectedMonth);

    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
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
                  Text(
                    'Total Spent',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        formatCurrency(analytics.totalSpent),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (analytics.previousMonthTotal > 0) ...[
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: analytics.isIncrease
                                ? theme.colorScheme.error.withOpacity(0.1)
                                : theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                analytics.isIncrease
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 12,
                                color: analytics.isIncrease
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${analytics.percentageChange.toStringAsFixed(1)}%',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: analytics.isIncrease
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (analytics.averageMonthly > 0) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        IconContainer.icon(
                          icon: AppIcons.insights,
                          iconColor: theme.colorScheme.primary,
                          backgroundColor:
                              theme.colorScheme.primary.withOpacity(0.1),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly average',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              formatCurrency(analytics.averageMonthly),
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
                  if (widget.showMonthlyChart) ...[
                    const SizedBox(height: 32),
                    MonthlyExpenseChart(
                      expenses: widget.expenses,
                      selectedMonth: widget.selectedMonth,
                      onMonthSelected: widget.onMonthSelected,
                      analyticsService: widget.analyticsService,
                      monthlyAverage: analytics.averageMonthly,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Necessity Cards (Essential and Extra)
          NecessityCards(
            expenses: widget.expenses,
            selectedMonth: widget.selectedMonth,
          ),
          const SizedBox(height: 8),
          // Recurring Expenses Card
          if (widget.repository != null && widget.categoryRepo != null)
            FutureBuilder<RecurringExpenseSummary>(
              future: _recurringExpenseService
                  .getRecurringExpenseSummaryForMonth(widget.selectedMonth),
              builder: (context, recurringSnapshot) {
                final recurringSummary = recurringSnapshot.hasData
                    ? recurringSnapshot.data!
                    : RecurringExpenseSummary(
                        totalMonthlyAmount: 0,
                        monthlyBillingAmount: 0,
                        yearlyBillingMonthlyEquivalent: 0,
                        totalRecurringExpenses: 0,
                        activeRecurringExpenses: 0,
                        dueSoonRecurringExpenses: 0,
                        overdueRecurringExpenses: 0,
                      );

                return RecurringExpensesCard(
                  summary: recurringSummary,
                  onTap: widget.repository != null &&
                          widget.categoryRepo != null &&
                          widget.accountRepo != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecurringExpensesScreen(
                                repository: widget.repository!,
                                categoryRepo: widget.categoryRepo!,
                                accountRepo: widget.accountRepo!,
                                selectedMonth: widget.selectedMonth,
                              ),
                            ),
                          );
                        }
                      : null,
                );
              },
            ),
        ],
      ),
    );
  }
}
