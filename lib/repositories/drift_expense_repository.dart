import 'package:drift/drift.dart';
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

  // Pagination methods
  @override
  Future<List<Expense>> getExpensesPaginated({
    int limit = 20,
    int offset = 0,
    String? orderBy,
    bool descending = true,
  }) async {
    final expenses = await _db.getExpensesPaginated(
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      descending: descending,
    );
    return expenses.map((e) => e.toDomain()).toList();
  }

  @override
  Future<int> getExpensesCount() async {
    return await _db.getExpensesCount();
  }

  @override
  Future<List<Expense>> getExpensesByDateRangePaginated(
    DateTime start,
    DateTime end, {
    int limit = 20,
    int offset = 0,
  }) async {
    final expenses = await _db.getExpensesByDateRangePaginated(
      start,
      end,
      limit: limit,
      offset: offset,
    );
    return expenses.map((e) => e.toDomain()).toList();
  }

  @override
  Future<int> getExpensesByDateRangeCount(DateTime start, DateTime end) async {
    return await _db.getExpensesByDateRangeCount(start, end);
  }

  // New methods for enhanced expense structure
  @override
  Future<List<Expense>> getExpensesByNecessity(ExpenseNecessity necessity) async {
    final expenses = await (_db.select(_db.expensesTable)
      ..where((tbl) => tbl.necessity.equals(necessity.index)))
      .get();
    return expenses.map((e) => e.toDomain()).toList();
  }

  @override
  Future<List<Expense>> getRecurringExpenses() async {
    final expenses = await (_db.select(_db.expensesTable)
      ..where((tbl) => tbl.isRecurring.equals(true)))
      .get();
    return expenses.map((e) => e.toDomain()).toList();
  }

  @override
  Future<List<Expense>> getExpensesByStatus(ExpenseStatus status) async {
    final expenses = await (_db.select(_db.expensesTable)
      ..where((tbl) => tbl.status.equals(status.index)))
      .get();
    return expenses.map((e) => e.toDomain()).toList();
  }

  @override
  Future<List<Expense>> getExpensesByFrequency(ExpenseFrequency frequency) async {
    final expenses = await (_db.select(_db.expensesTable)
      ..where((tbl) => tbl.frequency.equals(frequency.index)))
      .get();
    return expenses.map((e) => e.toDomain()).toList();
  }

  @override
  Future<List<Expense>> getExpensesByBudget(String budgetId) async {
    final expenses = await (_db.select(_db.expensesTable)
      ..where((tbl) => tbl.budgetId.equals(budgetId)))
      .get();
    return expenses.map((e) => e.toDomain()).toList();
  }

  @override
  Future<List<Expense>> getExpensesByTags(List<String> tags) async {
    // This is a simple implementation that checks if any of the tags match
    // A more sophisticated implementation would use SQL LIKE with wildcards
    final expenses = await _db.getAllExpenses();
    return expenses
        .map((e) => e.toDomain())
        .where((expense) {
          if (expense.tags == null) return false;
          return expense.tags!.any((tag) => tags.contains(tag));
        })
        .toList();
  }

  // Implementation of new methods for upcoming expenses
  @override
  Future<List<Expense>> getEffectiveExpenses({DateTime? asOfDate}) async {
    final referenceDate = asOfDate ?? DateTime.now();
    final expenses = await _db.getEffectiveExpenses(referenceDate);
    return expenses.map((e) => e.toDomain()).toList();
  }

  @override
  Future<List<Expense>> getUpcomingExpenses({DateTime? fromDate}) async {
    final referenceDate = fromDate ?? DateTime.now();
    final expenses = await _db.getUpcomingExpenses(referenceDate);
    return expenses.map((e) => e.toDomain()).toList();
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