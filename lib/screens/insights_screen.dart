import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/account.dart';
import '../utils/formatters.dart';
import '../widgets/picker_sheet.dart';
import '../widgets/add_category_sheet.dart';
import '../screens/settings_screen.dart';
import '../repositories/category_repository.dart';

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
  final _monthFormat = DateFormat.yMMMM();
  late DateTime _selectedMonth;
  bool? _selectedExpenseType; // null for all, true for fixed, false for variable
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

  Map<String, double> _getCategoryTotals() {
    final Map<String, double> totals = {};
    final monthExpenses = _filteredExpenses;
    final double totalSpent =
        monthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

    // First calculate raw totals
    for (final expense in monthExpenses) {
      if (expense.categoryId != null) {
        totals[expense.categoryId!] =
            (totals[expense.categoryId!] ?? 0.0) + expense.amount;
      } else {
        totals['uncategorized'] =
            (totals['uncategorized'] ?? 0.0) + expense.amount;
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
      BuildContext context, String categoryId, double percentage, double amount) {
    final theme = Theme.of(context);
    
    return FutureBuilder<ExpenseCategory?>(
      future: widget.categoryRepo.findCategoryById(categoryId),
      builder: (context, snapshot) {
        final categoryInfo = snapshot.data;
        final categoryName = categoryInfo?.name ?? 'Uncategorized';
        
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
              child: Text(
                categoryName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
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
          ],
        );
      },
    );
  }

  void _onMonthSelected(DateTime month) {
    setState(() {
      _selectedMonth = month;
    });
  }

  void _showAddCategorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCategorySheet(
        categoryRepo: widget.categoryRepo,
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
      title: 'Expense Type',
      children: [
        ListTile(
          title: const Text('All'),
          selected: _selectedExpenseType == null,
          onTap: () {
            setState(() => _selectedExpenseType = null);
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('Fixed'),
          selected: _selectedExpenseType == true,
          onTap: () {
            setState(() => _selectedExpenseType = true);
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('Variable'),
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
          title: const Text('All Accounts'),
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
      padding: const EdgeInsets.symmetric(horizontal: 8),
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

  Widget _buildHeader() {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
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
    final theme = Theme.of(context);
    final categoryTotals = _getCategoryTotals();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              padding: const EdgeInsets.symmetric(horizontal: 8),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  ...categoryTotals.entries.map((entry) {
                    final amount = _filteredExpenses
                        .where((e) =>
                            e.categoryId == entry.key ||
                            (entry.key == 'uncategorized' &&
                                e.categoryId == null))
                        .fold(0.0, (sum, e) => sum + e.amount);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        margin: EdgeInsets.zero,
                        color: theme.colorScheme.surfaceContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
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
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
                ]),
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
