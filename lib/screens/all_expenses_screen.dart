import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../repositories/category_repository.dart';
import '../repositories/expense_repository.dart';
import '../repositories/account_repository.dart';
import '../widgets/expense/lazy_loading_expense_list.dart';
import '../widgets/common/app_bar.dart';
import 'expense_detail_screen.dart';

class AllExpensesScreen extends StatefulWidget {
  final CategoryRepository categoryRepo;
  final ExpenseRepository repository;
  final AccountRepository accountRepo;
  final void Function(Expense) onDelete;
  final void Function() onExpenseUpdated;

  const AllExpensesScreen({
    super.key,
    required this.categoryRepo,
    required this.repository,
    required this.accountRepo,
    required this.onDelete,
    required this.onExpenseUpdated,
  });

  @override
  State<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends State<AllExpensesScreen> {
  void _viewExpenseDetails(Expense expense) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailScreen(
          expense: expense,
          categoryRepo: widget.categoryRepo,
          accountRepo: widget.accountRepo,
          onExpenseUpdated: (updatedExpense) async {
            await widget.repository.updateExpense(updatedExpense);
            // Notify parent to update its state
            widget.onExpenseUpdated();
          },
        ),
      ),
    );

    if (result == true) {
      await widget.repository.deleteExpense(expense.id);
      widget.onDelete(expense);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: KiwiAppBar(
        title: 'All Expenses',
        leading: const Icon(Icons.arrow_back),
      ),
      body: LazyLoadingExpenseList(
        expenseRepo: widget.repository,
        categoryRepo: widget.categoryRepo,
        onTap: _viewExpenseDetails,
        onDelete: widget.onDelete,
        groupByDate: true,
        pageSize: 10,
      ),
    );
  }
} 