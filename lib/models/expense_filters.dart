/// Simple filter model for expense queries
class ExpenseFilters {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? categoryIds;
  final List<String>? accountIds;
  final String? searchQuery;

  const ExpenseFilters({
    this.startDate,
    this.endDate,
    this.categoryIds,
    this.accountIds,
    this.searchQuery,
  });

  ExpenseFilters copyWith({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categoryIds,
    List<String>? accountIds,
    String? searchQuery,
  }) {
    return ExpenseFilters(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categoryIds: categoryIds ?? this.categoryIds,
      accountIds: accountIds ?? this.accountIds,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasActiveFilters =>
      startDate != null ||
      endDate != null ||
      (categoryIds != null && categoryIds!.isNotEmpty) ||
      (accountIds != null && accountIds!.isNotEmpty) ||
      (searchQuery != null && searchQuery!.isNotEmpty);

  ExpenseFilters clear() => const ExpenseFilters();
}
