import 'expense.dart';
import 'expense_category.dart';
import 'account.dart';

/// Result of a paginated expense query with preloaded related data
class PaginatedExpenses {
  final List<Expense> expenses;
  final int totalCount;
  final int currentPage;
  final bool hasMore;
  
  // Preloaded related data to avoid N+1 queries
  final Map<String, ExpenseCategory> categories;
  final Map<String, Account> accounts;

  const PaginatedExpenses({
    required this.expenses,
    required this.totalCount,
    required this.currentPage,
    required this.hasMore,
    this.categories = const {},
    this.accounts = const {},
  });

  PaginatedExpenses copyWith({
    List<Expense>? expenses,
    int? totalCount,
    int? currentPage,
    bool? hasMore,
    Map<String, ExpenseCategory>? categories,
    Map<String, Account>? accounts,
  }) {
    return PaginatedExpenses(
      expenses: expenses ?? this.expenses,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      categories: categories ?? this.categories,
      accounts: accounts ?? this.accounts,
    );
  }

  /// Get category for an expense, returns null if not found
  ExpenseCategory? getCategoryForExpense(Expense expense) {
    if (expense.categoryId == null) return null;
    return categories[expense.categoryId];
  }

  /// Get account for an expense, returns null if not found
  Account? getAccountForExpense(Expense expense) {
    return accounts[expense.accountId];
  }
}

