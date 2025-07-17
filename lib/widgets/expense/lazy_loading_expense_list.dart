import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../models/expense_category.dart';
import '../../models/account.dart';
import '../../utils/formatters.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/expense_repository.dart';
import '../dialogs/delete_confirmation_dialog.dart';

class LazyLoadingExpenseList extends StatefulWidget {
  final ExpenseRepository expenseRepo;
  final CategoryRepository categoryRepo;
  final Function(Expense)? onTap;
  final Function(Expense)? onDelete;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? orderBy;
  final bool descending;
  final int pageSize;
  final bool groupByDate;
  final String? categoryId; // Add category filter support
  final bool useInternalScroll; // New parameter to control scroll behavior

  const LazyLoadingExpenseList({
    super.key,
    required this.expenseRepo,
    required this.categoryRepo,
    this.onTap,
    this.onDelete,
    this.startDate,
    this.endDate,
    this.orderBy,
    this.descending = true,
    this.pageSize = 20,
    this.groupByDate = false,
    this.categoryId, // Add category filter parameter
    this.useInternalScroll = true, // Default to internal scrolling
  });

  @override
  State<LazyLoadingExpenseList> createState() => _LazyLoadingExpenseListState();
}

class _LazyLoadingExpenseListState extends State<LazyLoadingExpenseList> {
  final List<Expense> _expenses = [];
  late final ScrollController _scrollController;
  final _dateFormat = DateFormat.yMMMd();
  
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _currentOffset = 0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.useInternalScroll) {
      _scrollController = ScrollController();
      _scrollController.addListener(_onScroll);
    } else {
      // Use a dummy controller for external scrolling
      _scrollController = ScrollController();
    }
    _loadInitialData();
  }

  @override
  void dispose() {
    if (widget.useInternalScroll) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (!widget.useInternalScroll) return;
    if (!_scrollController.hasClients) return;
    
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      debugPrint('LazyLoading: Triggering load more data. Current: ${position.pixels}, Max: ${position.maxScrollExtent}');
      _loadMoreData();
    }
  }

  Future<void> _loadInitialData() async {
    if (_isLoading) return;
    
    debugPrint('LazyLoading: Loading initial data. pageSize: ${widget.pageSize}');
    setState(() {
      _isLoading = true;
    });

    try {
      // Get total count first
      if (widget.categoryId != null && widget.startDate != null && widget.endDate != null) {
        _totalCount = await widget.expenseRepo.getExpensesByCategoryAndDateRangeCount(
          widget.categoryId!,
          widget.startDate!,
          widget.endDate!,
        );
      } else if (widget.categoryId != null) {
        _totalCount = await widget.expenseRepo.getExpensesByCategoryCount(widget.categoryId!);
      } else if (widget.startDate != null && widget.endDate != null) {
        _totalCount = await widget.expenseRepo.getExpensesByDateRangeCount(
          widget.startDate!,
          widget.endDate!,
        );
      } else {
        _totalCount = await widget.expenseRepo.getExpensesCount();
      }

      debugPrint('LazyLoading: Total count: $_totalCount');

      // Load first page
      List<Expense> expenses;
      if (widget.categoryId != null && widget.startDate != null && widget.endDate != null) {
        expenses = await widget.expenseRepo.getExpensesByCategoryAndDateRangePaginated(
          widget.categoryId!,
          widget.startDate!,
          widget.endDate!,
          limit: widget.pageSize,
          offset: 0,
        );
      } else if (widget.categoryId != null) {
        expenses = await widget.expenseRepo.getExpensesByCategoryPaginated(
          widget.categoryId!,
          limit: widget.pageSize,
          offset: 0,
          orderBy: widget.orderBy,
          descending: widget.descending,
        );
      } else if (widget.startDate != null && widget.endDate != null) {
        expenses = await widget.expenseRepo.getExpensesByDateRangePaginated(
          widget.startDate!,
          widget.endDate!,
          limit: widget.pageSize,
          offset: 0,
        );
      } else {
        expenses = await widget.expenseRepo.getExpensesPaginated(
          limit: widget.pageSize,
          offset: 0,
          orderBy: widget.orderBy,
          descending: widget.descending,
        );
      }

      debugPrint('LazyLoading: Initial load complete. Loaded: ${expenses.length} expenses');

      setState(() {
        _expenses.clear();
        _expenses.addAll(expenses);
        _currentOffset = expenses.length;
        _hasMoreData = expenses.length == widget.pageSize;
        _isLoading = false;
      });
      
      debugPrint('LazyLoading: Initial state set. hasMoreData: $_hasMoreData, currentOffset: $_currentOffset');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading initial data: $e');
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMoreData) {
      debugPrint('LazyLoading: Skipping load more. isLoading: $_isLoading, hasMoreData: $_hasMoreData');
      return;
    }

    debugPrint('LazyLoading: Loading more data. Current offset: $_currentOffset, pageSize: ${widget.pageSize}');
    setState(() {
      _isLoading = true;
    });

    try {
      List<Expense> expenses;
      if (widget.categoryId != null && widget.startDate != null && widget.endDate != null) {
        expenses = await widget.expenseRepo.getExpensesByCategoryAndDateRangePaginated(
          widget.categoryId!,
          widget.startDate!,
          widget.endDate!,
          limit: widget.pageSize,
          offset: _currentOffset,
        );
      } else if (widget.categoryId != null) {
        expenses = await widget.expenseRepo.getExpensesByCategoryPaginated(
          widget.categoryId!,
          limit: widget.pageSize,
          offset: _currentOffset,
          orderBy: widget.orderBy,
          descending: widget.descending,
        );
      } else if (widget.startDate != null && widget.endDate != null) {
        expenses = await widget.expenseRepo.getExpensesByDateRangePaginated(
          widget.startDate!,
          widget.endDate!,
          limit: widget.pageSize,
          offset: _currentOffset,
        );
      } else {
        expenses = await widget.expenseRepo.getExpensesPaginated(
          limit: widget.pageSize,
          offset: _currentOffset,
          orderBy: widget.orderBy,
          descending: widget.descending,
        );
      }

      debugPrint('LazyLoading: Loaded ${expenses.length} more expenses. Total now: ${_expenses.length + expenses.length}');

      setState(() {
        _expenses.addAll(expenses);
        _currentOffset += expenses.length;
        _hasMoreData = expenses.length == widget.pageSize;
        _isLoading = false;
      });
      
      debugPrint('LazyLoading: Updated state. hasMoreData: $_hasMoreData, totalCount: $_totalCount');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading more data: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _currentOffset = 0;
      _hasMoreData = true;
    });
    await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    if (_expenses.isEmpty && !_isLoading) {
      return _buildEmptyState();
    }

    Widget content = widget.groupByDate 
        ? _buildGroupedExpenses()
        : _buildSimpleExpenses();

    if (!widget.useInternalScroll) {
      // Wrap with NotificationListener to detect scroll events from parent
      content = NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification) {
            // Check if we're near the bottom of the scrollable area
            final metrics = scrollInfo.metrics;
            if (metrics.pixels >= metrics.maxScrollExtent - 200) {
              _loadMoreData();
            }
          }
          return false; // Don't prevent the notification from bubbling up
        },
        child: content,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: content,
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.7,
              child: Image.asset(
                'assets/imgs/empty-state.png',
                width: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No expenses found.',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(32.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildGroupedExpenses() {
    final groupedExpenses = _groupExpensesByDate();
    final sortedEntries = _sortGroupedEntries(groupedExpenses);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sortedEntries.length + (_hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == sortedEntries.length) {
          return _buildLoadingIndicator();
        }
        
        final entry = sortedEntries[index];
        return _buildDateGroup(entry.key, entry.value);
      },
    );
  }

  Widget _buildSimpleExpenses() {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      elevation: 0,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _expenses.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _expenses.length) {
            return _buildLoadingIndicator();
          }
          
          final expense = _expenses[index];
          return _buildExpenseItem(context, expense);
        },
      ),
    );
  }

  Widget _buildDateGroup(DateTime date, List<Expense> expenses) {
    final theme = Theme.of(context);
    final dayTotal = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatSectionTitle(date),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
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
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          color: theme.colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
          child: Column(
            children: expenses.map((expense) => _buildExpenseItem(context, expense)).toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildExpenseItem(BuildContext context, Expense expense) {
    return FutureBuilder<ExpenseCategory?>(
      future: widget.categoryRepo.findCategoryById(
        expense.categoryId ?? CategoryRepository.uncategorizedId,
      ),
      builder: (context, snapshot) {
        final category = snapshot.data;
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
            return await DeleteConfirmationDialog.show(context);
          },
          onDismissed: (_) {
            if (widget.onDelete != null) {
              widget.onDelete!(expense);
            }
            setState(() {
              _expenses.removeWhere((e) => e.id == expense.id);
            });
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap != null ? () => widget.onTap!(expense) : null,
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
                      category?.icon ?? Icons.category_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(expense.date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
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
      },
    );
  }

  // Helper methods
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

  Map<DateTime, List<Expense>> _groupExpensesByDate() {
    final groupedExpenses = <DateTime, List<Expense>>{};
    final sortedExpenses = List<Expense>.from(_expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    final upcomingKey = DateTime(9999, 12, 31);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    for (var expense in sortedExpenses) {
      final date = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      
      if (date.isAfter(today)) {
        groupedExpenses.putIfAbsent(upcomingKey, () => []).add(expense);
      } else {
        groupedExpenses.putIfAbsent(date, () => []).add(expense);
      }
    }

    return groupedExpenses;
  }

  List<MapEntry<DateTime, List<Expense>>> _sortGroupedEntries(Map<DateTime, List<Expense>> groupedExpenses) {
    final sortedEntries = groupedExpenses.entries.toList()
      ..sort((a, b) {
        if (a.key == DateTime(9999, 12, 31)) return -1;
        if (b.key == DateTime(9999, 12, 31)) return 1;
        return b.key.compareTo(a.key);
      });
    return sortedEntries;
  }
} 