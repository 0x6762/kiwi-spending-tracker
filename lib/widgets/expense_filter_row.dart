import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/account.dart';
import 'picker_sheet.dart';

class ExpenseFilterRow extends StatelessWidget {
  final DateTime selectedMonth;
  final bool? selectedExpenseType;
  final String? selectedAccountId;
  final List<Expense> expenses;
  final ValueChanged<DateTime> onMonthSelected;
  final ValueChanged<bool?> onExpenseTypeSelected;
  final ValueChanged<String?> onAccountSelected;

  const ExpenseFilterRow({
    super.key,
    required this.selectedMonth,
    required this.selectedExpenseType,
    required this.selectedAccountId,
    required this.expenses,
    required this.onMonthSelected,
    required this.onExpenseTypeSelected,
    required this.onAccountSelected,
  });

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? trailingIcon,
  }) {
    return Builder(
      builder: (context) {
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
    );
  }

  void _showExpenseTypeSheet(BuildContext context) {
    PickerSheet.show(
      context: context,
      title: 'Expense Type',
      children: [
        ListTile(
          title: const Text('All'),
          selected: selectedExpenseType == null,
          onTap: () {
            onExpenseTypeSelected(null);
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('Fixed'),
          selected: selectedExpenseType == true,
          onTap: () {
            onExpenseTypeSelected(true);
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('Variable'),
          selected: selectedExpenseType == false,
          onTap: () {
            onExpenseTypeSelected(false);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void _showAccountSheet(BuildContext context) {
    PickerSheet.show(
      context: context,
      title: 'Select Account',
      children: [
        ListTile(
          title: const Text('All Accounts'),
          selected: selectedAccountId == null,
          onTap: () {
            onAccountSelected(null);
            Navigator.pop(context);
          },
        ),
        ...DefaultAccounts.defaultAccounts.map(
          (account) => ListTile(
            leading: Icon(account.icon, color: account.color),
            title: Text(account.name),
            selected: selectedAccountId == account.id,
            onTap: () {
              onAccountSelected(account.id);
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthFormat = DateFormat.yMMMM();
    String expenseTypeLabel = 'All Types';
    if (selectedExpenseType == true) expenseTypeLabel = 'Fixed';
    if (selectedExpenseType == false) expenseTypeLabel = 'Variable';

    String accountLabel = 'All Accounts';
    if (selectedAccountId != null) {
      accountLabel = DefaultAccounts.defaultAccounts
          .firstWhere((a) => a.id == selectedAccountId)
          .name;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Month filter
          _buildFilterChip(
            label: monthFormat.format(selectedMonth),
            selected: true,
            trailingIcon: Icons.keyboard_arrow_down,
            onTap: () async {
              final DateTime? picked = await showDialog<DateTime>(
                context: context,
                builder: (BuildContext context) {
                  return MonthPickerDialog(
                    selectedMonth: selectedMonth,
                    expenses: expenses,
                  );
                },
              );
              if (picked != null) {
                onMonthSelected(picked);
              }
            },
          ),
          const SizedBox(width: 8),
          // Expense type filter
          _buildFilterChip(
            label: expenseTypeLabel,
            selected: true,
            trailingIcon: Icons.keyboard_arrow_down,
            onTap: () => _showExpenseTypeSheet(context),
          ),
          const SizedBox(width: 8),
          // Account filter
          _buildFilterChip(
            label: accountLabel,
            selected: true,
            trailingIcon: Icons.keyboard_arrow_down,
            onTap: () => _showAccountSheet(context),
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