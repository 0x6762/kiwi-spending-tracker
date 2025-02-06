import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/expense.dart';
import 'monthly_expense_chart.dart';
import '../utils/formatters.dart';

class ExpenseSummary extends StatefulWidget {
  final List<Expense> expenses;
  final void Function(DateTime selectedMonth) onMonthSelected;
  final DateTime selectedMonth;
  final bool showChart;

  const ExpenseSummary({
    super.key,
    required this.expenses,
    required this.onMonthSelected,
    required this.selectedMonth,
    this.showChart = true,
  });

  @override
  State<ExpenseSummary> createState() => _ExpenseSummaryState();
}

class _ExpenseSummaryState extends State<ExpenseSummary> {
  final _monthFormat = DateFormat.yMMMM();

  List<Expense> get _monthlyExpenses {
    return widget.expenses
        .where((expense) =>
            expense.date.year == widget.selectedMonth.year &&
            expense.date.month == widget.selectedMonth.month)
        .toList();
  }

  double get _fixedTotal {
    return _monthlyExpenses
        .where((expense) => expense.isFixed)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get _variableTotal {
    return _monthlyExpenses
        .where((expense) => !expense.isFixed)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get _monthlyTotal => _fixedTotal + _variableTotal;

  double get _previousMonthTotal {
    final previousMonth =
        DateTime(widget.selectedMonth.year, widget.selectedMonth.month - 1);
    return widget.expenses
        .where((expense) =>
            expense.date.year == previousMonth.year &&
            expense.date.month == previousMonth.month)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Widget _buildMonthComparison(BuildContext context) {
    final previousTotal = _previousMonthTotal;
    if (previousTotal == 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final difference = _monthlyTotal - previousTotal;
    final percentageChange =
        (difference / previousTotal * 100).abs().toStringAsFixed(1);
    final isIncrease = difference > 0;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
            size: 16,
            color: isIncrease
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '${percentageChange}%',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isIncrease
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
          Text(
            ' ${isIncrease ? 'more' : 'less'} than last month',
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

    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showChart) ...[
            Card(
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(_monthlyTotal),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    _buildMonthComparison(context),
                    const SizedBox(height: 32),
                    MonthlyExpenseChart(
                      expenses: widget.expenses,
                      selectedMonth: widget.selectedMonth,
                      onMonthSelected: widget.onMonthSelected,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 0),
            Card(
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
                      amount: _fixedTotal,
                      context: context,
                      iconAsset: 'assets/icons/fixed_expense.svg',
                    ),
                    const SizedBox(height: 16),
                    _SummaryRow(
                      label: 'Variable Expenses',
                      amount: _variableTotal,
                      context: context,
                      iconAsset: 'assets/icons/variable_expense.svg',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final BuildContext context;
  final String iconAsset;

  const _SummaryRow({
    required this.label,
    required this.amount,
    required this.context,
    required this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isFixed = label == 'Fixed Expenses';

    return Container(
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
              isFixed ? const Color(0xFFCF5825) : const Color(0xFF8056E4),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 12),
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
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
