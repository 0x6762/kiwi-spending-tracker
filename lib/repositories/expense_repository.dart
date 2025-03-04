import '../models/expense.dart';

/// Abstract repository interface
abstract class ExpenseRepository {
  Future<List<Expense>> getAllExpenses();
  Future<void> addExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);
  
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
