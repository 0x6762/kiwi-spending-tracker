import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../widgets/expense_list.dart';
import '../widgets/expense_summary.dart';
import '../widgets/add_expense_dialog.dart';

class ExpenseListScreen extends StatefulWidget {
  final ExpenseRepository repository;

  const ExpenseListScreen({super.key, required this.repository});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List<Expense> _expenses = [];
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final expenses = await widget.repository.getAllExpenses();
    setState(() {
      _expenses = expenses;
    });
  }

  Future<void> _addExpense() async {
    final result = await showModalBottomSheet<Expense>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const AddExpenseDialog(),
    );

    if (result != null) {
      await widget.repository.addExpense(result);
      _loadExpenses();
    }
  }

  void _viewExpenseDetails(Expense expense) {
    // TODO: Implement expense details/edit
  }

  void _onMonthSelected(DateTime month) {
    setState(() {
      _selectedMonth = month;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Tracker'),
      ),
      body: Column(
        children: [
          ExpenseSummary(
            expenses: _expenses,
            selectedMonth: _selectedMonth,
            onMonthSelected: _onMonthSelected,
          ),
          Expanded(
            child: ExpenseList(
              expenses: _expenses
                  .where((expense) =>
                      expense.date.year == _selectedMonth.year &&
                      expense.date.month == _selectedMonth.month)
                  .toList(),
              onTap: _viewExpenseDetails,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        child: const Icon(Icons.add),
      ),
    );
  }
}
