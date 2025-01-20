import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

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
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Total',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: _showMonthPicker,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(_monthFormat.format(widget.selectedMonth)),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '\$${_monthlyTotal.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const Divider(height: 24),
            _SummaryRow(
              label: 'Fixed Expenses',
              amount: _fixedTotal,
              context: context,
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Variable Expenses',
              amount: _variableTotal,
              context: context,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final BuildContext context;

  const _SummaryRow({
    required this.label,
    required this.amount,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
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
