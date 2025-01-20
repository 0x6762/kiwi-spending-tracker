import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'models/expense.dart';
import 'repositories/expense_repository.dart';
import 'widgets/add_expense_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spending Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: ExpenseListScreen(repository: LocalStorageExpenseRepository(prefs)),
    );
  }
}

class ExpenseListScreen extends StatefulWidget {
  final ExpenseRepository repository;

  const ExpenseListScreen({super.key, required this.repository});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List<Expense> _expenses = [];
  final _dateFormat = DateFormat.yMMMd();

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Tracker'),
      ),
      body: ListView.builder(
        itemCount: _expenses.length,
        itemBuilder: (context, index) {
          final expense = _expenses[index];
          return ListTile(
            title: Text(expense.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_dateFormat.format(expense.date)),
                if (expense.category != null)
                  Text(expense.category!,
                      style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            trailing: Text(
              '\$${expense.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            onTap: () {
              // TODO: Implement expense details/edit
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        child: const Icon(Icons.add),
      ),
    );
  }
}
