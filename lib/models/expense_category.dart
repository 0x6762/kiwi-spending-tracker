import 'package:flutter/material.dart';

class ExpenseCategory {
  final String name;
  final IconData icon;

  const ExpenseCategory({
    required this.name,
    required this.icon,
  });
}

class ExpenseCategories {
  static const List<ExpenseCategory> values = [
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

  static ExpenseCategory? findByName(String name) {
    try {
      return values.firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }
}
