import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../repositories/category_repository.dart';
import '../repositories/expense_repository.dart';
import '../repositories/account_repository.dart';
import '../widgets/expense/expense_list.dart';
import '../widgets/common/app_bar.dart';
import '../utils/formatters.dart';
import 'expense_detail_screen.dart';

class AllExpensesScreen extends StatefulWidget {
  final List<Expense> expenses;
  final CategoryRepository categoryRepo;
  final ExpenseRepository repository;
  final AccountRepository accountRepo;
  final void Function(Expense) onDelete;
  final void Function() onExpenseUpdated;

  const AllExpensesScreen({
    super.key,
    required this.expenses,
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
  late List<Expense> _expenses;
  int _currentPage = 0;
  static const int _pageSize = 10;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Sort expenses by newest first before pagination
    final sortedExpenses = List<Expense>.from(widget.expenses)
      ..sort((a, b) => b.date.compareTo(a.date));
    _expenses = sortedExpenses.take(_pageSize).toList();
    _hasMoreData = sortedExpenses.length > _pageSize;
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreExpenses();
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
            setState(() {
              final index =
                  _expenses.indexWhere((e) => e.id == updatedExpense.id);
              if (index != -1) {
                _expenses[index] = updatedExpense;
              }
            });
            // Notify parent to update its state
            widget.onExpenseUpdated();
          },
        ),
      ),
    );

    if (result == true) {
      await widget.repository.deleteExpense(expense.id);
      setState(() {
        _expenses.removeWhere((e) => e.id == expense.id);
        // Load more data if we have less than page size and more data available
        if (_expenses.length < _pageSize && _hasMoreData) {
          _loadMoreExpenses();
        }
      });
      widget.onDelete(expense);
    }
  }

  @override
  void didUpdateWidget(AllExpensesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expenses != oldWidget.expenses) {
      setState(() {
        // Sort expenses by newest first before pagination
        final sortedExpenses = List<Expense>.from(widget.expenses)
          ..sort((a, b) => b.date.compareTo(a.date));
        _expenses = sortedExpenses.take(_pageSize).toList();
        _hasMoreData = sortedExpenses.length > _pageSize;
        _currentPage = 0;
      });
    }
  }

  Future<void> _loadMoreExpenses() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _currentPage++;
      // Sort expenses by newest first before pagination
      final sortedExpenses = List<Expense>.from(widget.expenses)
        ..sort((a, b) => b.date.compareTo(a.date));
      final startIndex = _currentPage * _pageSize;
      final endIndex = (startIndex + _pageSize).clamp(0, sortedExpenses.length);

      if (startIndex < sortedExpenses.length) {
        _expenses.addAll(sortedExpenses.sublist(startIndex, endIndex));
      }

      _hasMoreData = endIndex < sortedExpenses.length;
      _isLoadingMore = false;
    });
  }

  Widget _buildLoadMoreIndicator() {
    if (!_hasMoreData) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: _isLoadingMore
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : const SizedBox.shrink(),
    );
  }

  Map<DateTime, List<Expense>> _groupExpensesByDate() {
    final groupedExpenses = <DateTime, List<Expense>>{};
    final sortedExpenses = List<Expense>.from(_expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Special key for upcoming expenses
    final upcomingKey =
        DateTime(9999, 12, 31); // Far future date as a special key
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var expense in sortedExpenses) {
      final date = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );

      // Check if this is an upcoming expense
      if (date.isAfter(today)) {
        // Add to the upcoming group
        if (!groupedExpenses.containsKey(upcomingKey)) {
          groupedExpenses[upcomingKey] = [];
        }
        groupedExpenses[upcomingKey]!.add(expense);
      } else {
        // Add to the regular date group
        if (!groupedExpenses.containsKey(date)) {
          groupedExpenses[date] = [];
        }
        groupedExpenses[date]!.add(expense);
      }
    }

    return groupedExpenses;
  }

  String _formatSectionTitle(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final specialUpcomingKey = DateTime(9999, 12, 31);

    if (date == specialUpcomingKey) {
      return 'Upcoming';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return DateFormat.MMMd().format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupedExpenses = _groupExpensesByDate();

    // Sort the entries to ensure upcoming is first, then by date descending
    final sortedEntries = groupedExpenses.entries.toList()
      ..sort((a, b) {
        // Special case for the upcoming key
        if (a.key == DateTime(9999, 12, 31)) return -1;
        if (b.key == DateTime(9999, 12, 31)) return 1;
        // Otherwise sort by date descending
        return b.key.compareTo(a.key);
      });

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: KiwiAppBar(
        title: 'All Expenses',
        leading: const Icon(Icons.arrow_back),
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        itemCount: sortedEntries.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          // Load more indicator
          if (index == sortedEntries.length) {
            return _buildLoadMoreIndicator();
          }

          final entry = sortedEntries[index];
          // Calculate the sum of expenses for this day
          final dayTotal = entry.value
              .fold<double>(0, (sum, expense) => sum + expense.amount);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatSectionTitle(entry.key),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: entry.key == DateTime(9999, 12, 31)
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Total: ${formatCurrency(dayTotal)}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              ExpenseList(
                expenses: entry.value,
                categoryRepo: widget.categoryRepo,
                onTap: _viewExpenseDetails,
                onDelete: widget.onDelete,
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}
