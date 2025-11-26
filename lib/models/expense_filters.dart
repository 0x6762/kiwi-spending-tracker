import 'expense.dart';

/// Simple filter model for expense queries
class ExpenseFilters {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<ExpenseType>? types;
  final List<String>? categoryIds;
  final List<String>? accountIds;
  final String? searchQuery;

  const ExpenseFilters({
    this.startDate,
    this.endDate,
    this.types,
    this.categoryIds,
    this.accountIds,
    this.searchQuery,
  });

  ExpenseFilters copyWith({
    DateTime? startDate,
    DateTime? endDate,
    List<ExpenseType>? types,
    List<String>? categoryIds,
    List<String>? accountIds,
    String? searchQuery,
  }) {
    return ExpenseFilters(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      types: types ?? this.types,
      categoryIds: categoryIds ?? this.categoryIds,
      accountIds: accountIds ?? this.accountIds,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasActiveFilters =>
      startDate != null ||
      endDate != null ||
      (types != null && types!.isNotEmpty) ||
      (categoryIds != null && categoryIds!.isNotEmpty) ||
      (accountIds != null && accountIds!.isNotEmpty) ||
      (searchQuery != null && searchQuery!.isNotEmpty);

  ExpenseFilters clear() => const ExpenseFilters();
}

