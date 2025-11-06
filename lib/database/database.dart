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
  int get schemaVersion => 5;

  Future<void> open() async {
    await _openConnection();
  }

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
        },
        beforeOpen: (details) async {
          debugPrint('Opening database version ${details.versionNow}');
          // Only set foreign keys pragma here - this is essential and fast
          // Index creation is deferred to avoid blocking startup
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  // Indexes for better performance
  @override
  Iterable<TableInfo> get allTables => [
        expensesTable,
        categoriesTable,
        accountsTable,
      ];

  List<Index> get allIndexes => [
        Index('expenses_date_idx',
            'CREATE INDEX expenses_date_idx ON ${expensesTable.actualTableName} (date)'),
        Index('expenses_category_idx',
            'CREATE INDEX expenses_category_idx ON ${expensesTable.actualTableName} (category_id)'),
        Index('expenses_type_idx',
            'CREATE INDEX expenses_type_idx ON ${expensesTable.actualTableName} (type)'),
        Index('accounts_id_idx',
            'CREATE INDEX accounts_id_idx ON ${accountsTable.actualTableName} (id)'),
      ];

  /// Ensure database indexes exist
  /// This is called asynchronously after app startup to avoid blocking the UI thread
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

  Future<List<ExpenseTableData>> getExpensesByType(ExpenseType type) =>
      (select(expensesTable)
            ..where((e) => e.type.equals(type.index))
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
}
