import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/expense.dart';
import '../services/expense_analytics_service.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/account_repository.dart';
import '../screens/subscriptions_screen.dart';
import 'monthly_expense_chart.dart';
import 'upcoming_expenses_card.dart';
import '../utils/formatters.dart';

class ExpenseSummary extends StatefulWidget {
  final List<Expense> expenses;
  final void Function(DateTime selectedMonth) onMonthSelected;
  final DateTime selectedMonth;
  final bool showChart;
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
    this.repository,
    this.categoryRepo,
    this.accountRepo,
  });

  @override
  State<ExpenseSummary> createState() => _ExpenseSummaryState();
}

class _ExpenseSummaryState extends State<ExpenseSummary> {
  final _monthFormat = DateFormat.yMMMM();

  Widget _buildMonthComparison(BuildContext context, MonthlyAnalytics analytics) {
    if (analytics.previousMonthTotal == 0) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            analytics.isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
            size: 16,
            color: analytics.isIncrease
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '${analytics.percentageChange.toStringAsFixed(1)}%',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: analytics.isIncrease
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
          Text(
            ' ${analytics.isIncrease ? 'more' : 'less'} than last month',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<MonthlyAnalytics>(
      future: widget.analyticsService.getMonthlyAnalytics(widget.selectedMonth),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final analytics = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.showChart) ...[
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
                        const SizedBox(height: 4),
                        Text(
                          formatCurrency(analytics.totalSpent),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        _buildMonthComparison(context, analytics),
                        const SizedBox(height: 32),
                        MonthlyExpenseChart(
                          expenses: widget.expenses,
                          selectedMonth: widget.selectedMonth,
                          onMonthSelected: widget.onMonthSelected,
                          analyticsService: widget.analyticsService,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  margin: EdgeInsets.zero,
                  color: theme.colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _SummaryRow(
                          label: 'Fixed Expenses',
                          amount: analytics.fixedExpenses,
                          context: context,
                          iconAsset: 'assets/icons/fixed_expense.svg',
                          iconColor: const Color(0xFFCF5825),
                        ),
                        const SizedBox(height: 0),
                        _SummaryRow(
                          label: 'Variable Expenses',
                          amount: analytics.variableExpenses,
                          context: context,
                          iconAsset: 'assets/icons/variable_expense.svg',
                          iconColor: const Color(0xFF8056E4),
                        ),
                        const SizedBox(height: 0),
                        _SummaryRow(
                          label: 'Subscriptions',
                          amount: analytics.subscriptionExpenses,
                          context: context,
                          iconAsset: 'assets/icons/subscription.svg',
                          iconColor: const Color(0xFF2196F3),
                          onTap: widget.repository != null && 
                                 widget.categoryRepo != null && 
                                 widget.accountRepo != null
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SubscriptionsScreen(
                                        repository: widget.repository!,
                                        categoryRepo: widget.categoryRepo!,
                                        accountRepo: widget.accountRepo!,
                                        selectedMonth: widget.selectedMonth,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<UpcomingExpensesAnalytics>(
                  future: widget.analyticsService.getUpcomingExpenses(),
                  builder: (context, upcomingSnapshot) {
                    if (!upcomingSnapshot.hasData) {
                      return const SizedBox.shrink();
                    }
                    
                    final upcomingAnalytics = upcomingSnapshot.data!;
                    
                    if (upcomingAnalytics.upcomingExpenses.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    
                    return UpcomingExpensesCard(
                      analytics: upcomingAnalytics,
                      onTap: null,
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final BuildContext context;
  final String iconAsset;
  final Color iconColor;
  final VoidCallback? onTap;

  const _SummaryRow({
    required this.label,
    required this.amount,
    required this.context,
    required this.iconAsset,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                iconColor,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
        ),
      ),
    );
  }
}
