import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';

/// Centralized state manager for expenses
/// Provides a single source of truth for expense data across the app
/// All screens can listen to this for automatic synchronization
class ExpenseStateManager extends ChangeNotifier {
  final ExpenseRepository _repository;

  ExpenseStateManager(this._repository);

  // Cache for all expenses (used by MainScreen)
  List<Expense>? _allExpenses;
  bool _isLoadingAll = false;

  // Getters
  List<Expense>? get allExpenses => _allExpenses;
  bool get isLoadingAll => _isLoadingAll;
  bool get hasCachedData => _allExpenses != null;

  /// Load all expenses (for MainScreen)
  Future<void> loadAllExpenses({bool forceRefresh = false}) async {
    // Return cached data if available and not forcing refresh
    if (!forceRefresh && _allExpenses != null) {
      return;
    }

    _isLoadingAll = true;
    notifyListeners();

    try {
      _allExpenses = await _repository.getAllExpenses();
      _isLoadingAll = false;
      notifyListeners();
    } catch (e) {
      _isLoadingAll = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Add an expense and notify all listeners
  Future<void> addExpense(Expense expense) async {
    try {
      // Save to repository
      await _repository.addExpense(expense);

      // Optimistically update cached data
      if (_allExpenses != null) {
        _allExpenses = [expense, ..._allExpenses!];
      }

      // Notify all listeners (MainScreen, AllExpensesScreen, etc.)
      notifyListeners();
    } catch (e) {
      // Revert optimistic update on error
      if (_allExpenses != null) {
        _allExpenses = _allExpenses!.where((e) => e.id != expense.id).toList();
      }
      notifyListeners();
      rethrow;
    }
  }

  /// Update an expense and notify all listeners
  Future<void> updateExpense(Expense expense) async {
    try {
      // Save to repository
      await _repository.updateExpense(expense);

      // Optimistically update cached data
      if (_allExpenses != null) {
        final index = _allExpenses!.indexWhere((e) => e.id == expense.id);
        if (index != -1) {
          _allExpenses![index] = expense;
        }
      }

      // Notify all listeners
      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }

  /// Delete an expense and notify all listeners
  Future<void> deleteExpense(String expenseId) async {
    try {
      // Delete from repository
      await _repository.deleteExpense(expenseId);

      // Optimistically update cached data
      if (_allExpenses != null) {
        _allExpenses = _allExpenses!.where((e) => e.id != expenseId).toList();
      }

      // Notify all listeners
      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }

  /// Invalidate cache - forces next load to fetch fresh data
  void invalidateCache() {
    _allExpenses = null;
    notifyListeners();
  }

  /// Refresh all expenses (force reload)
  Future<void> refreshAll() async {
    await loadAllExpenses(forceRefresh: true);
  }

  /// Process batch operations (add/update multiple expenses)
  /// Used by background services like RecurringExpenseService
  /// Notifies listeners once after all operations complete
  Future<void> processBatchExpenses({
    required List<Expense> expensesToAdd,
    required List<Expense> expensesToUpdate,
  }) async {
    try {
      // Save all to repository
      for (final expense in expensesToAdd) {
        await _repository.addExpense(expense);
      }
      for (final expense in expensesToUpdate) {
        await _repository.updateExpense(expense);
      }

      // Update cached data
      if (_allExpenses != null) {
        // Add new expenses
        _allExpenses = [...expensesToAdd, ..._allExpenses!];
        
        // Update existing expenses
        for (final updatedExpense in expensesToUpdate) {
          final index = _allExpenses!.indexWhere((e) => e.id == updatedExpense.id);
          if (index != -1) {
            _allExpenses![index] = updatedExpense;
          }
        }
      }

      // Notify all listeners once after batch is complete
      notifyListeners();
    } catch (e) {
      // On error, invalidate cache to force fresh load
      invalidateCache();
      rethrow;
    }
  }
}

