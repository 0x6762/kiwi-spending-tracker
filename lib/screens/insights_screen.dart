import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../repositories/category_repository.dart';
import '../services/expense_analytics_service.dart';
import '../widgets/category_statistics.dart';
import '../widgets/expense_summary.dart';

class InsightsScreen extends StatefulWidget {
  final List<Expense> expenses;
  final CategoryRepository categoryRepo;
  final ExpenseAnalyticsService analyticsService;

  const InsightsScreen({
    super.key,
    required this.expenses,
    required this.categoryRepo,
    required this.analyticsService,
  });

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  late DateTime _selectedMonth;
  final _monthFormat = DateFormat.yMMMM();

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  List<Expense> get _filteredExpenses {
    return widget.expenses.where((expense) =>
        expense.date.year == _selectedMonth.year &&
        expense.date.month == _selectedMonth.month).toList();
  }

  void _showMonthPicker() async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return MonthPickerDialog(
          selectedMonth: _selectedMonth,
          expenses: widget.expenses,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: theme.colorScheme.surface,
        title: TextButton(
          onPressed: _showMonthPicker,
          style: TextButton.styleFrom(
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurfaceVariant,
            padding: const EdgeInsets.only(
              left: 8,
              right: 10,
              top: 8,
              bottom: 8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _monthFormat.format(_selectedMonth),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExpenseSummary(
              expenses: widget.expenses,
              selectedMonth: _selectedMonth,
              onMonthSelected: (month) {
                setState(() {
                  _selectedMonth = month;
                });
              },
              analyticsService: widget.analyticsService,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Text(
                'Spending by Category',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            CategoryStatistics(
              expenses: _filteredExpenses,
              categoryRepo: widget.categoryRepo,
              analyticsService: widget.analyticsService,
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
          ],
        ),
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
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surfaceContainer,
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
                    style: theme.textTheme.titleLarge,
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
