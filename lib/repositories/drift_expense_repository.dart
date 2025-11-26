import '../database/database.dart';
import '../database/extensions/expense_extensions.dart';
import '../database/extensions/category_extensions.dart';
import '../database/extensions/account_extensions.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/account.dart';
import '../models/expense_filters.dart';
import '../models/paginated_expenses.dart';
import 'expense_repository.dart';

class DriftExpenseRepository implements ExpenseRepository {
  final AppDatabase _db;

  DriftExpenseRepository(this._db);

  @override
  Future<List<Expense>> getAllExpenses() async {
    try {
      final expenses = await _db.getAllExpenses();
      return expenses.map((e) => e.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to load expenses: ${e.toString()}');
    }
  }

  @override
  Future<void> addExpense(Expense expense) async {
    try {
      await _db.insertExpense(expense.toCompanion());
    } catch (e) {
      throw Exception('Failed to add expense: ${e.toString()}');
    }
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    try {
      await _db.updateExpense(expense.toCompanion());
    } catch (e) {
      throw Exception('Failed to update expense: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      await _db.deleteExpense(id);
    } catch (e) {
      throw Exception('Failed to delete expense: ${e.toString()}');
    }
  }

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

  @override
  Future<PaginatedExpenses> getExpensesPaginated({
    int page = 0,
    int pageSize = 20,
    ExpenseFilters? filters,
  }) async {
    try {
      final offset = page * pageSize;

      // Convert filter types to indices
      final typeIndices = filters?.types?.map((t) => t.index).toList();

      // Get paginated expenses
      final expenseData = await _db.getExpensesPaginated(
        limit: pageSize,
        offset: offset,
        startDate: filters?.startDate,
        endDate: filters?.endDate,
        types: typeIndices,
        categoryIds: filters?.categoryIds,
        accountIds: filters?.accountIds,
        searchQuery: filters?.searchQuery,
      );

      final expenses = expenseData.map((e) => e.toDomain()).toList();

      // Get total count
      final totalCount = await _db.getExpenseCount(
        startDate: filters?.startDate,
        endDate: filters?.endDate,
        types: typeIndices,
        categoryIds: filters?.categoryIds,
        accountIds: filters?.accountIds,
        searchQuery: filters?.searchQuery,
      );

      // Preload categories and accounts
      final categoryIds = expenses
          .where((e) => e.categoryId != null)
          .map((e) => e.categoryId!)
          .toSet()
          .toList();

      final accountIds = expenses.map((e) => e.accountId).toSet().toList();

      final categoriesMap = <String, ExpenseCategory>{};
      if (categoryIds.isNotEmpty) {
        final categoriesData = await _db.select(_db.categoriesTable).get();
        for (final catData in categoriesData) {
          if (categoryIds.contains(catData.id)) {
            categoriesMap[catData.id] = catData.toDomain();
          }
        }
      }

      final accountsMap = <String, Account>{};
      if (accountIds.isNotEmpty) {
        final accountsData = await _db.select(_db.accountsTable).get();
        for (final accData in accountsData) {
          if (accountIds.contains(accData.id)) {
            accountsMap[accData.id] = accData.toDomain();
          }
        }
      }

      final hasMore = (offset + expenses.length) < totalCount;

      return PaginatedExpenses(
        expenses: expenses,
        totalCount: totalCount,
        currentPage: page,
        hasMore: hasMore,
        categories: categoriesMap,
        accounts: accountsMap,
      );
    } catch (e) {
      throw Exception('Failed to load paginated expenses: ${e.toString()}');
    }
  }

  @override
  Future<int> getExpenseCount({ExpenseFilters? filters}) async {
    try {
      final typeIndices = filters?.types?.map((t) => t.index).toList();

      return await _db.getExpenseCount(
        startDate: filters?.startDate,
        endDate: filters?.endDate,
        types: typeIndices,
        categoryIds: filters?.categoryIds,
        accountIds: filters?.accountIds,
        searchQuery: filters?.searchQuery,
      );
    } catch (e) {
      throw Exception('Failed to get expense count: ${e.toString()}');
    }
  }
} 