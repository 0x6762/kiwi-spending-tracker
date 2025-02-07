import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ExpenseCategory {
  final String name;
  final IconData icon;

  // Map of const IconData instances
  static const Map<int, IconData> _iconMap = {
    0xe318: IconData(0xe318, fontFamily: 'MaterialIcons'), // restaurant
    0xe1d5: IconData(0xe1d5, fontFamily: 'MaterialIcons'), // directions_car
    0xe59c: IconData(0xe59c, fontFamily: 'MaterialIcons'), // shopping_bag
    0xe40c: IconData(0xe40c, fontFamily: 'MaterialIcons'), // movie
    0xe4d3: IconData(0xe4d3, fontFamily: 'MaterialIcons'), // receipt
    0xe3a4: IconData(0xe3a4, fontFamily: 'MaterialIcons'), // medical_services
    0xe1d8: IconData(0xe1d8, fontFamily: 'MaterialIcons'), // flight
    0xe559: IconData(0xe559, fontFamily: 'MaterialIcons'), // school
    0xe3dc: IconData(0xe3dc, fontFamily: 'MaterialIcons'), // more_horiz
    0xe33b: IconData(0xe33b, fontFamily: 'MaterialIcons'), // help_outline
    0xe1c4: IconData(0xe1c4, fontFamily: 'MaterialIcons'), // category_outlined
  };

  const ExpenseCategory({
    required this.name,
    required this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': {
        'codePoint': icon.codePoint,
        'fontFamily': icon.fontFamily,
        'fontPackage': icon.fontPackage,
        'matchTextDirection': icon.matchTextDirection,
      },
    };
  }

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    final iconData = json['icon'];
    IconData icon;
    
    if (iconData is Map) {
      // New format with full icon data
      icon = IconData(
        iconData['codePoint'],
        fontFamily: iconData['fontFamily'],
        fontPackage: iconData['fontPackage'],
        matchTextDirection: iconData['matchTextDirection'] ?? false,
      );
    } else {
      // Legacy format with just codePoint
      icon = IconData(
        iconData as int,
        fontFamily: 'MaterialIcons',
      );
    }

    return ExpenseCategory(
      name: json['name'],
      icon: icon,
    );
  }

  static IconData iconFromCodePoint(int codePoint) {
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCategory &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          icon.codePoint == other.icon.codePoint;

  @override
  int get hashCode => name.hashCode ^ icon.codePoint.hashCode;
}

class ExpenseCategories {
  static const String _storageKey = 'custom_categories';
  static const String _editedDefaultsKey = 'edited_default_categories';
  static const String uncategorized = 'Uncategorized';
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
    if (name == uncategorized) {
      return ExpenseCategory(name: uncategorized, icon: Icons.help_outline);
    }
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
    // First update the category itself
    if (isDefaultCategory(oldCategory.name)) {
      // Update edited default category
      _editedDefaultCategories[oldCategory.name] = newCategory;
      await prefs.setStringList(
        _editedDefaultsKey,
        _editedDefaultCategories.entries
            .map((e) => jsonEncode({
                  'originalName': e.key,
                  'category': e.value.toJson(),
                }))
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

    // Now update all expenses that use this category
    final expensesJson = prefs.getString('expenses');
    if (expensesJson != null) {
      final List<dynamic> expenses = json.decode(expensesJson);
      bool hasChanges = false;

      for (var i = 0; i < expenses.length; i++) {
        if (expenses[i]['category'] == oldCategory.name) {
          expenses[i]['category'] = newCategory.name;
          hasChanges = true;
        }
      }

      if (hasChanges) {
        await prefs.setString('expenses', json.encode(expenses));
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
