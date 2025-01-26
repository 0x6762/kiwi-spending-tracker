import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ExpenseCategory {
  final String name;
  final IconData icon;

  const ExpenseCategory({
    required this.name,
    required this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon.codePoint,
    };
  }

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      name: json['name'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
    );
  }
}

class ExpenseCategories {
  static const String _storageKey = 'custom_categories';
  static const String _editedDefaultsKey = 'edited_default_categories';
  static List<ExpenseCategory> _customCategories = [];
  static Map<String, ExpenseCategory> _editedDefaultCategories = {};

  static final List<ExpenseCategory> _defaultCategories = [
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

  static List<ExpenseCategory> get values {
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

  static ExpenseCategory? findByName(String name) {
    try {
      return values.firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }

  static Future<void> loadCustomCategories(SharedPreferences prefs) async {
    // Load custom categories
    final categoriesJson = prefs.getStringList(_storageKey);
    if (categoriesJson != null) {
      _customCategories = categoriesJson
          .map((json) => ExpenseCategory.fromJson(jsonDecode(json)))
          .toList();
    }

    // Load edited default categories
    final editedDefaultsJson = prefs.getStringList(_editedDefaultsKey);
    if (editedDefaultsJson != null) {
      _editedDefaultCategories = Map.fromEntries(editedDefaultsJson
          .map((json) => ExpenseCategory.fromJson(jsonDecode(json)))
          .map((category) => MapEntry(category.name, category)));
    }
  }

  static Future<void> updateCategory(
    ExpenseCategory oldCategory,
    ExpenseCategory newCategory,
    SharedPreferences prefs,
  ) async {
    // Check if it's a default category
    final isDefault =
        _defaultCategories.any((cat) => cat.name == oldCategory.name);

    if (isDefault) {
      // Store in edited defaults
      _editedDefaultCategories[oldCategory.name] = newCategory;
      await prefs.setStringList(
        _editedDefaultsKey,
        _editedDefaultCategories.values
            .map((cat) => jsonEncode(cat.toJson()))
            .toList(),
      );
    } else {
      // Update custom category
      final index =
          _customCategories.indexWhere((cat) => cat.name == oldCategory.name);
      if (index != -1) {
        _customCategories[index] = newCategory;
        await prefs.setStringList(
          _storageKey,
          _customCategories.map((cat) => jsonEncode(cat.toJson())).toList(),
        );
      }
    }
  }

  static Future<void> addCategory(
      ExpenseCategory category, SharedPreferences prefs) async {
    // Check if category name already exists
    if (findByName(category.name) != null) {
      throw Exception('A category with this name already exists');
    }

    _customCategories.add(category);
    await prefs.setStringList(
      _storageKey,
      _customCategories.map((cat) => jsonEncode(cat.toJson())).toList(),
    );
  }

  static bool isDefaultCategory(String name) {
    return _defaultCategories.any((category) => category.name == name);
  }
}
