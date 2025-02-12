import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../repositories/category_repository.dart';
import '../widgets/category_statistics.dart';
import '../widgets/expense_filter_row.dart';
import 'settings_screen.dart';

class InsightsScreen extends StatefulWidget {
  final List<Expense> expenses;
  final CategoryRepository categoryRepo;

  const InsightsScreen({
    super.key,
    required this.expenses,
    required this.categoryRepo,
  });

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  late DateTime _selectedMonth;
  bool? _selectedExpenseType;
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  List<Expense> get _filteredExpenses {
    return widget.expenses.where((expense) {
      // Filter by month
      final isMonthMatch = expense.date.year == _selectedMonth.year &&
          expense.date.month == _selectedMonth.month;

      // Filter by expense type
      final isTypeMatch = _selectedExpenseType == null ||
          expense.isFixed == _selectedExpenseType;

      // Filter by account
      final isAccountMatch =
          _selectedAccountId == null || expense.accountId == _selectedAccountId;

      return isMonthMatch && isTypeMatch && isAccountMatch;
    }).toList();
  }

  Widget _buildHeader() {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 8, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  'Insights',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.more_horiz,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(
                        categoryRepo: widget.categoryRepo,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExpenseFilterRow(
                  selectedMonth: _selectedMonth,
                  selectedExpenseType: _selectedExpenseType,
                  selectedAccountId: _selectedAccountId,
                  expenses: widget.expenses,
                  onMonthSelected: (month) => setState(() => _selectedMonth = month),
                  onExpenseTypeSelected: (type) => setState(() => _selectedExpenseType = type),
                  onAccountSelected: (id) => setState(() => _selectedAccountId = id),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverToBoxAdapter(
              child: CategoryStatistics(
                expenses: _filteredExpenses,
                categoryRepo: widget.categoryRepo,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.bottom + 0),
          ),
        ],
      ),
    );
  }
}
