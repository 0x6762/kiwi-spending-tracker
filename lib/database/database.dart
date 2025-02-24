import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'tables/expenses_table.dart';
import 'tables/categories_table.dart';
import 'tables/accounts_table.dart';

part 'database.g.dart';

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
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          debugPrint('Database created successfully');
        },
        onUpgrade: (Migrator m, int from, int to) async {
          debugPrint('Upgrading database from version $from to $to');
          // If we're upgrading from a version before 4
          if (from < 4) {
            // Keep existing tables and data
            await m.createAll();
          }
        },
        beforeOpen: (details) async {
          debugPrint('Opening database version ${details.versionNow}');
          await customStatement('PRAGMA foreign_keys = ON');
          
          // Create indexes if they don't exist
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
        },
      );

  // Indexes for better performance
  @override
  Iterable<TableInfo> get allTables => [
        expensesTable,
        categoriesTable,
        accountsTable,
      ];

  @override
  List<Index> get allIndexes => [
        Index('expenses_date_idx', 'CREATE INDEX expenses_date_idx ON ${expensesTable.actualTableName} (date)'),
        Index('expenses_category_idx', 'CREATE INDEX expenses_category_idx ON ${expensesTable.actualTableName} (category_id)'),
        Index('expenses_type_idx', 'CREATE INDEX expenses_type_idx ON ${expensesTable.actualTableName} (type)'),
        Index('accounts_id_idx', 'CREATE INDEX accounts_id_idx ON ${accountsTable.actualTableName} (id)'),
      ];

  // Basic CRUD operations for Expenses
  Future<List<ExpenseTableData>> getAllExpenses() => select(expensesTable).get();
  
  Stream<List<ExpenseTableData>> watchAllExpenses() => select(expensesTable).watch();
  
  Future<ExpenseTableData> getExpenseById(String id) =>
      (select(expensesTable)..where((e) => e.id.equals(id))).getSingle();
  
  Future<int> insertExpense(ExpensesTableCompanion expense) =>
      into(expensesTable).insert(expense);
  
  Future<bool> updateExpense(ExpensesTableCompanion expense) =>
      update(expensesTable).replace(expense);
  
  Future<int> deleteExpense(String id) =>
      (delete(expensesTable)..where((e) => e.id.equals(id))).go();

  // Advanced query methods for Expenses
  Future<List<ExpenseTableData>> getExpensesByDateRange(DateTime start, DateTime end) =>
      (select(expensesTable)
        ..where((e) => e.date.isBetween(Variable(start), Variable(end)))
        ..orderBy([(e) => OrderingTerm(expression: e.date)]))
      .get();

  Stream<List<ExpenseTableData>> watchExpensesByDateRange(DateTime start, DateTime end) =>
      (select(expensesTable)
        ..where((e) => e.date.isBetween(Variable(start), Variable(end)))
        ..orderBy([(e) => OrderingTerm(expression: e.date)]))
      .watch();

  Future<List<ExpenseTableData>> getExpensesByCategory(String categoryId) =>
      (select(expensesTable)
        ..where((e) => e.categoryId.equals(categoryId))
        ..orderBy([(e) => OrderingTerm(expression: e.date, mode: OrderingMode.desc)]))
      .get();

  Future<List<ExpenseTableData>> getExpensesByType(ExpenseType type) =>
      (select(expensesTable)
        ..where((e) => e.type.equals(type.index))
        ..orderBy([(e) => OrderingTerm(expression: e.date, mode: OrderingMode.desc)]))
      .get();

  // Aggregation queries
  Future<double> getTotalExpensesByDateRange(DateTime start, DateTime end) async {
    final query = selectOnly(expensesTable)
      ..addColumns([expensesTable.amount.sum()])
      ..where(expensesTable.date.isBetween(Variable(start), Variable(end)));
    
    final row = await query.getSingle();
    return (row.read(expensesTable.amount.sum()) ?? 0.0);
  }

  Future<Map<String, double>> getTotalsByCategory(DateTime start, DateTime end) async {
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
  Future<List<CategoryTableData>> getAllCategories() => select(categoriesTable).get();
  
  Stream<List<CategoryTableData>> watchAllCategories() => select(categoriesTable).watch();
  
  Future<CategoryTableData> getCategoryById(String id) =>
      (select(categoriesTable)..where((c) => c.id.equals(id))).getSingle();
  
  Future<int> insertCategory(CategoriesTableCompanion category) =>
      into(categoriesTable).insert(category);
  
  Future<bool> updateCategory(CategoriesTableCompanion category) =>
      update(categoriesTable).replace(category);
  
  Future<int> deleteCategory(String id) =>
      (delete(categoriesTable)..where((c) => c.id.equals(id))).go();

  // Accounts operations
  Future<List<AccountsTableData>> getAllAccounts() => select(accountsTable).get();
  
  Future<AccountsTableData> getAccountById(String id) =>
      (select(accountsTable)..where((t) => t.id.equals(id)))
          .getSingle();
          
  Future<void> insertAccount(AccountsTableCompanion account) =>
      into(accountsTable).insert(account);
      
  Future<void> updateAccount(AccountsTableCompanion account) =>
      update(accountsTable).replace(account);
      
  Future<void> deleteAccount(String id) =>
      (delete(accountsTable)..where((t) => t.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'spending_tracker.db'));
    debugPrint('Database path: ${file.path}');
    return NativeDatabase.createInBackground(file);
  });
} 