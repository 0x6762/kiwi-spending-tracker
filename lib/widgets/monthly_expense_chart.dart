import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class MonthlyExpenseChart extends StatelessWidget {
  final List<Expense> expenses;
  final DateTime selectedMonth;
  final void Function(DateTime)? onMonthSelected;

  const MonthlyExpenseChart({
    super.key,
    required this.expenses,
    required this.selectedMonth,
    this.onMonthSelected,
  });

  List<DateTime> _getLast6Months() {
    final now = DateTime.now();
    return List.generate(6, (index) {
      return DateTime(
        now.year,
        now.month - (5 - index), // Start from 5 months ago
      );
    });
  }

  double _getMonthlyTotal(DateTime month) {
    return expenses
        .where((e) => e.date.year == month.year && e.date.month == month.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  String _formatAmount(double amount) {
    if (amount < 1000) {
      return NumberFormat.currency(symbol: '\$', decimalDigits: 0)
          .format(amount);
    }
    final value = (amount / 100).floor() / 10;
    return '\$${value.toStringAsFixed(1)}k';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final months = _getLast6Months();
    final monthFormat = DateFormat.MMM();
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return AspectRatio(
      aspectRatio: 2.2,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceBetween,
            barGroups: months.asMap().entries.map((entry) {
              final index = entry.key;
              final month = entry.value;
              final total = _getMonthlyTotal(month);
              final isSelectedMonth = month.year == selectedMonth.year &&
                  month.month == selectedMonth.month;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: total > 0 ? total : 100,
                    width: 48,
                    color: total > 0
                        ? (isSelectedMonth
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceVariant)
                        : theme.colorScheme.surfaceVariant,
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: expenses.isEmpty ? 100 : null,
                      color:
                          theme.colorScheme.primaryContainer.withOpacity(0.2),
                    ),
                    rodStackItems: [
                      BarChartRodStackItem(
                        0,
                        total > 0 ? total : 100, // Match the full height
                        Colors.transparent,
                        BorderSide.none,
                      ),
                    ],
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                  ),
                ],
                showingTooltipIndicators: total > 0 ? [0] : [],
              );
            }).toList(),
            barTouchData: BarTouchData(
              enabled: true,
              handleBuiltInTouches: true,
              touchCallback: (event, response) {
                if (event is FlTapUpEvent &&
                    response?.spot != null &&
                    onMonthSelected != null) {
                  final monthIndex = response!.spot!.touchedBarGroupIndex;
                  if (monthIndex >= 0 && monthIndex < months.length) {
                    final selectedMonth = months[monthIndex];
                    onMonthSelected!(selectedMonth);
                  }
                }
              },
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: theme.colorScheme.surfaceVariant,
                tooltipPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                tooltipMargin: 8,
                tooltipRoundedRadius: 24,
                fitInsideHorizontally: true,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final month = months[groupIndex];
                  final total = _getMonthlyTotal(month);
                  if (total <= 0) return null;
                  final isSelectedMonth = month.year == selectedMonth.year &&
                      month.month == selectedMonth.month;
                  return BarTooltipItem(
                    _formatAmount(total),
                    theme.textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelectedMonth
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withOpacity(0.8),
                      height: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
                tooltipHorizontalAlignment: FLHorizontalAlignment.center,
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value < 0 || value >= months.length)
                      return const Text('');
                    final month = months[value.toInt()];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        monthFormat.format(month),
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  },
                  reservedSize: 32,
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }
}
