import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/account.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/formatters.dart';
import '../providers/category_provider.dart';
import '../repositories/category_repository.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final Expense expense;

  const ExpenseDetailScreen({
    super.key,
    required this.expense,
  });

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  final _dateFormat = DateFormat.yMMMd();
  late Future<CategoryRepository> _categoryRepoFuture;

  @override
  void initState() {
    super.initState();
    _categoryRepoFuture = CategoryProvider.getInstance();
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

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
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

    return FutureBuilder<CategoryRepository>(
      future: _categoryRepoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final repo = snapshot.data!;
        return FutureBuilder<ExpenseCategory?>(
          future: expense.categoryId != null
              ? repo.findCategoryById(expense.categoryId!)
              : null,
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
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              category?.icon ?? Icons.category_outlined,
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            expense.title,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formatCurrency(expense.amount),
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildDetailRow(
                      'Category',
                      category?.name ?? 'Uncategorized',
                      Icons.category_outlined,
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
                      'Type',
                      expense.isFixed ? 'Fixed' : 'Variable',
                      expense.isFixed
                          ? Icons.repeat_outlined
                          : Icons.sync_outlined,
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
            );
          },
        );
      },
    );
  }
}
