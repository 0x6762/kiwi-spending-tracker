import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense_category.dart';

/// Abstract interface for category operations
abstract class CategoryRepository {
  /// Get all available categories (both default and custom)
  Future<List<ExpenseCategory>> getAllCategories();
  
  /// Find a category by its name
  Future<ExpenseCategory?> findCategoryByName(String name);
  
  /// Add a new custom category
  Future<void> addCategory(ExpenseCategory category);
  
  /// Update an existing category
  Future<void> updateCategory(ExpenseCategory oldCategory, ExpenseCategory newCategory);
  
  /// Check if a category is a default category
  Future<bool> isDefaultCategory(String name);
  
  /// Load categories from storage
  Future<void> loadCategories();
}

/// Implementation using SharedPreferences (matches current functionality)
class SharedPrefsCategoryRepository implements CategoryRepository {
  static const String _storageKey = 'custom_categories';
  static const String _editedDefaultsKey = 'edited_default_categories';
  final SharedPreferences _prefs;
  
  List<ExpenseCategory> _customCategories = [];
  Map<String, ExpenseCategory> _editedDefaultCategories = {};
  
  final List<ExpenseCategory> _defaultCategories = [
    ExpenseCategory(name: 'Food & Dining', icon: Icons.restaurant),
    ExpenseCategory(name: 'Transportation', icon: Icons.directions_car),
    ExpenseCategory(name: 'Shopping', icon: Icons.shopping_bag),
    ExpenseCategory(name: 'Entertainment', icon: Icons.movie),
    ExpenseCategory(name: 'Bills & Utilities', icon: Icons.receipt),
    ExpenseCategory(name: 'Health', icon: Icons.medical_services),
    ExpenseCategory(name: 'Travel', icon: Icons.flight),
    ExpenseCategory(name: 'Education', icon: Icons.school),
    ExpenseCategory(name: 'Other', icon: Icons.more_horiz),
  ];

  SharedPrefsCategoryRepository(this._prefs);

  @override
  Future<List<ExpenseCategory>> getAllCategories() async {
    final categories = <ExpenseCategory>[];
    
    // Add default categories (or their edited versions if they exist)
    for (final defaultCategory in _defaultCategories) {
      categories.add(
          _editedDefaultCategories[defaultCategory.name] ?? defaultCategory);
    }
    
    // Add custom categories
    categories.addAll(_customCategories);
    
    return categories;
  }

  @override
  Future<ExpenseCategory?> findCategoryByName(String name) async {
    if (name == 'Uncategorized') {
      return ExpenseCategory(name: 'Uncategorized', icon: Icons.help_outline);
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
    // Check if category name already exists
    if (await findCategoryByName(category.name) != null) {
      throw Exception('A category with this name already exists');
    }

    _customCategories.add(category);
    await _saveCustomCategories();
  }

  @override
  Future<void> updateCategory(
    ExpenseCategory oldCategory,
    ExpenseCategory newCategory,
  ) async {
    if (await isDefaultCategory(oldCategory.name)) {
      // Update edited default category
      _editedDefaultCategories[oldCategory.name] = newCategory;
      await _saveEditedDefaults();
    } else {
      // Update custom category
      final index = _customCategories.indexWhere(
        (cat) => cat.name == oldCategory.name,
      );
      if (index != -1) {
        _customCategories[index] = newCategory;
        await _saveCustomCategories();
      }
    }

    // Update all expenses that use this category
    await _updateExpenseCategories(oldCategory.name, newCategory.name);
  }

  @override
  Future<bool> isDefaultCategory(String name) async {
    return _defaultCategories.any((category) => category.name == name);
  }

  @override
  Future<void> loadCategories() async {
    // Load custom categories
    final categoriesJson = _prefs.getStringList(_storageKey);
    if (categoriesJson != null) {
      _customCategories = categoriesJson
          .map((json) => ExpenseCategory.fromJson(jsonDecode(json)))
          .toList();
    }

    // Load edited default categories
    final editedDefaultsJson = _prefs.getStringList(_editedDefaultsKey);
    if (editedDefaultsJson != null) {
      _editedDefaultCategories = Map.fromEntries(
        editedDefaultsJson
            .map((json) => ExpenseCategory.fromJson(jsonDecode(json)))
            .map((category) => MapEntry(category.name, category)),
      );
    }
  }

  // Private helper methods
  Future<void> _saveCustomCategories() async {
    await _prefs.setStringList(
      _storageKey,
      _customCategories.map((cat) => jsonEncode(cat.toJson())).toList(),
    );
  }

  Future<void> _saveEditedDefaults() async {
    await _prefs.setStringList(
      _editedDefaultsKey,
      _editedDefaultCategories.entries
          .map((e) => jsonEncode(e.value.toJson()))
          .toList(),
    );
  }

  Future<void> _updateExpenseCategories(
    String oldCategoryName,
    String newCategoryName,
  ) async {
    final expensesJson = _prefs.getString('expenses');
    if (expensesJson != null) {
      final List<dynamic> expenses = json.decode(expensesJson);
      bool hasChanges = false;

      for (var i = 0; i < expenses.length; i++) {
        if (expenses[i]['category'] == oldCategoryName) {
          expenses[i]['category'] = newCategoryName;
          hasChanges = true;
        }
      }

      if (hasChanges) {
        await _prefs.setString('expenses', json.encode(expenses));
      }
    }
  }
} 