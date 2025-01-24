import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/account.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/formatters.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;
  late final DateFormat _dateFormat;
  late final DateFormat _timeFormat;

  ExpenseDetailScreen({
    super.key,
    required this.expense,
  }) {
    _dateFormat = DateFormat.yMMMMd();
    _timeFormat = DateFormat.jm();
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Expense'),
            content:
                const Text('Are you sure you want to delete this expense?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      // Pop twice to go back to the main screen and return true to indicate deletion
      Navigator.of(context).pop(true);
    }
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value,
      {IconData? icon, Color? iconColor, Widget? customIcon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          if (customIcon != null) ...[
            customIcon,
            const SizedBox(width: 16),
          ] else if (icon != null) ...[
            Icon(
              icon,
              size: 24,
              color: iconColor ?? theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = expense.category != null
        ? ExpenseCategories.findByName(expense.category!)
        : null;
    final account = DefaultAccounts.defaultAccounts
        .firstWhere((a) => a.id == expense.accountId);

    final isFixed = expense.isFixed;
    final expenseTypeColor =
        isFixed ? const Color(0xFFCF5825) : const Color(0xFF8056E4);
    final expenseTypeIcon = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: expenseTypeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SvgPicture.asset(
        isFixed
            ? 'assets/icons/fixed_expense.svg'
            : 'assets/icons/variable_expense.svg',
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(
          expenseTypeColor,
          BlendMode.srcIn,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'Expense Details',
          style: theme.textTheme.titleMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implement edit functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: theme.colorScheme.surfaceVariant,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    formatCurrency(expense.amount),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    expense.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        theme,
                        'Account',
                        account.name,
                        icon: account.icon,
                        iconColor: account.color,
                      ),
                      if (category != null)
                        _buildDetailRow(
                          theme,
                          'Category',
                          category.name,
                          icon: category.icon,
                        ),
                      _buildDetailRow(
                        theme,
                        'Date',
                        _dateFormat.format(expense.date),
                        icon: Icons.calendar_today,
                      ),
                      _buildDetailRow(
                        theme,
                        'Time',
                        _timeFormat.format(expense.createdAt),
                        icon: Icons.access_time,
                      ),
                      _buildDetailRow(
                        theme,
                        'Type',
                        expense.isFixed ? 'Fixed Expense' : 'Variable Expense',
                        customIcon: expenseTypeIcon,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
