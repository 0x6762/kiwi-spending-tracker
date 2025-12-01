import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../services/expense_analytics_service.dart';
import '../../utils/formatters.dart';

class MonthlyExpenseChart extends StatefulWidget {
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

  @override
  State<MonthlyExpenseChart> createState() => _MonthlyExpenseChartState();
}

class _MonthlyExpenseChartState extends State<MonthlyExpenseChart> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToCurrentMonth = false;

  List<DateTime> _getAvailableMonths() {
    final now = DateTime.now();

    if (widget.expenses.isEmpty) {
      // Fallback to last 6 months if no expenses
      return List.generate(6, (index) {
        return DateTime(
          now.year,
          now.month - (5 - index),
        );
      });
    }

    final expenseMonths = widget.expenses
        .map((e) => DateTime(e.date.year, e.date.month))
        .toSet()
        .toList();

    expenseMonths.sort();

    final firstMonth = expenseMonths.first;
    final lastMonth = DateTime(now.year, now.month + 1);

    final months = <DateTime>[];

    DateTime currentMonth = firstMonth;
    while (currentMonth.isBefore(lastMonth)) {
      months.add(DateTime(currentMonth.year, currentMonth.month));
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    }

    if (months.length < 6) {
      final monthsNeeded = 6 - months.length;

      if (months.isNotEmpty) {
        final firstExpenseMonth = months.first;
        for (int i = 1; i <= monthsNeeded; i++) {
          final monthToAdd = DateTime(
            firstExpenseMonth.year,
            firstExpenseMonth.month - i,
          );
          months.insert(0, monthToAdd);
      }
    } else {
      return List.generate(6, (index) {
          return DateTime(
            now.year,
            now.month - (5 - index),
          );
        });
      }
    }

    return months;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToRightmost(List<DateTime> months) {
    if (_hasScrolledToCurrentMonth || months.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
        _hasScrolledToCurrentMonth = true;
      }
    });
  }

  Future<Map<DateTime, double>> _getMonthlyTotals(List<DateTime> months) async {
    if (months.isEmpty) return {};

    final startDate = months.first;
    final endDate = months.last.add(const Duration(days: 31));
    return widget.analyticsService.getMonthlyTotals(startDate, endDate);
  }

  double _calculateBarHeight(double total, double maxTotal) {
    final minHeight = maxTotal * 0.1;

    if (total <= 0) return minHeight * 0.3;

    return total < minHeight ? minHeight : total;
  }

  double _calculateBorderRadius(double total, double maxTotal) {
    if (total <= 0) return 4;

    return 4 + (total / maxTotal) * 12;
  }

  String _formatAmount(double amount) {
    if (amount < 1000) {
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
    final months = _getAvailableMonths();
    final monthFormat = DateFormat.MMM();

    // Scroll to rightmost position when months are available
    _scrollToRightmost(months);

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

        // Calculate chart width based on number of months
        final barWidth = MediaQuery.of(context).size.width * 0.14;
        final spacing = MediaQuery.of(context).size.width * 0.02;
        final chartWidth = (months.length * barWidth) +
            ((months.length - 1) * spacing) +
            0; // 32 for padding

        return Container(
          height: 140, // Increased height to accommodate tooltips
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: chartWidth,
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 0),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceBetween,
                    minY: 0,
                    maxY: maxTotal,
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        if (widget.monthlyAverage != null &&
                            widget.monthlyAverage! > 0)
                          HorizontalLine(
                            y: widget.monthlyAverage!,
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.6),
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
                      final isSelectedMonth =
                          month.year == widget.selectedMonth.year &&
                              month.month == widget.selectedMonth.month;

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: _calculateBarHeight(total, maxTotal),
                            width: barWidth,
                            color: total > 0
                                ? (isSelectedMonth
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface
                                        .withOpacity(0.2))
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
                            widget.onMonthSelected != null) {
                          final monthIndex =
                              response!.spot!.touchedBarGroupIndex;
                          if (monthIndex >= 0 && monthIndex < months.length) {
                            final selectedMonth = months[monthIndex];
                            widget.onMonthSelected!(selectedMonth);
                          }
                        }
                      },
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor:
                            theme.colorScheme.onSurface.withOpacity(0),
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
                              month.year == widget.selectedMonth.year &&
                                  month.month == widget.selectedMonth.month;
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
                        tooltipHorizontalAlignment:
                            FLHorizontalAlignment.center,
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
            ),
          ),
        );
      },
    );
  }
}
