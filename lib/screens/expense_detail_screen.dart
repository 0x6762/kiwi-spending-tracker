import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/account.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/formatters.dart';
import '../repositories/category_repository.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final Expense expense;
  final CategoryRepository categoryRepo;

  const ExpenseDetailScreen({
    super.key,
    required this.expense,
    required this.categoryRepo,
  });

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  final _dateFormat = DateFormat.yMMMd();

  Widget _buildDetailRow(
    String label,
    String value,
    dynamic icon, {
    Color? iconColor,
    bool isSvg = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: isSvg
                ? SvgPicture.asset(
                    icon,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      iconColor ?? theme.colorScheme.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  )
                : Icon(
                    icon as IconData,
                    color: iconColor ?? theme.colorScheme.onSurfaceVariant,
                  ),
          ),
          const SizedBox(width: 16),
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
    final expense = widget.expense;
    final account = DefaultAccounts.defaultAccounts
        .firstWhere(
          (a) => a.id == expense.accountId,
          orElse: () => DefaultAccounts.checking,
        );

    return FutureBuilder<ExpenseCategory?>(
      future: expense.categoryId != null
          ? widget.categoryRepo.findCategoryById(expense.categoryId!)
          : Future.value(null),
      builder: (context, categorySnapshot) {
        final category = categorySnapshot.data;

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.surface,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Expense'),
                          content: const Text(
                              'Are you sure you want to delete this expense?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    theme.colorScheme.error,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ) ??
                      false;

                  if (shouldDelete) {
                    Navigator.pop(context, true);
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        formatCurrency(expense.amount),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        expense.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Card(
                  margin: EdgeInsets.zero,
                  color: theme.colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          'Category',
                          category?.name ?? CategoryRepository.uncategorizedCategory.name,
                          category?.icon ?? CategoryRepository.uncategorizedCategory.icon,
                        ),
                        _buildDetailRow(
                          'Account',
                          account.name,
                          account.icon,
                          iconColor: account.color,
                        ),
                        _buildDetailRow(
                          'Date',
                          _dateFormat.format(expense.date),
                          Icons.calendar_today_outlined,
                        ),
                        _buildDetailRow(
                          'Time Added',
                          DateFormat.jm().format(expense.createdAt),
                          Icons.access_time_outlined,
                        ),
                        _buildDetailRow(
                          'Type',
                          expense.isFixed ? 'Fixed' : 'Variable',
                          expense.isFixed
                              ? 'assets/icons/fixed_expense.svg'
                              : 'assets/icons/variable_expense.svg',
                          iconColor: expense.isFixed
                              ? const Color(0xFFCF5825)  // Fixed expense orange
                              : const Color(0xFF8056E4), // Variable expense purple
                          isSvg: true,
                        ),
                        if (expense.notes != null && expense.notes!.isNotEmpty)
                          _buildDetailRow(
                            'Notes',
                            expense.notes!,
                            Icons.notes_outlined,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
