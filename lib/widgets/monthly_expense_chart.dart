import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../utils/formatters.dart';

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
    return List.generate(5, (index) {
      return DateTime(
        now.year,
        now.month - (4 - index), // Start from 5 months ago
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
      return formatCurrency(amount);
    }
    final value = (amount / 1000).toStringAsFixed(1);
    // Remove the currency symbol from the formatted string and add 'k' suffix
    final formatted = formatCurrency(1000).replaceAll(RegExp(r'[0-9.,]+'), '');
    return '$formatted${value}k';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final months = _getLast6Months();
    final monthFormat = DateFormat.MMM();

    return AspectRatio(
      aspectRatio: 2.5,
      child: Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 0),
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
                    width: MediaQuery.of(context).size.width * 0.15, // 15% of screen width
                    color: total > 0
                        ? (isSelectedMonth
                            ? theme.colorScheme.onSurface //selected month bar color
                            : theme.colorScheme.onSurface.withOpacity(0.2)) //other months bar color
                        : theme.colorScheme.onSurface.withOpacity(0.07), //no expenses bar color
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: expenses.isEmpty ? 100 : null,
                      color: theme.colorScheme.primaryContainer.withOpacity(0.2),
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
                tooltipBgColor: theme.colorScheme.onSurface.withOpacity(0.1),
                tooltipPadding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                tooltipMargin: 8,
                tooltipRoundedRadius: 16,
                fitInsideHorizontally: false,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final month = months[groupIndex];
                  final total = _getMonthlyTotal(month);
                  if (total <= 0) return null;
                  final isSelectedMonth = month.year == selectedMonth.year &&
                      month.month == selectedMonth.month;
                  return BarTooltipItem(
                    _formatAmount(total),
                    theme.textTheme.labelSmall!.copyWith(
                      // fontWeight: FontWeight.bold,
                      color: isSelectedMonth
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant.withOpacity(1),
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
                        monthFormat.format(month).toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );

                  },
                  reservedSize: 24,
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
