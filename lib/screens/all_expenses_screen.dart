import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../repositories/category_repository.dart';
import '../repositories/expense_repository.dart';
import '../repositories/account_repository.dart';
import '../widgets/expense_list.dart';
import '../widgets/app_bar.dart';
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

  @override
  void initState() {
    super.initState();
    _expenses = widget.expenses;
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
              final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
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
      });
      widget.onDelete(expense);
    }
  }

  @override
  void didUpdateWidget(AllExpensesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expenses != oldWidget.expenses) {
      setState(() {
        _expenses = widget.expenses;
      });
    }
  }

  Map<DateTime, List<Expense>> _groupExpensesByDate() {
    final groupedExpenses = <DateTime, List<Expense>>{};
    final sortedExpenses = List<Expense>.from(_expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Special key for upcoming expenses
    final upcomingKey = DateTime(9999, 12, 31); // Far future date as a special key
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: sortedEntries.map((entry) {
            // Calculate the sum of expenses for this day
            final dayTotal = entry.value.fold<double>(
              0, (sum, expense) => sum + expense.amount
            );
            
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
                Card(
                  margin: EdgeInsets.zero,
                  color: theme.colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                  child: ExpenseList(
                    expenses: entry.value,
                    categoryRepo: widget.categoryRepo,
                    onTap: _viewExpenseDetails,
                    onDelete: widget.onDelete,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
} 