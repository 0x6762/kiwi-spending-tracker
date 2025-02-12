import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/account.dart';
import '../utils/formatters.dart';
import '../providers/category_provider.dart';
import '../repositories/category_repository.dart';

class ExpenseList extends StatefulWidget {
  final List<Expense> expenses;
  final void Function(Expense expense)? onTap;
  final void Function(Expense expense)? onDelete;
  final ScrollController? scrollController;
  final bool shrinkWrap;

  const ExpenseList({
    super.key,
    required this.expenses,
    this.onTap,
    this.onDelete,
    this.scrollController,
    this.shrinkWrap = false,
  });

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  final _dateFormat = DateFormat.yMMMd();
  late Future<CategoryRepository> _categoryRepoFuture;

  @override
  void initState() {
    super.initState();
    _categoryRepoFuture = CategoryProvider.getInstance();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final expenseDate = DateTime(date.year, date.month, date.day);

    if (expenseDate == today) {
      return 'Today';
    } else if (expenseDate == yesterday) {
      return 'Yesterday';
    } else {
      return _dateFormat.format(date);
    }
  }

  List<Expense> get _sortedExpenses {
    return [...widget.expenses]..sort((a, b) {
        // First compare by date
        final dateComparison = b.date.compareTo(a.date);
        if (dateComparison != 0) {
          return dateComparison;
        }
        // If same date, compare by creation time
        return b.createdAt.compareTo(a.createdAt);
      });
  }

  Widget _buildExpenseItem(BuildContext context, Expense expense) {
    return FutureBuilder<ExpenseCategory?>(
      future: _categoryRepoFuture.then((repo) =>
        expense.category != null ? repo.findCategoryByName(expense.category!) : null
      ),
      builder: (context, snapshot) {
        final category = snapshot.data;
        final account = DefaultAccounts.defaultAccounts
            .firstWhere(
              (a) => a.id == expense.accountId,
              orElse: () => DefaultAccounts.checking,
            );

        return Dismissible(
          key: Key(expense.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Theme.of(context).colorScheme.surfaceContainer,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
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
          },
          onDismissed: (_) {
            if (widget.onDelete != null) {
              widget.onDelete!(expense);
            }
          },
          child: ListTile(
            onTap: widget.onTap != null ? () => widget.onTap!(expense) : null,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                category?.icon ?? Icons.category_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            title: Text(expense.title),
            subtitle: Text(
              '${_formatDate(expense.date)} • ${account.name}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Text(
              formatCurrency(expense.amount),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenses = _sortedExpenses;

    if (expenses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text('No expenses yet'),
        ),
      );
    }

    return ListView.builder(
      controller: widget.scrollController,
      shrinkWrap: true, // This ensures the list takes only the space it needs
      physics: const NeverScrollableScrollPhysics(), // Disable scrolling within the list
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        final isFirstItem = index == 0;
        final isLastItem = index == expenses.length - 1;
        final previousDate = !isFirstItem ? expenses[index - 1].date : null;
        final showDateHeader = isFirstItem || 
          previousDate == null || 
          !isSameDay(expense.date, previousDate);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader) ...[
              if (!isFirstItem) const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text(
                  _formatDate(expense.date),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            Card(
              margin: EdgeInsets.zero,
              child: _buildExpenseItem(context, expense),
            ),
            if (!isLastItem) const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
}
