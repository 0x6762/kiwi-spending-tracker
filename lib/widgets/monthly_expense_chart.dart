import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class MonthlyExpenseChart extends StatelessWidget {
  final List<Expense> expenses;

  const MonthlyExpenseChart({
    super.key,
    required this.expenses,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final months = _getLast6Months();
    final monthFormat = DateFormat.MMM();
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final now = DateTime.now();

    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceEvenly,
            groupsSpace: 16,
            maxY: expenses.isEmpty ? 100 : null,
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
            barGroups: months.asMap().entries.map((entry) {
              final index = entry.key;
              final month = entry.value;
              final total = _getMonthlyTotal(month);
              final isCurrentMonth =
                  month.year == now.year && month.month == now.month;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: total > 0
                        ? total
                        : 100, // Use full height for placeholders
                    width: 32, // Increased bar width
                    color: total > 0
                        ? (isCurrentMonth
                            ? theme.colorScheme.primary
                            : theme.colorScheme.primary.withOpacity(0.6))
                        : theme.colorScheme.surfaceVariant
                            .withOpacity(0.15), // More subtle opacity
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
                    borderRadius: BorderRadius.zero,
                  ),
                ],
                showingTooltipIndicators: total > 0 ? [0] : [],
              );
            }).toList(),
            barTouchData: BarTouchData(
              enabled: false,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.transparent,
                tooltipPadding: EdgeInsets.zero,
                tooltipMargin: 0,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final month = months[groupIndex];
                  final total = _getMonthlyTotal(month);
                  if (total <= 0) return null;
                  return BarTooltipItem(
                    currencyFormat.format(total),
                    theme.textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
