import '../models/account.dart';

/// Abstract interface for account operations
abstract class AccountRepository {
  /// Get all available accounts (both default and custom)
  Future<List<Account>> getAllAccounts();
  
  /// Find an account by its ID
  Future<Account?> findAccountById(String id);
  
  /// Add a new custom account
  Future<void> addAccount(Account account);
  
  /// Update an existing account
  Future<void> updateAccount(Account oldAccount, Account newAccount);
  
  /// Check if an account is a default account
  Future<bool> isDefaultAccount(String id);
  
  /// Load accounts from storage
  Future<void> loadAccounts();

  /// Delete an account by its ID
  /// This will fail if the account is a default account
  Future<void> deleteAccount(String id);
} 