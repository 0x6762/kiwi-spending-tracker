import 'package:flutter/material.dart';
import '../repositories/category_repository.dart';
import '../repositories/expense_repository.dart';
import '../repositories/account_repository.dart';
import '../widgets/expense/lazy_loading_expense_list.dart';
import '../widgets/common/app_bar.dart';
import '../models/expense.dart';
import 'expense_detail_screen.dart';

class LazyLoadingExpensesScreen extends StatefulWidget {
  final CategoryRepository categoryRepo;
  final ExpenseRepository expenseRepo;
  final AccountRepository accountRepo;
  final void Function(Expense) onDelete;
  final void Function() onExpenseUpdated;

  const LazyLoadingExpensesScreen({
    super.key,
    required this.categoryRepo,
    required this.expenseRepo,
    required this.accountRepo,
    required this.onDelete,
    required this.onExpenseUpdated,
  });

  @override
  State<LazyLoadingExpensesScreen> createState() => _LazyLoadingExpensesScreenState();
}

class _LazyLoadingExpensesScreenState extends State<LazyLoadingExpensesScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _orderBy = 'date';
  bool _descending = true;
  int _pageSize = 20;

  void _viewExpenseDetails(Expense expense) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailScreen(
          expense: expense,
          categoryRepo: widget.categoryRepo,
          accountRepo: widget.accountRepo,
          onExpenseUpdated: (updatedExpense) async {
            await widget.expenseRepo.updateExpense(updatedExpense);
            // Notify parent to update its state
            widget.onExpenseUpdated();
          },
        ),
      ),
    );

    if (result == true) {
      await widget.expenseRepo.deleteExpense(expense.id);
      widget.onDelete(expense);
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        startDate: _startDate,
        endDate: _endDate,
        orderBy: _orderBy,
        descending: _descending,
        pageSize: _pageSize,
        onApply: (startDate, endDate, orderBy, descending, pageSize) {
          setState(() {
            _startDate = startDate;
            _endDate = endDate;
            _orderBy = orderBy;
            _descending = descending;
            _pageSize = pageSize;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: KiwiAppBar(
        title: 'All Expenses',
        leading: const Icon(Icons.arrow_back),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter summary
          if (_startDate != null || _endDate != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _buildFilterSummary(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
          // Lazy loading expense list
          Expanded(
            child: LazyLoadingExpenseList(
              expenseRepo: widget.expenseRepo,
              categoryRepo: widget.categoryRepo,
              onTap: _viewExpenseDetails,
              onDelete: widget.onDelete,
              startDate: _startDate,
              endDate: _endDate,
              orderBy: _orderBy,
              descending: _descending,
              pageSize: _pageSize,
            ),
          ),
        ],
      ),
    );
  }

  String _buildFilterSummary() {
    final parts = <String>[];
    
    if (_startDate != null && _endDate != null) {
      parts.add('${_startDate!.day}/${_startDate!.month} - ${_endDate!.day}/${_endDate!.month}');
    } else if (_startDate != null) {
      parts.add('From ${_startDate!.day}/${_startDate!.month}');
    } else if (_endDate != null) {
      parts.add('Until ${_endDate!.day}/${_endDate!.month}');
    }
    
    parts.add('Order by ${_orderBy} ${_descending ? 'desc' : 'asc'}');
    parts.add('Page size: $_pageSize');
    
    return parts.join(' • ');
  }
}

class _FilterDialog extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String orderBy;
  final bool descending;
  final int pageSize;
  final Function(DateTime?, DateTime?, String, bool, int) onApply;

  const _FilterDialog({
    required this.startDate,
    required this.endDate,
    required this.orderBy,
    required this.descending,
    required this.pageSize,
    required this.onApply,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late String _orderBy;
  late bool _descending;
  late int _pageSize;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _orderBy = widget.orderBy;
    _descending = widget.descending;
    _pageSize = widget.pageSize;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Filter & Sort'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Date range
          ListTile(
            title: const Text('Date Range'),
            subtitle: Text(
              _startDate != null && _endDate != null
                  ? '${_startDate!.day}/${_startDate!.month} - ${_endDate!.day}/${_endDate!.month}'
                  : 'All dates',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final now = DateTime.now();
              final startDate = await showDatePicker(
                context: context,
                initialDate: _startDate ?? now,
                firstDate: DateTime(2020),
                lastDate: now,
              );
              if (startDate != null) {
                final endDate = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? startDate,
                  firstDate: startDate,
                  lastDate: now,
                );
                setState(() {
                  _startDate = startDate;
                  _endDate = endDate;
                });
              }
            },
          ),
          // Order by
          ListTile(
            title: const Text('Order By'),
            subtitle: Text(_orderBy),
            trailing: DropdownButton<String>(
              value: _orderBy,
              items: const [
                DropdownMenuItem(value: 'date', child: Text('Date')),
                DropdownMenuItem(value: 'amount', child: Text('Amount')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _orderBy = value;
                  });
                }
              },
            ),
          ),
          // Sort direction
          ListTile(
            title: const Text('Sort Direction'),
            subtitle: Text(_descending ? 'Descending' : 'Ascending'),
            trailing: Switch(
              value: _descending,
              onChanged: (value) {
                setState(() {
                  _descending = value;
                });
              },
            ),
          ),
          // Page size
          ListTile(
            title: const Text('Page Size'),
            subtitle: Text('$_pageSize items'),
            trailing: DropdownButton<int>(
              value: _pageSize,
              items: const [
                DropdownMenuItem(value: 10, child: Text('10')),
                DropdownMenuItem(value: 20, child: Text('20')),
                DropdownMenuItem(value: 50, child: Text('50')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _pageSize = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(_startDate, _endDate, _orderBy, _descending, _pageSize);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
} 