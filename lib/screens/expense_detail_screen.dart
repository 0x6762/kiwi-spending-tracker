import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/account.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/formatters.dart';
import '../utils/icons.dart';
import '../repositories/category_repository.dart';
import '../repositories/account_repository.dart';
import '../widgets/common/app_bar.dart';
import '../widgets/dialogs/delete_confirmation_dialog.dart';
import 'multi_step_expense/multi_step_expense_screen.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final Expense expense;
  final CategoryRepository categoryRepo;
  final AccountRepository accountRepo;
  final Function(Expense)? onExpenseUpdated;

  const ExpenseDetailScreen({
    super.key,
    required this.expense,
    required this.categoryRepo,
    required this.accountRepo,
    this.onExpenseUpdated,
  });

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  final _dateFormat = DateFormat.yMMMd();
  late Expense _currentExpense;

  @override
  void initState() {
    super.initState();
    _currentExpense = widget.expense;
  }

  void _showEditExpenseDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) =>
          MultiStepExpenseScreen(
        categoryRepo: widget.categoryRepo,
        accountRepo: widget.accountRepo,
        expense: _currentExpense,
        onExpenseAdded: (updatedExpense) {
          setState(() {
            _currentExpense = updatedExpense;
          });
          widget.onExpenseUpdated?.call(updatedExpense);
        },
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

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

  String _getNecessityLabel(ExpenseNecessity necessity) {
    switch (necessity) {
      case ExpenseNecessity.essential:
        return 'Essential (Need)';
      case ExpenseNecessity.extra:
        return 'Extra (Want)';
      case ExpenseNecessity.savings:
        return 'Savings/Investment';
    }
  }

  IconData _getNecessityIcon(ExpenseNecessity necessity) {
    switch (necessity) {
      case ExpenseNecessity.essential:
        return Icons.home_outlined;
      case ExpenseNecessity.extra:
        return Icons.shopping_bag_outlined;
      case ExpenseNecessity.savings:
        return Icons.savings_outlined;
    }
  }

  String _getFrequencyLabel(ExpenseFrequency frequency) {
    switch (frequency) {
      case ExpenseFrequency.oneTime:
        return 'One-time';
      case ExpenseFrequency.daily:
        return 'Daily';
      case ExpenseFrequency.weekly:
        return 'Weekly';
      case ExpenseFrequency.biWeekly:
        return 'Bi-weekly';
      case ExpenseFrequency.monthly:
        return 'Monthly';
      case ExpenseFrequency.quarterly:
        return 'Quarterly';
      case ExpenseFrequency.yearly:
        return 'Yearly';
      case ExpenseFrequency.custom:
        return 'Custom';
    }
  }

  String _getStatusLabel(ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.pending:
        return 'Pending';
      case ExpenseStatus.paid:
        return 'Paid';
      case ExpenseStatus.overdue:
        return 'Overdue';
      case ExpenseStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.pending:
        return Colors.orange;
      case ExpenseStatus.paid:
        return Colors.green;
      case ExpenseStatus.overdue:
        return Colors.red;
      case ExpenseStatus.cancelled:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<Account?>(
      future: widget.accountRepo.findAccountById(_currentExpense.accountId),
      builder: (context, accountSnapshot) {
        final account = accountSnapshot.data ?? DefaultAccounts.checking;

        return FutureBuilder<ExpenseCategory?>(
          future: _currentExpense.categoryId != null
              ? widget.categoryRepo
                  .findCategoryById(_currentExpense.categoryId!)
              : Future.value(null),
          builder: (context, categorySnapshot) {
            final category = categorySnapshot.data;

            return Scaffold(
              backgroundColor: theme.colorScheme.surface,
              appBar: KiwiAppBar(
                title: 'Expense Details',
                leading: const Icon(AppIcons.back),
                actions: [
                  IconButton(
                    icon: const Icon(AppIcons.edit),
                    onPressed: _showEditExpenseDialog,
                  ),
                  IconButton(
                    icon: Icon(
                      AppIcons.delete,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: () async {
                      final shouldDelete =
                          await DeleteConfirmationDialog.show(context);
                      if (shouldDelete == true && mounted) {
                        Navigator.pop(context, true);
                      }
                    },
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentExpense.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formatCurrency(_currentExpense.amount),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                              category?.name ??
                                  CategoryRepository.uncategorizedCategory.name,
                              category?.icon ??
                                  CategoryRepository.uncategorizedCategory.icon,
                            ),
                            _buildDetailRow(
                              'Account',
                              account.name,
                              account.icon,
                              iconColor: account.color,
                            ),
                            _buildDetailRow(
                              'Date',
                              _dateFormat.format(_currentExpense.date),
                              AppIcons.calendar,
                            ),
                            _buildDetailRow(
                              'Time Added',
                              DateFormat.jm().format(_currentExpense.createdAt),
                              AppIcons.time,
                            ),
                            if (_currentExpense.notes != null &&
                                _currentExpense.notes!.isNotEmpty)
                              _buildDetailRow(
                                'Notes',
                                _currentExpense.notes!,
                                AppIcons.notes,
                              ),
                            _buildDetailRow(
                              'Necessity',
                              _getNecessityLabel(_currentExpense.necessity),
                              _getNecessityIcon(_currentExpense.necessity),
                            ),
                            _buildDetailRow(
                              'Frequency',
                              _getFrequencyLabel(_currentExpense.frequency),
                              Icons.repeat,
                            ),
                            _buildDetailRow(
                              'Status',
                              _getStatusLabel(_currentExpense.status),
                              Icons.check_circle_outline,
                              iconColor:
                                  _getStatusColor(_currentExpense.status),
                            ),
                            if (_currentExpense.isRecurring)
                              _buildDetailRow(
                                'Recurring',
                                'Yes',
                                Icons.autorenew,
                              ),
                            if (_currentExpense.paymentMethod != null)
                              _buildDetailRow(
                                'Payment Method',
                                _currentExpense.paymentMethod!,
                                Icons.payment,
                              ),
                            if (_currentExpense.tags != null &&
                                _currentExpense.tags!.isNotEmpty)
                              _buildDetailRow(
                                'Tags',
                                _currentExpense.tags!.join(', '),
                                Icons.tag,
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
      },
    );
  }
}
