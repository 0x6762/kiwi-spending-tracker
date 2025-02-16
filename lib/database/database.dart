import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables/expenses_table.dart';
import 'tables/categories_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    ExpensesTable,
    CategoriesTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // CRUD operations for Expenses
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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'spending_tracker.db'));
    return NativeDatabase.createInBackground(file);
  });
} 