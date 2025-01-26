import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../utils/formatters.dart';
import '../widgets/expense_summary.dart';
import '../widgets/add_category_sheet.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesScreen extends StatefulWidget {
  final List<Expense> expenses;

  const CategoriesScreen({
    super.key,
    required this.expenses,
  });

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _monthFormat = DateFormat.yMMMM();
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _loadCustomCategories();
  }

  Future<void> _loadCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await ExpenseCategories.loadCustomCategories(prefs);
    if (mounted) {
      setState(() {});
    }
  }

  void _onMonthSelected(DateTime month) {
    setState(() {
      _selectedMonth = month;
    });
  }

  List<Expense> get _monthlyExpenses {
    return widget.expenses
        .where((expense) =>
            expense.date.year == _selectedMonth.year &&
            expense.date.month == _selectedMonth.month)
        .toList();
  }

  Map<String, double> _getCategoryTotals() {
    final Map<String, double> totals = {};
    final monthExpenses = _monthlyExpenses;
    final double totalSpent =
        monthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

    // First calculate raw totals
    for (final expense in monthExpenses) {
      if (expense.category != null) {
        totals[expense.category!] =
            (totals[expense.category!] ?? 0.0) + expense.amount;
      } else {
        totals['Uncategorized'] =
            (totals['Uncategorized'] ?? 0.0) + expense.amount;
      }
    }

    // Convert to percentages
    if (totalSpent > 0) {
      totals.forEach((category, amount) {
        totals[category] = (amount / totalSpent) * 100;
      });
    }

    // Sort by percentage (descending)
    final sortedEntries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  Widget _buildCategoryRow(
      BuildContext context, String category, double percentage, double amount) {
    final theme = Theme.of(context);
    final categoryInfo = category == 'Uncategorized'
        ? null
        : ExpenseCategories.findByName(category);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              categoryInfo?.icon ?? Icons.category_outlined,
              size: 24,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(amount),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCategorySheet(
        onCategoryAdded: () {
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryTotals = _getCategoryTotals();
    final monthlyTotal =
        _monthlyExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: theme.colorScheme.surface,
              centerTitle: false,
              titleSpacing: 16,
              title: Text(
                'Categories',
                style: theme.textTheme.titleLarge,
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: Icon(
                      Icons.add,
                      color: theme.colorScheme.onSurface,
                    ),
                    onPressed: _showAddCategorySheet,
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: ExpenseSummary(
                expenses: widget.expenses,
                selectedMonth: _selectedMonth,
                onMonthSelected: _onMonthSelected,
                showChart: false,
              ),
            ),
            if (categoryTotals.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No expenses this month',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: categoryTotals.entries.map((entry) {
                            final amount = _monthlyExpenses
                                .where((e) =>
                                    e.category == entry.key ||
                                    (entry.key == 'Uncategorized' &&
                                        e.category == null))
                                .fold(0.0, (sum, e) => sum + e.amount);
                            return _buildCategoryRow(
                              context,
                              entry.key,
                              entry.value,
                              amount,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
