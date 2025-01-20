import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

// Abstract repository interface
abstract class ExpenseRepository {
  Future<List<Expense>> getAllExpenses();
  Future<void> addExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);
}

// Local storage implementation using SharedPreferences
class LocalStorageExpenseRepository implements ExpenseRepository {
  static const String _storageKey = 'expenses';
  final SharedPreferences _prefs;

  LocalStorageExpenseRepository(this._prefs);

  @override
  Future<List<Expense>> getAllExpenses() async {
    final String? expensesJson = _prefs.getString(_storageKey);
    if (expensesJson == null) return [];

    final List<dynamic> decodedList = json.decode(expensesJson);
    return decodedList
        .map((item) => Expense.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addExpense(Expense expense) async {
    final expenses = await getAllExpenses();
    expenses.add(expense);
    await _saveExpenses(expenses);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final expenses = await getAllExpenses();
    final index = expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      expenses[index] = expense;
      await _saveExpenses(expenses);
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    final expenses = await getAllExpenses();
    expenses.removeWhere((expense) => expense.id == id);
    await _saveExpenses(expenses);
  }

  Future<void> _saveExpenses(List<Expense> expenses) async {
    final String encodedData = json.encode(
      expenses.map((expense) => expense.toJson()).toList(),
    );
    await _prefs.setString(_storageKey, encodedData);
  }
}
