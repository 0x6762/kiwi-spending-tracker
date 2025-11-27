import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/account.dart';
import '../models/expense_filters.dart';
import '../models/paginated_expenses.dart';
import '../repositories/expense_repository.dart';

/// Simple provider for managing expense list state with pagination
class ExpenseListProvider extends ChangeNotifier {
  final ExpenseRepository _repository;

  ExpenseListProvider(this._repository);

  // State
  List<Expense> _expenses = [];
  PaginatedExpenses? _currentPage;
  ExpenseFilters _filters = const ExpenseFilters();
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPageNumber = 0;
  static const int _pageSize = 20;

  // Getters
  List<Expense> get expenses => _expenses;
  ExpenseFilters get filters => _filters;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _currentPage?.hasMore ?? false;
  String? get error => _error;
  int get totalCount => _currentPage?.totalCount ?? 0;

  /// Get category for an expense from cached data
  ExpenseCategory? getCategoryForExpense(Expense expense) {
    return _currentPage?.getCategoryForExpense(expense);
  }

  /// Get account for an expense from cached data
  Account? getAccountForExpense(Expense expense) {
    return _currentPage?.getAccountForExpense(expense);
  }

  /// Load first page of expenses
  Future<void> loadExpenses({ExpenseFilters? newFilters}) async {
    _isLoading = true;
    _error = null;
    _currentPageNumber = 0;
    _expenses = [];
    
    if (newFilters != null) {
      _filters = newFilters;
    }
    
    notifyListeners();

    try {
      final result = await _repository.getExpensesPaginated(
        page: 0,
        pageSize: _pageSize,
        filters: _filters,
      );

      _currentPage = result;
      _expenses = result.expenses;
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Load next page of expenses
  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPageNumber + 1;
      final result = await _repository.getExpensesPaginated(
        page: nextPage,
        pageSize: _pageSize,
        filters: _filters,
      );

      _currentPageNumber = nextPage;
      _expenses.addAll(result.expenses);
      
      // Merge categories and accounts
      _currentPage = _currentPage?.copyWith(
        expenses: _expenses,
        totalCount: result.totalCount,
        currentPage: nextPage,
        hasMore: result.hasMore,
        categories: {..._currentPage!.categories, ...result.categories},
        accounts: {..._currentPage!.accounts, ...result.accounts},
      );

      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMore = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Apply filters and reload
  Future<void> applyFilters(ExpenseFilters newFilters) async {
    await loadExpenses(newFilters: newFilters);
  }

  /// Clear filters and reload
  Future<void> clearFilters() async {
    await loadExpenses(newFilters: const ExpenseFilters());
  }

  /// Refresh - reload current data
  Future<void> refresh() async {
    await loadExpenses();
  }

  /// Add an expense to the list without saving (for use with ExpenseStateManager)
  /// This is used when ExpenseStateManager has already saved the expense
  void addExpenseToList(Expense expense) {
    // Optimistically add to local list (insert at beginning for newest first)
    _expenses.insert(0, expense);
    
    // Update total count
    if (_currentPage != null) {
      _currentPage = _currentPage!.copyWith(
        expenses: _expenses,
        totalCount: _currentPage!.totalCount + 1,
      );
    }
    
    notifyListeners();
  }

  /// Remove an expense from the list without saving (for use with ExpenseStateManager)
  /// This is used when ExpenseStateManager has already deleted the expense
  void removeExpenseFromList(String expenseId) {
    // Remove from local list
    _expenses.removeWhere((e) => e.id == expenseId);
    
    // Update total count
    if (_currentPage != null) {
      _currentPage = _currentPage!.copyWith(
        expenses: _expenses,
        totalCount: _currentPage!.totalCount - 1,
      );
    }
    
    notifyListeners();
    
    // If we're running low on items and have more, load more
    if (_expenses.length < _pageSize && hasMore) {
      loadMore();
    }
  }

  /// Update an expense in the list
  void updateExpenseInList(Expense updatedExpense) {
    final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
    if (index != -1) {
      _expenses[index] = updatedExpense;
      notifyListeners();
    }
  }
}

