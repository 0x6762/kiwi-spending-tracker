import '../models/expense.dart';
import '../models/expense_filters.dart';
import '../models/paginated_expenses.dart';

/// Abstract repository interface
abstract class ExpenseRepository {
  Future<List<Expense>> getAllExpenses();
  Future<void> addExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);

  Future<List<Expense>> getExpensesByNecessity(ExpenseNecessity necessity);
  Future<List<Expense>> getRecurringExpenses();
  Future<List<Expense>> getExpensesByStatus(ExpenseStatus status);
  Future<List<Expense>> getExpensesByFrequency(ExpenseFrequency frequency);
  Future<List<Expense>> getExpensesByBudget(String budgetId);
  Future<List<Expense>> getExpensesByTags(List<String> tags);

  Future<List<Expense>> getEffectiveExpenses({DateTime? asOfDate});
  Future<List<Expense>> getUpcomingExpenses({DateTime? fromDate});

  /// Get expenses with pagination and filters
  Future<PaginatedExpenses> getExpensesPaginated({
    int page = 0,
    int pageSize = 20,
    ExpenseFilters? filters,
  });

  /// Get total count of expenses matching filters
  Future<int> getExpenseCount({ExpenseFilters? filters});
}
