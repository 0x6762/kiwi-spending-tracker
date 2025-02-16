import '../database/database.dart';
import '../database/extensions/expense_extensions.dart';
import '../models/expense.dart';
import 'expense_repository.dart';

class DriftExpenseRepository implements ExpenseRepository {
  final AppDatabase _db;

  DriftExpenseRepository(this._db);

  @override
  Future<List<Expense>> getAllExpenses() async {
    final expenses = await _db.getAllExpenses();
    return expenses.map((e) => e.toDomain()).toList();
  }

  @override
  Future<void> addExpense(Expense expense) async {
    await _db.insertExpense(expense.toCompanion());
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    await _db.updateExpense(expense.toCompanion());
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _db.deleteExpense(id);
  }

  // Additional methods that might be useful but not required by the interface
  Stream<List<Expense>> watchAllExpenses() {
    return _db.watchAllExpenses().map(
          (expenses) => expenses.map((e) => e.toDomain()).toList(),
        );
  }

  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final expenses = await _db.getExpensesByDateRange(start, end);
    return expenses.map((e) => e.toDomain()).toList();
  }

  Stream<List<Expense>> watchExpensesByDateRange(DateTime start, DateTime end) {
    return _db.watchExpensesByDateRange(start, end).map(
          (expenses) => expenses.map((e) => e.toDomain()).toList(),
        );
  }
} 