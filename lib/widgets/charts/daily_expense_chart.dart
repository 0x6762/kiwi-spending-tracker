import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../services/expense_analytics_service.dart';
import '../../utils/formatters.dart';

class DailyExpenseChart extends StatelessWidget {
  final List<Expense> expenses;
  final DateTime selectedMonth;
  final ExpenseAnalyticsService analyticsService;
  final bool isCompact;
  final double? dailyAverage;

  const DailyExpenseChart({
    super.key,
    required this.expenses,
    required this.selectedMonth,
    required this.analyticsService,
    this.isCompact = false,
    this.dailyAverage,
  });

  List<DateTime> _getDaysInMonth() {
    if (isCompact) {
      // For compact view, show last 14 days starting from today
      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);
      return List.generate(14, (index) {
        return todayOnly.subtract(Duration(days: 13 - index));
      });
    } else {
      // For full view, show entire month
      final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
      final lastDay = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
      return List.generate(
        lastDay.day,
        (index) => DateTime(selectedMonth.year, selectedMonth.month, index + 1),
      );
    }
  }

  Map<DateTime, double> _getDailyTotals() {
    final days = _getDaysInMonth();
    final dailyTotals = <DateTime, double>{};
    
    // Initialize all days with 0
    for (final day in days) {
      dailyTotals[day] = 0.0;
    }
    
    // Add up expenses for each day
    for (final expense in expenses) {
      final dayKey = DateTime(expense.date.year, expense.date.month, expense.date.day);
      if (dailyTotals.containsKey(dayKey)) {
        dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0.0) + expense.amount;
      }
    }
    
    return dailyTotals;
  }



  String _formatAmount(double amount) {
    if (amount < 1000) {
      final currentSymbol = formatCurrency(0).replaceAll(RegExp(r'[0-9.,]+'), '');
      return formatCurrency(amount)
          .replaceAll(RegExp(r'[.,]00'), '')
          .replaceAll(RegExp(r'[.,][0-9]+'), '');
    }
    final value = (amount / 1000).toStringAsFixed(1);
    final formatted = formatCurrency(1000).replaceAll(RegExp(r'[0-9.,]+'), '');
    return '$formatted${value}k';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dailyTotals = _getDailyTotals();
    final days = _getDaysInMonth();
        final maxTotal = dailyTotals.values.isEmpty 
        ? 0.0 
        : dailyTotals.values.reduce((max, value) => value > max ? value : max);

    // Create line chart spots
    final spots = days.asMap().entries.map((entry) {
      final index = entry.key;
      final day = entry.value;
      final total = dailyTotals[day] ?? 0.0;
      return FlSpot(index.toDouble(), total);
    }).toList();

    final avgValue = dailyAverage ?? 0.0;
    final chartMaxY = maxTotal == 0 ? 100.0 : 
        (maxTotal > avgValue ? maxTotal * 1.1 : avgValue * 1.2);
    
    final chartWidget = LineChart(
                 LineChartData(
                   minX: 0,
                   maxX: (days.length - 1).toDouble(),
                   minY: 0,
                   maxY: chartMaxY,
                   extraLinesData: ExtraLinesData(
                     horizontalLines: [
                       // Baseline at y=0
                      //  HorizontalLine(
                      //    y: 0,
                      //    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                      //    strokeWidth: 1,
                      //    dashArray: [3, 3],
                      //  ),
                       // Daily average line
                       if (avgValue > 0)
                         HorizontalLine(
                           y: avgValue,
                           color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                           strokeWidth: 1,
                           dashArray: [1, 5],
                           label: HorizontalLineLabel(
                             show: true,
                             labelResolver: (line) => isCompact ? 'Avg' : 'Daily Average',
                             style: theme.textTheme.labelSmall?.copyWith(
                               color: theme.colorScheme.onSurfaceVariant,
                               fontSize: isCompact ? 10 : 12,
                             ),
                             alignment: Alignment.topLeft,
                           ),
                         ),
                     ],
                   ),
                   lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: theme.colorScheme.primary,
                      barWidth: isCompact ? 1.5 : 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          final total = dailyTotals[days[index]] ?? 0.0;
                          if (total == 0) return FlDotCirclePainter(
                            radius: 0,
                            color: Colors.transparent,
                          );
                          
                          // Check if this is today's data point (last index)
                          final isToday = index == days.length - 1;
                          
                          // Only show dot for today's data point
                          if (!isToday) {
                            return FlDotCirclePainter(
                              radius: 0,
                              color: Colors.transparent,
                            );
                          }
                          
                          return FlDotCirclePainter(
                            radius: isCompact ? 4 : 4,
                            color: theme.colorScheme.onSurface,
                            strokeWidth: 2,
                            strokeColor: theme.colorScheme.primary,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: false,
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        cutOffY: 0,
                        applyCutOffY: true,
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: isCompact ? 40 : 30,
                        interval: isCompact ? 1 : (days.length > 15 ? 5 : 2),
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= days.length) return const Text('');
                          final day = days[index];
                          
                          // Get first letter of day of week
                          final dayOfWeek = DateFormat('E').format(day);
                          final dayLetter = dayOfWeek.substring(0, 1).toUpperCase();
                          
                          return Padding(
                            padding: EdgeInsets.only(top: isCompact ? 24 : 8),
                            child: Text(
                              dayLetter,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: isCompact ? 10 : null,
                              ),
                            ),
                          );
                        },
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
                  gridData: FlGridData(
                    show: !isCompact,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    horizontalInterval: chartMaxY == 0 ? 20 : chartMaxY / 4,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: theme.colorScheme.onSurface.withOpacity(0.9),
                      tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      tooltipMargin: 8,
                      tooltipRoundedRadius: 12,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((touchedSpot) {
                          final index = touchedSpot.x.toInt();
                          if (index < 0 || index >= days.length) return null;
                          final day = days[index];
                          final total = dailyTotals[day] ?? 0.0;
                          if (total == 0) return null;
                          final dateFormat = isCompact 
                            ? DateFormat('MMM d')
                            : DateFormat('MMM d');
                          return LineTooltipItem(
                            '${dateFormat.format(day)}\n${_formatAmount(total)}',
                            theme.textTheme.labelSmall!.copyWith(
                              color: theme.colorScheme.surface,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          );
                        }).toList();
                      },
                    ),
                                     ),
                 ),
               );

    if (isCompact) {
      return chartWidget;
    }

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCompact ? 'Last 14 Days' : 'Daily Spending Trend',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: isCompact ? 3.0 : 2.5,
              child: chartWidget,
            ),
          ],
        ),
      ),
    );
  }
} 