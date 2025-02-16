import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../database/extensions/category_extensions.dart';
import '../models/expense_category.dart';
import 'category_repository.dart';

class DriftCategoryRepository implements CategoryRepository {
  final AppDatabase _db;
  bool _isInitialized = false;

  DriftCategoryRepository(this._db);

  @override
  Future<List<ExpenseCategory>> getAllCategories() async {
    final categories = await _db.getAllCategories();
    return categories.map((c) => c.toDomain()).toList();
  }

  @override
  Future<ExpenseCategory?> findCategoryById(String id) async {
    if (id == CategoryRepository.uncategorizedId) {
      return CategoryRepository.uncategorizedCategory;
    }

    try {
      final category = await _db.getCategoryById(id);
      return category.toDomain();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ExpenseCategory?> findCategoryByName(String name) async {
    if (name == 'Uncategorized') {
      return CategoryRepository.uncategorizedCategory;
    }

    final categories = await getAllCategories();
    try {
      return categories.firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addCategory(ExpenseCategory category) async {
    // Check if category ID already exists
    if (await findCategoryById(category.id) != null) {
      throw Exception('A category with this ID already exists');
    }

    // Also check if name exists for backward compatibility
    if (await findCategoryByName(category.name) != null) {
      throw Exception('A category with this name already exists');
    }

    // Convert to companion and set flags
    final companion = CategoriesTableCompanion.insert(
      id: category.id,
      name: category.name,
      iconCodePoint: category.icon.codePoint,
      iconFontFamily: Value(category.icon.fontFamily),
      iconFontPackage: Value(category.icon.fontPackage),
      iconMatchTextDirection: Value(category.icon.matchTextDirection),
      isDefault: const Value(false),
      isModified: const Value(false),
    );
    
    await _db.insertCategory(companion);
  }

  @override
  Future<void> updateCategory(ExpenseCategory oldCategory, ExpenseCategory newCategory) async {
    try {
      final existingCategory = await _db.getCategoryById(oldCategory.id);
      final isDefault = existingCategory.isDefault;
      
      await _db.updateCategory(CategoriesTableCompanion(
        id: Value(newCategory.id),
        name: Value(newCategory.name),
        iconCodePoint: Value(newCategory.icon.codePoint),
        iconFontFamily: Value(newCategory.icon.fontFamily),
        iconFontPackage: Value(newCategory.icon.fontPackage),
        iconMatchTextDirection: Value(newCategory.icon.matchTextDirection),
        isDefault: Value(isDefault),
        isModified: Value(isDefault), // Only mark as modified if it's a default category
      ));
    } catch (e) {
      debugPrint('Error updating category: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isDefaultCategory(String id) async {
    try {
      final category = await _db.getCategoryById(id);
      return category.isDefault;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> loadCategories() async {
    if (_isInitialized) return;

    // Insert default categories if they don't exist
    for (final category in CategoryRepository.defaultCategories) {
      try {
        await _db.getCategoryById(category.id);
      } catch (e) {
        // Category doesn't exist, insert it with default flags
        final companion = CategoriesTableCompanion.insert(
          id: category.id,
          name: category.name,
          iconCodePoint: category.icon.codePoint,
          iconFontFamily: Value(category.icon.fontFamily),
          iconFontPackage: Value(category.icon.fontPackage),
          iconMatchTextDirection: Value(category.icon.matchTextDirection),
          isDefault: const Value(true),
          isModified: const Value(false),
        );
        await _db.insertCategory(companion);
      }
    }

    _isInitialized = true;
  }
} 