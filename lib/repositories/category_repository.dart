import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/expense_category.dart';

/// Abstract interface for category operations
abstract class CategoryRepository {
  static const String uncategorizedId = 'uncategorized';
  static final ExpenseCategory uncategorizedCategory = ExpenseCategory(
    id: uncategorizedId,
    name: 'Uncategorized',
    icon: Icons.help_outline,
  );

  static final List<ExpenseCategory> defaultCategories = [
    ExpenseCategory(id: 'food_dining', name: 'Food & Dining', icon: Icons.restaurant),
    ExpenseCategory(id: 'transportation', name: 'Transportation', icon: Icons.directions_car),
    ExpenseCategory(id: 'shopping', name: 'Shopping', icon: Icons.shopping_bag),
    ExpenseCategory(id: 'entertainment', name: 'Entertainment', icon: Icons.movie),
    ExpenseCategory(id: 'bills_utilities', name: 'Bills & Utilities', icon: Icons.receipt),
    ExpenseCategory(id: 'health', name: 'Health', icon: Icons.medical_services),
    ExpenseCategory(id: 'travel', name: 'Travel', icon: Icons.flight),
    ExpenseCategory(id: 'education', name: 'Education', icon: Icons.school),
    ExpenseCategory(id: 'other', name: 'Other', icon: Icons.more_horiz),
  ];

  /// Get all available categories (both default and custom)
  Future<List<ExpenseCategory>> getAllCategories();
  
  /// Find a category by its ID
  Future<ExpenseCategory?> findCategoryById(String id);
  
  /// Find a category by its name (for backward compatibility)
  Future<ExpenseCategory?> findCategoryByName(String name);
  
  /// Add a new custom category
  Future<void> addCategory(ExpenseCategory category);
  
  /// Update an existing category
  Future<void> updateCategory(ExpenseCategory oldCategory, ExpenseCategory newCategory);
  
  /// Check if a category is a default category
  Future<bool> isDefaultCategory(String id);
  
  /// Load categories from storage
  Future<void> loadCategories();
} 