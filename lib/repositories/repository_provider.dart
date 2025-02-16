import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database.dart';
import 'expense_repository.dart';
import 'category_repository.dart';
import 'drift_expense_repository.dart';
import 'drift_category_repository.dart';

/// A provider that manages repository implementations
class RepositoryProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  final AppDatabase database;
  
  late final ExpenseRepository expenseRepository;
  late final CategoryRepository categoryRepository;
  
  RepositoryProvider({
    required this.prefs,
    required this.database,
    bool useDrift = true,
  }) {
    // Initialize repositories based on the storage type
    if (useDrift) {
      expenseRepository = DriftExpenseRepository(database);
      categoryRepository = DriftCategoryRepository(database);
    } else {
      expenseRepository = LocalStorageExpenseRepository(prefs);
      categoryRepository = SharedPrefsCategoryRepository(prefs);
    }
  }

  /// Switch between Drift and SharedPreferences implementations
  Future<void> switchImplementation(bool useDrift) async {
    if (useDrift) {
      expenseRepository = DriftExpenseRepository(database);
      categoryRepository = DriftCategoryRepository(database);
    } else {
      expenseRepository = LocalStorageExpenseRepository(prefs);
      categoryRepository = SharedPrefsCategoryRepository(prefs);
    }
    notifyListeners();
  }
} 