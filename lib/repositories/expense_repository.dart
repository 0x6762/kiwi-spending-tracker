import '../models/expense.dart';

/// Abstract repository interface
abstract class ExpenseRepository {
  Future<List<Expense>> getAllExpenses();
  Future<void> addExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);
  
  // Pagination methods
  Future<List<Expense>> getExpensesPaginated({
    int limit = 20,
    int offset = 0,
    String? orderBy,
    bool descending = true,
  });
  Future<int> getExpensesCount();
  Future<List<Expense>> getExpensesByDateRangePaginated(
    DateTime start,
    DateTime end, {
    int limit = 20,
    int offset = 0,
  });
  Future<int> getExpensesByDateRangeCount(DateTime start, DateTime end);

  // Category-specific pagination methods
  Future<List<Expense>> getExpensesByCategoryPaginated(
    String categoryId, {
    int limit = 20,
    int offset = 0,
    String? orderBy,
    bool descending = true,
  });
  Future<int> getExpensesByCategoryCount(String categoryId);

  // Category and date range pagination methods
  Future<List<Expense>> getExpensesByCategoryAndDateRangePaginated(
    String categoryId,
    DateTime start,
    DateTime end, {
    int limit = 20,
    int offset = 0,
  });
  Future<int> getExpensesByCategoryAndDateRangeCount(String categoryId, DateTime start, DateTime end);
  
  // New methods for enhanced expense structure
  Future<List<Expense>> getExpensesByNecessity(ExpenseNecessity necessity);
  Future<List<Expense>> getRecurringExpenses();
  Future<List<Expense>> getExpensesByStatus(ExpenseStatus status);
  Future<List<Expense>> getExpensesByFrequency(ExpenseFrequency frequency);
  Future<List<Expense>> getExpensesByBudget(String budgetId);
  Future<List<Expense>> getExpensesByTags(List<String> tags);
  
  // New methods for upcoming expenses
  Future<List<Expense>> getEffectiveExpenses({DateTime? asOfDate});
  Future<List<Expense>> getUpcomingExpenses({DateTime? fromDate});
}
