import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/account_repository.dart';
import '../services/expense_analytics_service.dart';
import '../widgets/app_bar.dart';
import '../utils/formatters.dart';
import 'expense_detail_screen.dart';

class UpcomingExpensesScreen extends StatefulWidget {
  final ExpenseRepository repository;
  final CategoryRepository categoryRepo;
  final AccountRepository accountRepo;
  final DateTime selectedMonth;

  const UpcomingExpensesScreen({
    super.key,
    required this.repository,
    required this.categoryRepo,
    required this.accountRepo,
    required this.selectedMonth,
  });

  @override
  State<UpcomingExpensesScreen> createState() => _UpcomingExpensesScreenState();
}

class _UpcomingExpensesScreenState extends State<UpcomingExpensesScreen> {
  late ExpenseAnalyticsService _analyticsService;
  List<Expense> _upcomingExpenses = [];
  double _totalAmount = 0.0;
  bool _isLoading = true;
  final _dateFormat = DateFormat.yMMMd();

  @override
  void initState() {
    super.initState();
    _analyticsService = ExpenseAnalyticsService(widget.repository, widget.categoryRepo);
    _loadUpcomingExpenses();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final expenseDate = DateTime(date.year, date.month, date.day);

    if (expenseDate == today) {
      return 'Today';
    } else if (expenseDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return _dateFormat.format(date);
    }
  }

  Future<void> _loadUpcomingExpenses() async {
    setState(() => _isLoading = true);
    try {
      // Get upcoming expenses
      final upcomingAnalytics = await _analyticsService.getUpcomingExpenses();
      
      setState(() {
        _upcomingExpenses = upcomingAnalytics.upcomingExpenses;
        _totalAmount = upcomingAnalytics.totalAmount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load upcoming expenses: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteExpense(Expense expense) async {
    await widget.repository.deleteExpense(expense.id);
    _loadUpcomingExpenses();
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
            _loadUpcomingExpenses();
          },
        ),
        maintainState: true,
      ),
    );

    if (result == true) {
      await _deleteExpense(expense);
    }
  }

  Widget _buildUpcomingExpenseItem(BuildContext context, Expense expense) {
    final theme = Theme.of(context);
    
    return FutureBuilder<ExpenseCategory?>(
      future: widget.categoryRepo.findCategoryById(expense.categoryId ?? CategoryRepository.uncategorizedId),
      builder: (context, snapshot) {
        final category = snapshot.data;
        
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
                content: const Text('Are you sure you want to delete this upcoming expense?'),
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
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                category?.icon ?? Icons.category_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            title: Text(
              expense.title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Due on: ${_formatDate(expense.date)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Text(
              formatCurrency(expense.amount),
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            onTap: () => _viewExpenseDetails(expense),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingExpensesSummary() {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.fromLTRB(8, 16, 8, 16),
      color: theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Upcoming',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: KiwiAppBar(
        title: 'Upcoming Expenses',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadUpcomingExpenses,
        color: theme.colorScheme.primary,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _upcomingExpenses.isEmpty
                ? Center(
                    child: Text(
                      'No upcoming expenses',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildUpcomingExpensesSummary(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Text(
                            'Upcoming Expenses',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: theme.colorScheme.surfaceContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _upcomingExpenses.length,
                            itemBuilder: (context, index) {
                              return _buildUpcomingExpenseItem(context, _upcomingExpenses[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
} 