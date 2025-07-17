import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/account_repository.dart';
import '../widgets/common/app_bar.dart';
import '../widgets/expense/lazy_loading_expense_list.dart';
import '../utils/formatters.dart';
import '../utils/icons.dart';
import 'expense_detail_screen.dart';

class CategoryExpensesScreen extends StatefulWidget {
  final ExpenseRepository repository;
  final CategoryRepository categoryRepo;
  final AccountRepository accountRepo;
  final String categoryId;
  final DateTime selectedMonth;

  const CategoryExpensesScreen({
    super.key,
    required this.repository,
    required this.categoryRepo,
    required this.accountRepo,
    required this.categoryId,
    required this.selectedMonth,
  });

  @override
  State<CategoryExpensesScreen> createState() => _CategoryExpensesScreenState();
}

class _CategoryExpensesScreenState extends State<CategoryExpensesScreen> {
  ExpenseCategory? _category;
  bool _isLoading = true;
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCategory();
    _loadTotalAmount();
  }

  Future<void> _loadCategory() async {
    final category = await widget.categoryRepo.findCategoryById(widget.categoryId);
    setState(() {
      _category = category;
    });
  }

  Future<void> _loadTotalAmount() async {
    setState(() => _isLoading = true);
    try {
      // Get all expenses for the selected month and category to calculate total
      final allExpenses = await widget.repository.getAllExpenses();
      
      // Filter expenses by month and category
      final filteredExpenses = allExpenses.where((expense) => 
        expense.date.year == widget.selectedMonth.year &&
        expense.date.month == widget.selectedMonth.month &&
        expense.categoryId == widget.categoryId &&
        expense.status == ExpenseStatus.paid
      ).toList();
      
      // Calculate total amount
      final total = filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
      
      setState(() {
        _totalAmount = total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load category total: ${e.toString()}')),
        );
      }
    }
  }

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
            // Refresh the total amount when an expense is updated
            _loadTotalAmount();
          },
        ),
        maintainState: true,
      ),
    );

    if (result == true) {
      await widget.repository.deleteExpense(expense.id);
      // Refresh the total amount when an expense is deleted
      _loadTotalAmount();
    }
  }

  void _deleteExpense(Expense expense) async {
    await widget.repository.deleteExpense(expense.id);
    // Refresh the total amount when an expense is deleted
    _loadTotalAmount();
  }

  Widget _buildCategorySummary() {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      color: theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      elevation: 0,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Expenses',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                formatCurrency(_totalAmount),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: KiwiAppBar(
        title: _category?.name ?? 'Category Expenses',
        leading: const Icon(AppIcons.back),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCategorySummary(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Expenses',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: LazyLoadingExpenseList(
                      expenseRepo: widget.repository,
                      categoryRepo: widget.categoryRepo,
                      onTap: _viewExpenseDetails,
                      onDelete: _deleteExpense,
                      categoryId: widget.categoryId,
                      startDate: DateTime(widget.selectedMonth.year, widget.selectedMonth.month, 1),
                      endDate: DateTime(widget.selectedMonth.year, widget.selectedMonth.month + 1, 0),
                      orderBy: 'date',
                      descending: true,
                      pageSize: 10,
                      groupByDate: true,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 