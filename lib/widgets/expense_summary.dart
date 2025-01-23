import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/expense.dart';
import 'monthly_expense_chart.dart';

class ExpenseSummary extends StatefulWidget {
  final List<Expense> expenses;
  final void Function(DateTime selectedMonth) onMonthSelected;
  final DateTime selectedMonth;

  const ExpenseSummary({
    super.key,
    required this.expenses,
    required this.onMonthSelected,
    required this.selectedMonth,
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

  void _showMonthPicker() async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return MonthPickerDialog(
          selectedMonth: widget.selectedMonth,
          expenses: widget.expenses,
        );
      },
    );

    if (picked != null) {
      widget.onMonthSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _showMonthPicker,
              style: TextButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainer,
                foregroundColor: theme.colorScheme.onSurfaceVariant,
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 10,
                  top: 8,
                  bottom: 8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_monthFormat.format(widget.selectedMonth)),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Column(
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
                '\$${_monthlyTotal.toStringAsFixed(2)}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          MonthlyExpenseChart(
            expenses: widget.expenses,
            selectedMonth: widget.selectedMonth,
            onMonthSelected: widget.onMonthSelected,
          ),
          const SizedBox(height: 32),
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
            '\$${amount.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class MonthPickerDialog extends StatelessWidget {
  final DateTime selectedMonth;
  final List<Expense> expenses;

  const MonthPickerDialog({
    super.key,
    required this.selectedMonth,
    required this.expenses,
  });

  List<DateTime> get _availableMonths {
    final months = expenses
        .map((e) => DateTime(e.date.year, e.date.month))
        .toSet()
        .toList();
    months.sort((a, b) => b.compareTo(a)); // Most recent first
    return months;
  }

  @override
  Widget build(BuildContext context) {
    final monthFormat = DateFormat.yMMMM();
    final months = _availableMonths;

    return Dialog(
      backgroundColor: Theme.of(context)
          .colorScheme
          .surfaceContainer, //select month top picker background color
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Month',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: months.length,
                itemBuilder: (context, index) {
                  final month = months[index];
                  final isSelected = month.year == selectedMonth.year &&
                      month.month == selectedMonth.month;

                  return ListTile(
                    title: Text(monthFormat.format(month)),
                    selected: isSelected,
                    onTap: () => Navigator.pop(context, month),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
