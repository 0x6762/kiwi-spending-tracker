import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../services/expense_analytics_service.dart';
import '../../utils/formatters.dart';

class MonthlyExpenseChart extends StatelessWidget {
  final List<Expense> expenses;
  final DateTime selectedMonth;
  final void Function(DateTime)? onMonthSelected;
  final ExpenseAnalyticsService analyticsService;
  final double? monthlyAverage;

  const MonthlyExpenseChart({
    super.key,
    required this.expenses,
    required this.selectedMonth,
    required this.analyticsService,
    this.onMonthSelected,
    this.monthlyAverage,
  });

  List<DateTime> _getLast6Months() {
    final now = DateTime.now();
    return List.generate(5, (index) {
      return DateTime(
        now.year,
        now.month - (4 - index),
      );
    });
  }

  Future<Map<DateTime, double>> _getMonthlyTotals(List<DateTime> months) async {
    final startDate = months.first;
    final endDate = months.last.add(const Duration(days: 31));
    return analyticsService.getMonthlyTotals(startDate, endDate);
  }

  double _calculateBarHeight(double total, double maxTotal) {
    // Calculate minimum height for non-zero values (10% of max)
    final minHeight = maxTotal * 0.1;

    // Empty months should be 1/3 of the minimum height
    if (total <= 0) return minHeight * 0.3;

    return total < minHeight ? minHeight : total;
  }

  double _calculateBorderRadius(double total, double maxTotal) {
    if (total <= 0) return 4; // Minimum radius for empty months

    // Interpolate between 6 and 16 based on the proportion of max value
    return 4 + (total / maxTotal) * 12;
  }

  String _formatAmount(double amount) {
    if (amount < 1000) {
      final currentSymbol =
          formatCurrency(0).replaceAll(RegExp(r'[0-9.,]+'), '');
      // Handle both dot and comma decimal separators
      return formatCurrency(amount)
          .replaceAll(RegExp(r'[.,]00'), '') // Remove .00 or ,00
          .replaceAll(RegExp(r'[.,][0-9]+'),
              ''); // Remove any decimal part with either . or ,
    }
    final value = (amount / 1000).toStringAsFixed(1);
    final formatted = formatCurrency(1000).replaceAll(RegExp(r'[0-9.,]+'), '');
    return '$formatted${value}k';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final months = _getLast6Months();
    final monthFormat = DateFormat.MMM();

    return FutureBuilder<Map<DateTime, double>>(
      future: _getMonthlyTotals(months),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final monthlyTotals = snapshot.data!;
        final maxTotal = monthlyTotals.values.isEmpty
            ? 0.0
            : monthlyTotals.values
                .reduce((max, value) => value > max ? value : max);

        return AspectRatio(
          aspectRatio: 2.5,
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                minY: 0,
                maxY: maxTotal,
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    if (monthlyAverage != null && monthlyAverage! > 0)
                      HorizontalLine(
                        y: monthlyAverage!,
                        color:
                            theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                        strokeWidth: 1,
                        dashArray: [1, 5],
                        label: HorizontalLineLabel(
                          show: false,
                          labelResolver: (line) => 'Avg',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                          alignment: Alignment.topLeft,
                        ),
                      ),
                  ],
                ),
                barGroups: months.asMap().entries.map((entry) {
                  final index = entry.key;
                  final month = entry.value;
                  final monthKey = DateTime(month.year, month.month);
                  final total = monthlyTotals[monthKey] ?? 0.0;
                  final isSelectedMonth = month.year == selectedMonth.year &&
                      month.month == selectedMonth.month;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: _calculateBarHeight(total, maxTotal),
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: total > 0
                            ? (isSelectedMonth
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurface.withOpacity(0.2))
                            : theme.colorScheme.onSurface.withOpacity(0.07),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: false,
                          color: theme.colorScheme.primaryContainer
                              .withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(
                            _calculateBorderRadius(total, maxTotal))),
                        rodStackItems: [],
                        fromY: 0,
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
                    tooltipBgColor: theme.colorScheme.onSurface.withOpacity(0),
                    tooltipPadding: const EdgeInsets.fromLTRB(8, 8, 8, 3),
                    tooltipMargin: 4,
                    tooltipRoundedRadius: 16,
                    fitInsideHorizontally: false,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final month = months[groupIndex];
                      final monthKey = DateTime(month.year, month.month);
                      final total = monthlyTotals[monthKey] ?? 0.0;
                      if (total <= 0) return null;
                      final isSelectedMonth =
                          month.year == selectedMonth.year &&
                              month.month == selectedMonth.month;
                      return BarTooltipItem(
                        _formatAmount(total),
                        theme.textTheme.labelSmall!.copyWith(
                          color: isSelectedMonth
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant
                                  .withOpacity(1),
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
      },
    );
  }
}
