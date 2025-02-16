import 'package:flutter/material.dart';
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

    await _db.insertCategory(category.toCompanion());
  }

  @override
  Future<void> updateCategory(ExpenseCategory oldCategory, ExpenseCategory newCategory) async {
    await _db.updateCategory(newCategory.toCompanion());
  }

  @override
  Future<bool> isDefaultCategory(String id) async {
    return CategoryRepository.defaultCategories.any((category) => category.id == id);
  }

  @override
  Future<void> loadCategories() async {
    if (_isInitialized) return;

    // Insert default categories if they don't exist
    for (final category in CategoryRepository.defaultCategories) {
      try {
        await _db.getCategoryById(category.id);
      } catch (e) {
        // Category doesn't exist, insert it
        await _db.insertCategory(category.toCompanion());
      }
    }

    _isInitialized = true;
  }
} 