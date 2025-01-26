import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/account.dart';
import '../utils/formatters.dart';
import '../widgets/expense_summary.dart';
import '../widgets/add_category_sheet.dart';
import '../widgets/picker_button.dart';
import '../widgets/picker_sheet.dart';
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
  bool?
      _selectedExpenseType; // null for all, true for fixed, false for variable
  String? _selectedAccountId;

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

  Map<String, double> _getCategoryTotals() {
    final Map<String, double> totals = {};
    final monthExpenses = _filteredExpenses;
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

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
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

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? trailingIcon,
  }) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: onTap,
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
          Text(label),
          if (trailingIcon != null) ...[
            const SizedBox(width: 4),
            Icon(trailingIcon, size: 18),
          ],
        ],
      ),
    );
  }

  void _showExpenseTypeSheet() {
    PickerSheet.show(
      context: context,
      title: 'Select Type',
      children: [
        ListTile(
          title: Text('All Types'),
          selected: _selectedExpenseType == null,
          onTap: () {
            setState(() => _selectedExpenseType = null);
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: Text('Fixed'),
          selected: _selectedExpenseType == true,
          onTap: () {
            setState(() => _selectedExpenseType = true);
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: Text('Variable'),
          selected: _selectedExpenseType == false,
          onTap: () {
            setState(() => _selectedExpenseType = false);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void _showAccountSheet() {
    PickerSheet.show(
      context: context,
      title: 'Select Account',
      children: [
        ListTile(
          title: Text('All Accounts'),
          selected: _selectedAccountId == null,
          onTap: () {
            setState(() => _selectedAccountId = null);
            Navigator.pop(context);
          },
        ),
        ...DefaultAccounts.defaultAccounts.map(
          (account) => ListTile(
            leading: Icon(account.icon, color: account.color),
            title: Text(account.name),
            selected: _selectedAccountId == account.id,
            onTap: () {
              setState(() => _selectedAccountId = account.id);
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    String expenseTypeLabel = 'All Types';
    if (_selectedExpenseType == true) expenseTypeLabel = 'Fixed';
    if (_selectedExpenseType == false) expenseTypeLabel = 'Variable';

    String accountLabel = 'All Accounts';
    if (_selectedAccountId != null) {
      accountLabel = DefaultAccounts.defaultAccounts
          .firstWhere((a) => a.id == _selectedAccountId)
          .name;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Month filter
          _buildFilterChip(
            label: _monthFormat.format(_selectedMonth),
            selected: true,
            trailingIcon: Icons.keyboard_arrow_down,
            onTap: () async {
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
                _onMonthSelected(picked);
              }
            },
          ),
          const SizedBox(width: 8),
          // Expense type filter
          _buildFilterChip(
            label: expenseTypeLabel,
            selected: true,
            trailingIcon: Icons.keyboard_arrow_down,
            onTap: _showExpenseTypeSheet,
          ),
          const SizedBox(width: 8),
          // Account filter
          _buildFilterChip(
            label: accountLabel,
            selected: true,
            trailingIcon: Icons.keyboard_arrow_down,
            onTap: _showAccountSheet,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryTotals = _getCategoryTotals();

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildFilterRow(),
                  const SizedBox(height: 16),
                ],
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
                    ...categoryTotals.entries.map((entry) {
                      final amount = _filteredExpenses
                          .where((e) =>
                              e.category == entry.key ||
                              (entry.key == 'Uncategorized' &&
                                  e.category == null))
                          .fold(0.0, (sum, e) => sum + e.amount);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          color: theme.colorScheme.surfaceContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: _buildCategoryRow(
                              context,
                              entry.key,
                              entry.value,
                              amount,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    // Add bottom padding for navigation bar
                    SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 80),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
