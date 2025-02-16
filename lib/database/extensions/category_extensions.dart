import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../../models/expense_category.dart' as domain;
import '../database.dart';
import '../tables/categories_table.dart';

extension CategoryConversions on CategoryTableData {
  domain.ExpenseCategory toDomain() {
    return domain.ExpenseCategory(
      id: id,
      name: name,
      icon: IconData(
        iconCodePoint,
        fontFamily: iconFontFamily,
        fontPackage: iconFontPackage,
        matchTextDirection: iconMatchTextDirection,
      ),
    );
  }
}

extension CategoryTableConversion on domain.ExpenseCategory {
  CategoriesTableCompanion toCompanion() {
    return CategoriesTableCompanion(
      id: Value(id),
      name: Value(name),
      iconCodePoint: Value(icon.codePoint),
      iconFontFamily: Value(icon.fontFamily),
      iconFontPackage: Value(icon.fontPackage),
      iconMatchTextDirection: Value(icon.matchTextDirection),
    );
  }
} 