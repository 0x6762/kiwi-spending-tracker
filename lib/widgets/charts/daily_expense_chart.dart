import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../services/expense_analytics_service.dart';
import '../../utils/formatters.dart';

class PulsingDotPainter extends FlDotPainter {
  final double radius;
  final Color color;
  final double pulseValue;
  final bool isToday;

  PulsingDotPainter({
    required this.radius,
    required this.color,
    required this.pulseValue,
    required this.isToday,
  });

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    if (!isToday) {
      // Draw regular dot for non-today points
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(offsetInCanvas, radius, paint);
      return;
    }

    // Draw pulsing background for today's point
    final pulseRadius =
        radius + (pulseValue * 12.0); // Increased from 6.0 to 12.0
    final pulseOpacity = 0.5 * (1.0 - pulseValue); // Increased from 0.3 to 0.5

    final pulsePaint = Paint()
      ..color = color.withOpacity(pulseOpacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(offsetInCanvas, pulseRadius, pulsePaint);

    // Draw the main dot
    final mainPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(offsetInCanvas, radius, mainPaint);
  }

  @override
  Size getSize(FlSpot spot) {
    final maxRadius =
        isToday ? radius + 12.0 : radius; // Updated to match new pulse radius
    return Size(maxRadius * 2, maxRadius * 2);
  }

  @override
  List<Object?> get props => [radius, color, pulseValue, isToday];
}

class DailyExpenseChart extends StatefulWidget {
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

  @override
  State<DailyExpenseChart> createState() => _DailyExpenseChartState();
}

class _DailyExpenseChartState extends State<DailyExpenseChart>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(
          milliseconds: 2000), // Increased duration to include pause
      vsync: this,
    )..repeat();
    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: const Interval(0.0, 0.6,
          curve: Curves.easeOut), // Animation happens in first 60%, then pause
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  List<DateTime> _getDaysInMonth() {
    // Show last 6 days + today + next day (8 total days)
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    return List.generate(8, (index) {
      if (index < 7) {
        // First 7 days: last 6 days + today
        return todayOnly.subtract(Duration(days: 6 - index));
      } else {
        // 8th day: tomorrow
        return todayOnly.add(const Duration(days: 1));
      }
    });
  }

  Map<DateTime, double> _getDailyTotals() {
    final days = _getDaysInMonth();
    final dailyTotals = <DateTime, double>{};

    for (final day in days) {
      dailyTotals[day] = 0.0;
    }

    for (final expense in widget.expenses) {
      final dayKey =
          DateTime(expense.date.year, expense.date.month, expense.date.day);
      if (dailyTotals.containsKey(dayKey)) {
        dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0.0) + expense.amount;
      }
    }

    return dailyTotals;
  }

  String _formatAmount(double amount) {
    if (amount < 1000) {
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

    // Create line chart spots (only up to today, not including tomorrow)
    final spots = days.asMap().entries.take(7).map((entry) {
      final index = entry.key;
      final day = entry.value;
      final total = dailyTotals[day] ?? 0.0;
      return FlSpot(index.toDouble(), total);
    }).toList();

    final avgValue = widget.dailyAverage ?? 0.0;
    final chartMaxY = maxTotal == 0
        ? 100.0
        : (maxTotal > avgValue ? maxTotal * 1.1 : avgValue * 1.2);

    final chartWidget = AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return LineChart(
          LineChartData(
            minX: 0,
            maxX: (days.length - 1).toDouble(),
            minY: 0,
            maxY: chartMaxY,
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                // Daily average line
                if (avgValue > 0)
                  HorizontalLine(
                    y: avgValue,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                    strokeWidth: 1,
                    dashArray: [1, 5],
                    label: HorizontalLineLabel(
                      show: false,
                      labelResolver: (line) =>
                          widget.isCompact ? 'Avg' : 'Weekly Average',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: widget.isCompact ? 10 : 12,
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
                barWidth: widget.isCompact ? 1.5 : 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    // Check if this is today's data point (7th index, 0-based = 6)
                    final isToday = index == 6;

                    // Always show dot for today's data point, even if no expenses
                    if (isToday) {
                      return PulsingDotPainter(
                        radius: widget.isCompact ? 4 : 4,
                        color: theme.colorScheme.primary,
                        pulseValue: _pulseAnimation.value,
                        isToday: isToday,
                      );
                    }

                    // For other days, don't show dots by default (only on touch)
                    return FlDotCirclePainter(
                      radius: 0,
                      color: Colors.transparent,
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
                  reservedSize: widget.isCompact ? 40 : 30,
                  interval: 1, // Show all 7 days
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= days.length)
                      return const Text('');
                    final day = days[index];

                    final dayOfWeek = DateFormat('E').format(day);
                    final dayLetter = dayOfWeek.substring(0, 1).toUpperCase();

                    // Check if this is today
                    final today = DateTime.now();
                    final isToday = day.year == today.year &&
                        day.month == today.month &&
                        day.day == today.day;

                    return Padding(
                      padding: EdgeInsets.only(top: widget.isCompact ? 24 : 8),
                      child: Text(
                        dayLetter,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isToday
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.7),
                          fontSize: widget.isCompact ? 10 : null,
                          fontWeight: isToday ? FontWeight.w600 : null,
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
              show: !widget.isCompact,
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
              getTouchedSpotIndicator:
                  (LineChartBarData barData, List<int> spotIndexes) {
                return spotIndexes.map((index) {
                  return TouchedSpotIndicatorData(
                    FlLine(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      strokeWidth: 2,
                      dashArray: [3, 3],
                    ),
                    FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: widget.isCompact ? 6 : 8,
                          color: theme.colorScheme.primary,
                          strokeWidth: 0,
                          strokeColor: theme.colorScheme.surface,
                        );
                      },
                    ),
                  );
                }).toList();
              },
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: theme.colorScheme.onSurface.withOpacity(0.9),
                tooltipPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                tooltipMargin: 8,
                tooltipRoundedRadius: 12,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((touchedSpot) {
                    final index = touchedSpot.x.toInt();
                    if (index < 0 || index >= days.length) return null;
                    final day = days[index];
                    final total = dailyTotals[day] ?? 0.0;
                    if (total == 0) return null;
                    final dateFormat = widget.isCompact
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
      },
    );

    if (widget.isCompact) {
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
              'Past Week + Today',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: widget.isCompact ? 3.0 : 3.2,
              child: chartWidget,
            ),
          ],
        ),
      ),
    );
  }
}
