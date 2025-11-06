import '../models/expense_category.dart';
import '../utils/icons.dart';

/// Abstract interface for category operations
abstract class CategoryRepository {
  static const String uncategorizedId = 'uncategorized';
  static final ExpenseCategory uncategorizedCategory = ExpenseCategory(
    id: uncategorizedId,
    name: 'Uncategorized',
    icon: AppIcons.uncategorized,
  );

  static final List<ExpenseCategory> defaultCategories = [
    ExpenseCategory(id: 'food_dining', name: 'Food & Dining', icon: AppIcons.foodDining),
    ExpenseCategory(id: 'transportation', name: 'Transportation', icon: AppIcons.transportation),
    ExpenseCategory(id: 'shopping', name: 'Shopping', icon: AppIcons.shopping),
    ExpenseCategory(id: 'entertainment', name: 'Entertainment', icon: AppIcons.entertainment),
    ExpenseCategory(id: 'bills_utilities', name: 'Bills & Utilities', icon: AppIcons.billsUtilities),
    ExpenseCategory(id: 'health', name: 'Health', icon: AppIcons.health),
    ExpenseCategory(id: 'travel', name: 'Travel', icon: AppIcons.travel),
    ExpenseCategory(id: 'education', name: 'Education', icon: AppIcons.education),
    ExpenseCategory(id: 'other', name: 'Other', icon: AppIcons.more),
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