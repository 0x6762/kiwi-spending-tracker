import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../widgets/expense_list.dart';
import '../widgets/expense_summary.dart';
import '../widgets/add_expense_dialog.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final List<Expense> _expenses = [];
  DateTime _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  void _addExpense() async {
    final expense = await showDialog<Expense>(
      context: context,
      builder: (ctx) => const AddExpenseDialog(),
    );

    if (expense != null) {
      setState(() {
        _expenses.add(expense);
        // Update selected month to the month of the new expense if it's different
        if (expense.date.year != _selectedMonth.year ||
            expense.date.month != _selectedMonth.month) {
          _selectedMonth = DateTime(expense.date.year, expense.date.month);
        }
      });
    }
  }

  void _viewExpenseDetails(Expense expense) {
    // TODO: Implement expense details view
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
        title: const Text('Expense Tracker'),
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
              expenses: _expenses,
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
