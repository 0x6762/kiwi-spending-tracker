import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../repositories/category_repository.dart';
import '../../utils/formatters.dart';
import '../../theme/theme.dart';
import '../../services/expense_analytics_service.dart';
import '../../services/subscription_service.dart';
import '../../repositories/expense_repository.dart';
import '../../repositories/account_repository.dart';
import '../../screens/subscriptions_screen.dart';
import '../charts/monthly_expense_chart.dart';
import '../common/icon_container.dart';
import '../../utils/icons.dart';
import 'subscription_plans_card.dart';

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
  final _monthFormat = DateFormat.yMMMM();
  late SubscriptionService _subscriptionService;

  @override
  void initState() {
    super.initState();
    if (widget.repository != null && widget.categoryRepo != null) {
      _subscriptionService =
          SubscriptionService(widget.repository!, widget.categoryRepo!);
    }
  }

  Widget _buildMonthComparison(
      BuildContext context, MonthlyAnalytics analytics) {
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
            style: theme.textTheme.bodySmall?.copyWith(
              color: analytics.isIncrease
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
          Text(
            ' ${analytics.isIncrease ? 'more' : 'less'} than last month',
            style: theme.textTheme.bodySmall?.copyWith(
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
                                    : theme.colorScheme.primary
                                        .withOpacity(0.1),
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
                        iconColor: theme.colorScheme.fixedExpenseColor,
                      ),
                      const SizedBox(height: 0),
                      _SummaryRow(
                        label: 'Variable Expenses',
                        amount: analytics.variableExpenses,
                        context: context,
                        iconAsset: 'assets/icons/variable_expense.svg',
                        iconColor: theme.colorScheme.variableExpenseColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Subscription Plans Card
              if (widget.repository != null && widget.categoryRepo != null)
                FutureBuilder<SubscriptionSummary>(
                  future: _subscriptionService
                      .getSubscriptionSummaryForMonth(widget.selectedMonth),
                  builder: (context, subscriptionSnapshot) {
                    // Create a default summary if no data is available
                    final subscriptionSummary = subscriptionSnapshot.hasData
                        ? subscriptionSnapshot.data!
                        : SubscriptionSummary(
                            totalMonthlyAmount: 0,
                            monthlyBillingAmount: 0,
                            yearlyBillingMonthlyEquivalent: 0,
                            totalSubscriptions: 0,
                            activeSubscriptions: 0,
                            dueSoonSubscriptions: 0,
                            overdueSubscriptions: 0,
                          );

                    return SubscriptionPlansCard(
                      summary: subscriptionSummary,
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
                    );
                  },
                ),
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
  final bool showArrow;

  const _SummaryRow({
    required this.label,
    required this.amount,
    required this.context,
    required this.iconAsset,
    required this.iconColor,
    this.onTap,
    this.showArrow = true,
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
            if (onTap != null && showArrow) ...[
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
