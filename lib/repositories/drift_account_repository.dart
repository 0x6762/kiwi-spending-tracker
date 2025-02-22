import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../database/extensions/account_extensions.dart';
import '../models/account.dart';
import 'account_repository.dart';

class DriftAccountRepository implements AccountRepository {
  final AppDatabase _db;
  bool _isInitialized = false;

  DriftAccountRepository(this._db);

  @override
  Future<List<Account>> getAllAccounts() async {
    final accounts = await _db.getAllAccounts();
    return accounts.map((a) => a.toDomain()).toList();
  }

  @override
  Future<Account?> findAccountById(String id) async {
    try {
      final account = await _db.getAccountById(id);
      return account.toDomain();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addAccount(Account account) async {
    // Check if account ID already exists
    if (await findAccountById(account.id) != null) {
      throw Exception('An account with this ID already exists');
    }

    await _db.insertAccount(account.toCompanion());
  }

  @override
  Future<void> updateAccount(Account oldAccount, Account newAccount) async {
    try {
      final existingAccount = await _db.getAccountById(oldAccount.id);
      final isDefault = existingAccount.isDefault;
      
      await _db.updateAccount(newAccount.toCompanion());
    } catch (e) {
      debugPrint('Error updating account: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isDefaultAccount(String id) async {
    try {
      final account = await _db.getAccountById(id);
      return account.isDefault;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> loadAccounts() async {
    if (_isInitialized) return;

    // Insert default accounts if they don't exist
    for (final account in DefaultAccounts.defaultAccounts) {
      try {
        await _db.getAccountById(account.id);
      } catch (e) {
        // Account doesn't exist, insert it
        await _db.insertAccount(account.toCompanion());
      }
    }

    _isInitialized = true;
  }

  Future<bool> _hasExpenses(String accountId) async {
    final expenses = await (_db.select(_db.expensesTable)
      ..where((e) => e.accountId.equals(accountId))
      ..limit(1))
      .get();
    return expenses.isNotEmpty;
  }

  @override
  Future<void> deleteAccount(String id) async {
    // Check if it's a default account
    if (await isDefaultAccount(id)) {
      throw Exception('Cannot delete a default account');
    }

    // Check if the account exists
    final account = await findAccountById(id);
    if (account == null) {
      throw Exception('Account not found');
    }

    // Check if the account has any expenses
    if (await _hasExpenses(id)) {
      throw Exception('Cannot delete account with existing expenses. Please reassign or delete the expenses first.');
    }

    // Delete the account
    await _db.deleteAccount(id);
  }
} 