import 'package:flutter/material.dart';
import '../database/database.dart';
import 'expense_repository.dart';
import 'category_repository.dart';
import 'account_repository.dart';
import 'drift_expense_repository.dart';
import 'drift_category_repository.dart';
import 'drift_account_repository.dart';

/// A provider that manages repository implementations
class RepositoryProvider extends ChangeNotifier {
  final AppDatabase database;
  final ExpenseRepository expenseRepository;
  final CategoryRepository categoryRepository;
  final AccountRepository accountRepository;
  
  RepositoryProvider({
    required this.database,
  }) : expenseRepository = DriftExpenseRepository(database),
       categoryRepository = DriftCategoryRepository(database),
       accountRepository = DriftAccountRepository(database);

  /// Initialize all repositories
  Future<void> initialize() async {
    try {
      // Load default accounts
      await accountRepository.loadAccounts();
    } catch (e) {
      debugPrint('Error initializing repositories: $e');
    }
  }
} 