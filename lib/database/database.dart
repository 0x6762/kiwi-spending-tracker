import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'tables/expenses_table.dart';
import 'tables/categories_table.dart';
import 'tables/accounts_table.dart';
import '../models/expense.dart';

part 'database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'spending_tracker.db'));
    debugPrint('Database path: ${file.path}');
    return NativeDatabase(file);
  });
}

@DriftDatabase(
  tables: [
    ExpensesTable,
    CategoriesTable,
    AccountsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  static AppDatabase? _instance;

  AppDatabase._() : super(_openConnection());

  factory AppDatabase() {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          debugPrint('Database created successfully');
        },
        onUpgrade: (Migrator m, int from, int to) async {
          debugPrint('Upgrading database from version $from to $to');

          if (from < 4) {
            await m.createAll();
          }

          if (from < 5) {
            await m.createTable(expensesTable);

            await customStatement('''
              ALTER TABLE expenses_table RENAME TO expenses_table_old;
            ''');

            await customStatement('''
              CREATE TABLE expenses_table (
                id TEXT NOT NULL PRIMARY KEY,
                title TEXT NOT NULL,
                description TEXT,
                amount REAL NOT NULL,
                date INTEGER NOT NULL,
                created_at INTEGER NOT NULL,
                category_id TEXT,
                notes TEXT,
                type INTEGER NOT NULL,
                account_id TEXT NOT NULL,
                billing_cycle TEXT,
                next_billing_date INTEGER,
                due_date INTEGER,
                necessity INTEGER NOT NULL DEFAULT 1,
                is_recurring INTEGER NOT NULL DEFAULT 0,
                frequency INTEGER NOT NULL DEFAULT 0,
                status INTEGER NOT NULL DEFAULT 1,
                variable_amount REAL,
                end_date INTEGER,
                budget_id TEXT,
                payment_method TEXT,
                tags TEXT
              );
            ''');

            await customStatement('''
              INSERT INTO expenses_table (
                id, title, description, amount, date, created_at, 
                category_id, notes, type, account_id, billing_cycle, 
                next_billing_date, due_date, necessity, is_recurring, 
                frequency, status
              )
              SELECT 
                id, title, description, amount, date, created_at, 
                category_id, notes, type, account_id, billing_cycle, 
                next_billing_date, due_date, 1, 
                CASE WHEN type = 0 THEN 1 ELSE 0 END,
                CASE WHEN type = 0 THEN 2 ELSE 0 END,
                1
              FROM expenses_table_old;
            ''');

            await customStatement('''
              DROP TABLE expenses_table_old;
            ''');
          }

          if (from < 6) {
            // Migrate billingCycle to frequency for existing data
            // Monthly -> frequency = 4 (monthly enum index)
            await customStatement('''
              UPDATE expenses_table 
              SET frequency = 4 
              WHERE billing_cycle = 'Monthly' AND frequency = 0;
            ''');

            // Yearly -> frequency = 6 (yearly enum index)
            await customStatement('''
              UPDATE expenses_table 
              SET frequency = 6 
              WHERE billing_cycle = 'Yearly' AND frequency = 0;
            ''');

            // Drop billing_cycle column
            await customStatement('''
              ALTER TABLE expenses_table RENAME TO expenses_table_old;
            ''');

            await customStatement('''
              CREATE TABLE expenses_table (
                id TEXT NOT NULL PRIMARY KEY,
                title TEXT NOT NULL,
                description TEXT,
                amount REAL NOT NULL,
                date INTEGER NOT NULL,
                created_at INTEGER NOT NULL,
                category_id TEXT,
                notes TEXT,
                type INTEGER NOT NULL,
                account_id TEXT NOT NULL,
                next_billing_date INTEGER,
                due_date INTEGER,
                necessity INTEGER NOT NULL DEFAULT 1,
                is_recurring INTEGER NOT NULL DEFAULT 0,
                frequency INTEGER NOT NULL DEFAULT 0,
                status INTEGER NOT NULL DEFAULT 1,
                variable_amount REAL,
                end_date INTEGER,
                budget_id TEXT,
                payment_method TEXT,
                tags TEXT
              );
            ''');

            await customStatement('''
              INSERT INTO expenses_table (
                id, title, description, amount, date, created_at, 
                category_id, notes, type, account_id, 
                next_billing_date, due_date, necessity, is_recurring, 
                frequency, status, variable_amount, end_date, budget_id, 
                payment_method, tags
              )
              SELECT 
                id, title, description, amount, date, created_at, 
                category_id, notes, type, account_id, 
                next_billing_date, due_date, necessity, is_recurring, 
                frequency, status, variable_amount, end_date, budget_id, 
                payment_method, tags
              FROM expenses_table_old;
            ''');

            await customStatement('''
              DROP TABLE expenses_table_old;
            ''');
          }

          if (from < 7) {
            // Clean up invalid data: fixed and variable expenses should not be recurring
            // Set is_recurring = 0, frequency = 0 (oneTime), and clear next_billing_date
            // for any fixed or variable expenses that are incorrectly marked as recurring
            await customStatement('''
              UPDATE expenses_table 
              SET is_recurring = 0,
                  frequency = 0,
                  next_billing_date = NULL
              WHERE (type = 1 OR type = 2) 
                AND (is_recurring = 1 OR frequency != 0);
            ''');
            // Note: type = 1 is fixed, type = 2 is variable, type = 0 is subscription
            // frequency = 0 is oneTime
          }

          if (from < 8) {
            // Remove unused variable_amount column
            await customStatement('''
              ALTER TABLE expenses_table RENAME TO expenses_table_old;
            ''');

            await customStatement('''
              CREATE TABLE expenses_table (
                id TEXT NOT NULL PRIMARY KEY,
                title TEXT NOT NULL,
                description TEXT,
                amount REAL NOT NULL,
                date INTEGER NOT NULL,
                created_at INTEGER NOT NULL,
                category_id TEXT,
                notes TEXT,
                type INTEGER NOT NULL,
                account_id TEXT NOT NULL,
                next_billing_date INTEGER,
                due_date INTEGER,
                necessity INTEGER NOT NULL DEFAULT 1,
                is_recurring INTEGER NOT NULL DEFAULT 0,
                frequency INTEGER NOT NULL DEFAULT 0,
                status INTEGER NOT NULL DEFAULT 1,
                end_date INTEGER,
                budget_id TEXT,
                payment_method TEXT,
                tags TEXT
              );
            ''');

            await customStatement('''
              INSERT INTO expenses_table (
                id, title, description, amount, date, created_at, 
                category_id, notes, type, account_id, 
                next_billing_date, due_date, necessity, is_recurring, 
                frequency, status, end_date, budget_id, 
                payment_method, tags
              )
              SELECT 
                id, title, description, amount, date, created_at, 
                category_id, notes, type, account_id, 
                next_billing_date, due_date, necessity, is_recurring, 
                frequency, status, end_date, budget_id, 
                payment_method, tags
              FROM expenses_table_old;
            ''');

            await customStatement('''
              DROP TABLE expenses_table_old;
            ''');
          }

          if (from < 9) {
            // Remove type column - no longer needed
            await customStatement('''
              ALTER TABLE expenses_table RENAME TO expenses_table_old;
            ''');

            await customStatement('''
              CREATE TABLE expenses_table (
                id TEXT NOT NULL PRIMARY KEY,
                title TEXT NOT NULL,
                description TEXT,
                amount REAL NOT NULL,
                date INTEGER NOT NULL,
                created_at INTEGER NOT NULL,
                category_id TEXT,
                notes TEXT,
                account_id TEXT NOT NULL,
                next_billing_date INTEGER,
                due_date INTEGER,
                necessity INTEGER NOT NULL DEFAULT 1,
                is_recurring INTEGER NOT NULL DEFAULT 0,
                frequency INTEGER NOT NULL DEFAULT 0,
                status INTEGER NOT NULL DEFAULT 1,
                end_date INTEGER,
                budget_id TEXT,
                payment_method TEXT,
                tags TEXT
              );
            ''');

            await customStatement('''
              INSERT INTO expenses_table (
                id, title, description, amount, date, created_at, 
                category_id, notes, account_id, 
                next_billing_date, due_date, necessity, is_recurring, 
                frequency, status, end_date, budget_id, 
                payment_method, tags
              )
              SELECT 
                id, title, description, amount, date, created_at, 
                category_id, notes, account_id, 
                next_billing_date, due_date, necessity, is_recurring, 
                frequency, status, end_date, budget_id, 
                payment_method, tags
              FROM expenses_table_old;
            ''');

            await customStatement('''
              DROP TABLE expenses_table_old;
            ''');
          }
        },
        beforeOpen: (details) async {
          debugPrint('Opening database version ${details.versionNow}');
          // Only set foreign keys pragma here - this is essential and fast
          // Index creation is deferred to avoid blocking startup
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  @override
  Iterable<TableInfo> get allTables => [
        expensesTable,
        categoriesTable,
        accountsTable,
      ];

  Future<void> ensureIndexes() async {
    try {
      await transaction(() async {
        // Expenses indexes
        await customStatement(
          'CREATE INDEX IF NOT EXISTS expenses_date_idx ON expenses_table (date)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS expenses_category_idx ON expenses_table (category_id)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS expenses_type_idx ON expenses_table (type)',
        );

        // Accounts index
        await customStatement(
          'CREATE INDEX IF NOT EXISTS accounts_id_idx ON accounts_table (id)',
        );
      });
      debugPrint('Database indexes created/verified');
    } catch (e) {
      debugPrint('Error creating database indexes: $e');
      // Don't rethrow - indexes are optional for functionality
      // The app can work without them, just slower queries
    }
  }

  // Basic CRUD operations for Expenses
  Future<List<ExpenseTableData>> getAllExpenses() =>
      select(expensesTable).get();

  Stream<List<ExpenseTableData>> watchAllExpenses() =>
      select(expensesTable).watch();

  Future<ExpenseTableData> getExpenseById(String id) =>
      (select(expensesTable)..where((e) => e.id.equals(id))).getSingle();

  Future<int> insertExpense(ExpensesTableCompanion expense) =>
      into(expensesTable).insert(expense);

  Future<bool> updateExpense(ExpensesTableCompanion expense) =>
      update(expensesTable).replace(expense);

  Future<int> deleteExpense(String id) =>
      (delete(expensesTable)..where((e) => e.id.equals(id))).go();

  // Advanced query methods for Expenses
  Future<List<ExpenseTableData>> getExpensesByDateRange(
          DateTime start, DateTime end) =>
      (select(expensesTable)
            ..where((e) => e.date.isBetween(Variable(start), Variable(end)))
            ..orderBy([(e) => OrderingTerm(expression: e.date)]))
          .get();

  Stream<List<ExpenseTableData>> watchExpensesByDateRange(
          DateTime start, DateTime end) =>
      (select(expensesTable)
            ..where((e) => e.date.isBetween(Variable(start), Variable(end)))
            ..orderBy([(e) => OrderingTerm(expression: e.date)]))
          .watch();

  // Methods for current and upcoming expenses
  Future<List<ExpenseTableData>> getEffectiveExpenses(DateTime asOfDate) =>
      (select(expensesTable)
            ..where((e) =>
                // An expense is "effective" (current) if its date is on or before the reference date
                e.date.isSmallerOrEqual(Variable(asOfDate)) &
                // Still exclude cancelled expenses
                e.status.isNotIn([ExpenseStatus.cancelled.index]))
            ..orderBy([
              (e) => OrderingTerm(expression: e.date, mode: OrderingMode.desc)
            ]))
          .get();

  Future<List<ExpenseTableData>> getUpcomingExpenses(DateTime fromDate) =>
      (select(expensesTable)
            ..where((e) =>
                // An expense is "upcoming" if its date is after the reference date
                e.date.isBiggerThan(Variable(fromDate)) &
                // Still exclude cancelled expenses
                e.status.isNotIn([ExpenseStatus.cancelled.index]))
            ..orderBy([
              (e) => OrderingTerm(expression: e.date, mode: OrderingMode.asc)
            ]))
          .get();

  Future<List<ExpenseTableData>> getExpensesByCategory(String categoryId) =>
      (select(expensesTable)
            ..where((e) => e.categoryId.equals(categoryId))
            ..orderBy([
              (e) => OrderingTerm(expression: e.date, mode: OrderingMode.desc)
            ]))
          .get();

  // Aggregation queries
  Future<double> getTotalExpensesByDateRange(
      DateTime start, DateTime end) async {
    final query = selectOnly(expensesTable)
      ..addColumns([expensesTable.amount.sum()])
      ..where(expensesTable.date.isBetween(Variable(start), Variable(end)));

    final row = await query.getSingle();
    return (row.read(expensesTable.amount.sum()) ?? 0.0);
  }

  Future<Map<String, double>> getTotalsByCategory(
      DateTime start, DateTime end) async {
    final query = selectOnly(expensesTable)
      ..addColumns([expensesTable.categoryId, expensesTable.amount.sum()])
      ..where(expensesTable.date.isBetween(Variable(start), Variable(end)))
      ..groupBy([expensesTable.categoryId]);

    final rows = await query.get();
    return {
      for (final row in rows)
        (row.read(expensesTable.categoryId) ?? 'uncategorized'):
            (row.read(expensesTable.amount.sum()) ?? 0.0)
    };
  }

  // CRUD operations for Categories
  Future<List<CategoryTableData>> getAllCategories() =>
      select(categoriesTable).get();

  Stream<List<CategoryTableData>> watchAllCategories() =>
      select(categoriesTable).watch();

  Future<CategoryTableData> getCategoryById(String id) =>
      (select(categoriesTable)..where((c) => c.id.equals(id))).getSingle();

  Future<int> insertCategory(CategoriesTableCompanion category) =>
      into(categoriesTable).insert(category);

  Future<bool> updateCategory(CategoriesTableCompanion category) =>
      update(categoriesTable).replace(category);

  Future<int> deleteCategory(String id) =>
      (delete(categoriesTable)..where((c) => c.id.equals(id))).go();

  // Accounts operations
  Future<List<AccountsTableData>> getAllAccounts() =>
      select(accountsTable).get();

  Future<AccountsTableData> getAccountById(String id) =>
      (select(accountsTable)..where((t) => t.id.equals(id))).getSingle();

  Future<void> insertAccount(AccountsTableCompanion account) =>
      into(accountsTable).insert(account);

  Future<void> updateAccount(AccountsTableCompanion account) =>
      update(accountsTable).replace(account);

  Future<void> deleteAccount(String id) =>
      (delete(accountsTable)..where((t) => t.id.equals(id))).go();

  Future<List<ExpenseTableData>> getExpensesByNecessity(int necessityIndex) {
    return (select(expensesTable)
          ..where((tbl) => tbl.necessity.equals(necessityIndex))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<ExpenseTableData>> getRecurringExpenses() {
    return (select(expensesTable)
          ..where((tbl) => tbl.isRecurring.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<ExpenseTableData>> getExpensesByStatus(int statusIndex) {
    return (select(expensesTable)
          ..where((tbl) => tbl.status.equals(statusIndex))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<ExpenseTableData>> getExpensesByFrequency(int frequencyIndex) {
    return (select(expensesTable)
          ..where((tbl) => tbl.frequency.equals(frequencyIndex))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<ExpenseTableData>> getExpensesByBudget(String budgetId) {
    return (select(expensesTable)
          ..where((tbl) => tbl.budgetId.equals(budgetId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  // Streams for watching changes
  Stream<List<ExpenseTableData>> watchExpensesByNecessity(int necessityIndex) {
    return (select(expensesTable)
          ..where((tbl) => tbl.necessity.equals(necessityIndex))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Stream<List<ExpenseTableData>> watchRecurringExpenses() {
    return (select(expensesTable)
          ..where((tbl) => tbl.isRecurring.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Stream<List<ExpenseTableData>> watchExpensesByStatus(int statusIndex) {
    return (select(expensesTable)
          ..where((tbl) => tbl.status.equals(statusIndex))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Stream<List<ExpenseTableData>> watchExpensesByFrequency(int frequencyIndex) {
    return (select(expensesTable)
          ..where((tbl) => tbl.frequency.equals(frequencyIndex))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Stream<List<ExpenseTableData>> watchExpensesByBudget(String budgetId) {
    return (select(expensesTable)
          ..where((tbl) => tbl.budgetId.equals(budgetId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  // Pagination methods
  Future<List<ExpenseTableData>> getExpensesPaginated({
    required int limit,
    required int offset,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categoryIds,
    List<String>? accountIds,
    String? searchQuery,
  }) {
    final query = select(expensesTable);

    // Build where conditions
    final conditions = <Expression<bool>>[];

    if (startDate != null) {
      conditions.add(expensesTable.date.isBiggerOrEqualValue(startDate));
    }

    if (endDate != null) {
      conditions.add(expensesTable.date.isSmallerOrEqualValue(endDate));
    }

    if (categoryIds != null && categoryIds.isNotEmpty) {
      conditions.add(expensesTable.categoryId.isIn(categoryIds));
    }

    if (accountIds != null && accountIds.isNotEmpty) {
      conditions.add(expensesTable.accountId.isIn(accountIds));
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final searchLower = '%${searchQuery.toLowerCase()}%';
      conditions.add(expensesTable.title.lower().like(searchLower) |
          expensesTable.notes.lower().like(searchLower));
    }

    // Apply all conditions
    if (conditions.isNotEmpty) {
      query.where((_) {
        Expression<bool> combined = conditions.first;
        for (var i = 1; i < conditions.length; i++) {
          combined = combined & conditions[i];
        }
        return combined;
      });
    }

    // Order by date descending, then apply pagination
    query
      ..orderBy([(t) => OrderingTerm.desc(t.date)])
      ..limit(limit, offset: offset);

    return query.get();
  }

  Future<int> getExpenseCount({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categoryIds,
    List<String>? accountIds,
    String? searchQuery,
  }) async {
    final query = selectOnly(expensesTable)
      ..addColumns([expensesTable.id.count()]);

    // Build where conditions
    final conditions = <Expression<bool>>[];

    if (startDate != null) {
      conditions.add(expensesTable.date.isBiggerOrEqualValue(startDate));
    }

    if (endDate != null) {
      conditions.add(expensesTable.date.isSmallerOrEqualValue(endDate));
    }

    if (categoryIds != null && categoryIds.isNotEmpty) {
      conditions.add(expensesTable.categoryId.isIn(categoryIds));
    }

    if (accountIds != null && accountIds.isNotEmpty) {
      conditions.add(expensesTable.accountId.isIn(accountIds));
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final searchLower = '%${searchQuery.toLowerCase()}%';
      conditions.add(expensesTable.title.lower().like(searchLower) |
          expensesTable.notes.lower().like(searchLower));
    }

    // Apply all conditions
    if (conditions.isNotEmpty) {
      Expression<bool> combined = conditions.first;
      for (var i = 1; i < conditions.length; i++) {
        combined = combined & conditions[i];
      }
      query.where(combined);
    }

    final result = await query.getSingle();
    return result.read(expensesTable.id.count()) ?? 0;
  }
}
