import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense_category.dart';
import '../repositories/category_repository.dart';

class CategoryMigration {
  static const String _migrationCompleteKey = 'category_id_migration_complete';
  
  /// Migrates expenses from using category names to using category IDs
  static Future<void> migrateToIds(SharedPreferences prefs, CategoryRepository categoryRepo) async {
    // Check if migration has already been completed
    if (prefs.getBool(_migrationCompleteKey) == true) {
      return;
    }

    final expensesJson = prefs.getString('expenses');
    if (expensesJson == null) {
      // No expenses to migrate
      await prefs.setBool(_migrationCompleteKey, true);
      return;
    }

    try {
      final List<dynamic> expenses = json.decode(expensesJson);
      bool hasChanges = false;

      for (var i = 0; i < expenses.length; i++) {
        final expense = expenses[i];
        
        // Skip if already has categoryId
        if (expense['categoryId'] != null) {
          continue;
        }

        // Get old category name
        final oldCategory = expense['category'];
        if (oldCategory == null) {
          continue;
        }

        // Find category by name and update to use ID
        final category = await categoryRepo.findCategoryByName(oldCategory);
        if (category != null) {
          expense['categoryId'] = category.id;
          expense.remove('category'); // Remove old category field
          hasChanges = true;
        }
      }

      if (hasChanges) {
        await prefs.setString('expenses', json.encode(expenses));
      }

      // Mark migration as complete
      await prefs.setBool(_migrationCompleteKey, true);
    } catch (e) {
      print('Error during category migration: $e');
      // Don't mark as complete if there was an error
    }
  }
} 