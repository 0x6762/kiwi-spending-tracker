import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/account_repository.dart';
import '../widgets/common/app_bar.dart';
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
  List<Expense> _expenses = [];
  ExpenseCategory? _category;
  bool _isLoading = true;
  final _dateFormat = DateFormat.yMMMd();
  final _monthFormat = DateFormat.yMMMM();
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCategory();
    _loadExpenses();
  }

  Future<void> _loadCategory() async {
    final category = await widget.categoryRepo.findCategoryById(widget.categoryId);
    setState(() {
      _category = category;
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final expenseDate = DateTime(date.year, date.month, date.day);

    if (expenseDate == today) {
      return 'Today';
    } else if (expenseDate == yesterday) {
      return 'Yesterday';
    } else if (expenseDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return _dateFormat.format(date);
    }
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);
    try {
      // Get effective expenses (only past and present expenses, not future ones)
      final effectiveExpenses = await widget.repository.getEffectiveExpenses(asOfDate: DateTime.now());
      
      // Filter expenses by month and category
      final filteredExpenses = effectiveExpenses.where((expense) => 
        expense.date.year == widget.selectedMonth.year &&
        expense.date.month == widget.selectedMonth.month &&
        expense.categoryId == widget.categoryId &&
        expense.status == ExpenseStatus.paid
      ).toList();
      
      // Sort by date (most recent first)
      filteredExpenses.sort((a, b) => b.date.compareTo(a.date));
      
      // Calculate total amount
      final total = filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
      
      setState(() {
        _expenses = filteredExpenses;
        _totalAmount = total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load category expenses: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteExpense(Expense expense) async {
    await widget.repository.deleteExpense(expense.id);
    _loadExpenses();
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
            _loadExpenses();
          },
        ),
        maintainState: true,
      ),
    );

    if (result == true) {
      await _deleteExpense(expense);
    }
  }

  Widget _buildExpenseItem(BuildContext context, Expense expense) {
    final theme = Theme.of(context);
    
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: theme.colorScheme.surfaceContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(
          Icons.delete,
          color: theme.colorScheme.error,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Expense'),
            content: const Text('Are you sure you want to delete this expense?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('DELETE'),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => _deleteExpense(expense),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _viewExpenseDetails(expense),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _category?.icon ?? Icons.category_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            expense.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatDate(expense.date),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (expense.notes != null && expense.notes!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          expense.notes!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                formatCurrency(expense.amount),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                    child: SingleChildScrollView(
                      child: Card(
                        margin: EdgeInsets.zero,
                        color: theme.colorScheme.surfaceContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _expenses.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return _buildExpenseItem(context, _expenses[index]);
                          },
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