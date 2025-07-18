import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../services/recurring_expense_service.dart';
import 'package:uuid/uuid.dart';

/// Represents an upcoming expense with additional context
class UpcomingExpenseItem {
  final Expense expense;
  final bool isRecurringTemplate;
  final bool isGeneratedInstance;
  final DateTime? nextOccurrenceDate;
  final String? recurringTemplateId;

  UpcomingExpenseItem({
    required this.expense,
    this.isRecurringTemplate = false,
    this.isGeneratedInstance = false,
    this.nextOccurrenceDate,
    this.recurringTemplateId,
  });

  /// Get the effective date for sorting and display
  DateTime get effectiveDate {
    if (isRecurringTemplate && nextOccurrenceDate != null) {
      return nextOccurrenceDate!;
    }
    return expense.date;
  }

  /// Get the display amount (for recurring templates, this is the template amount)
  double get displayAmount => expense.amount;

  /// Get a user-friendly description of the expense type
  String get typeDescription {
    if (isRecurringTemplate) {
      return 'Recurring ${_getExpenseTypeLabel(expense.type)}';
    } else if (isGeneratedInstance) {
      return 'Generated ${_getExpenseTypeLabel(expense.type)}';
    } else {
      return _getExpenseTypeLabel(expense.type);
    }
  }

  String _getExpenseTypeLabel(ExpenseType type) {
    switch (type) {
      case ExpenseType.subscription:
        return 'Subscription';
      case ExpenseType.fixed:
        return 'Fixed Expense';
      case ExpenseType.variable:
        return 'Variable Expense';
    }
  }
}

/// Unified service for handling all upcoming expenses
/// Combines recurring expense templates and manually created future expenses
class UnifiedUpcomingService {
  final ExpenseRepository _expenseRepo;
  final RecurringExpenseService _recurringService;
  final Uuid _uuid = const Uuid();

  UnifiedUpcomingService(this._expenseRepo, this._recurringService);



  /// Get all upcoming expenses within a specified time range
  Future<List<UpcomingExpenseItem>> getUpcomingExpenses({
    int daysAhead = 30,
    DateTime? fromDate,
    bool includeRecurringTemplates = true,
    bool includeManualExpenses = true,
    bool includeGeneratedInstances = true,
  }) async {
    final now = DateTime.now();
    final referenceDate = fromDate ?? now;
    final futureDate = referenceDate.add(Duration(days: daysAhead));
    
    final upcomingItems = <UpcomingExpenseItem>[];

    // 1. Get manual future expenses (non-recurring)
    if (includeManualExpenses) {
      final manualUpcoming = await _getManualUpcomingExpenses(referenceDate, futureDate);
      upcomingItems.addAll(manualUpcoming);
    }

    // 2. Get recurring expense templates that will generate expenses soon
    if (includeRecurringTemplates) {
      final recurringUpcoming = await _getRecurringTemplateUpcoming(referenceDate, futureDate);
      upcomingItems.addAll(recurringUpcoming);
    }

    // 3. Get generated instances from recurring expenses
    if (includeGeneratedInstances) {
      final generatedUpcoming = await _getGeneratedInstanceUpcoming(referenceDate, futureDate);
      upcomingItems.addAll(generatedUpcoming);
    }

    // Sort by effective date (earliest first)
    upcomingItems.sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate));

    return upcomingItems;
  }

  /// Get upcoming expenses grouped by type
  Future<Map<String, List<UpcomingExpenseItem>>> getUpcomingExpensesByType({
    int daysAhead = 30,
    DateTime? fromDate,
  }) async {
    final upcoming = await getUpcomingExpenses(
      daysAhead: daysAhead,
      fromDate: fromDate,
    );

    final grouped = <String, List<UpcomingExpenseItem>>{};
    
    for (final item in upcoming) {
      final key = item.typeDescription;
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return grouped;
  }

  /// Get upcoming expenses for a specific expense type
  Future<List<UpcomingExpenseItem>> getUpcomingExpensesByExpenseType({
    required ExpenseType type,
    int daysAhead = 30,
    DateTime? fromDate,
  }) async {
    final allUpcoming = await getUpcomingExpenses(
      daysAhead: daysAhead,
      fromDate: fromDate,
    );

    return allUpcoming.where((item) => item.expense.type == type).toList();
  }

  /// Get total upcoming amount within a time range
  Future<double> getTotalUpcomingAmount({
    int daysAhead = 30,
    DateTime? fromDate,
  }) async {
    final upcoming = await getUpcomingExpenses(
      daysAhead: daysAhead,
      fromDate: fromDate,
    );

    return upcoming.fold<double>(0.0, (sum, item) => sum + item.displayAmount);
  }

  /// Get upcoming expenses summary with breakdowns
  Future<UpcomingExpensesSummary> getUpcomingExpensesSummary({
    int daysAhead = 30,
    DateTime? fromDate,
  }) async {
    final upcoming = await getUpcomingExpenses(
      daysAhead: daysAhead,
      fromDate: fromDate,
    );

    double totalAmount = 0.0;
    double recurringAmount = 0.0;
    double manualAmount = 0.0;
    int recurringCount = 0;
    int manualCount = 0;

    for (final item in upcoming) {
      totalAmount += item.displayAmount;
      
      if (item.isRecurringTemplate) {
        recurringAmount += item.displayAmount;
        recurringCount++;
      } else {
        manualAmount += item.displayAmount;
        manualCount++;
      }
    }

    return UpcomingExpensesSummary(
      totalAmount: totalAmount,
      recurringAmount: recurringAmount,
      manualAmount: manualAmount,
      totalCount: upcoming.length,
      recurringCount: recurringCount,
      manualCount: manualCount,
      fromDate: fromDate ?? DateTime.now(),
      toDate: (fromDate ?? DateTime.now()).add(Duration(days: daysAhead)),
    );
  }

  /// Get overdue recurring expenses that should have been processed
  Future<List<UpcomingExpenseItem>> getOverdueRecurringExpenses() async {
    final now = DateTime.now();
    final templates = await _recurringService.getRecurringTemplates();
    final overdue = <UpcomingExpenseItem>[];

    for (final template in templates) {
      final nextDate = template.nextBillingDate;
      if (nextDate != null && nextDate.isBefore(now)) {
        overdue.add(UpcomingExpenseItem(
          expense: template,
          isRecurringTemplate: true,
          nextOccurrenceDate: nextDate,
        ));
      }
    }

    return overdue;
  }

  /// Get expenses due today
  Future<List<UpcomingExpenseItem>> getExpensesDueToday() async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return await getUpcomingExpenses(
      fromDate: todayStart,
      daysAhead: 1,
    );
  }

  /// Get expenses due this week
  Future<List<UpcomingExpenseItem>> getExpensesDueThisWeek() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final weekEnd = weekStartDate.add(const Duration(days: 7));

    return await getUpcomingExpenses(
      fromDate: weekStartDate,
      daysAhead: 7,
    );
  }

  /// Get expenses due this month
  Future<List<UpcomingExpenseItem>> getExpensesDueThisMonth() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);
    final daysInMonth = monthEnd.difference(monthStart).inDays;

    return await getUpcomingExpenses(
      fromDate: monthStart,
      daysAhead: daysInMonth,
    );
  }

  // Private helper methods

  /// Get manual (non-recurring) upcoming expenses
  Future<List<UpcomingExpenseItem>> _getManualUpcomingExpenses(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    final allExpenses = await _expenseRepo.getAllExpenses();
    final manualUpcoming = <UpcomingExpenseItem>[];

    for (final expense in allExpenses) {
      // Only include non-recurring expenses with future dates
      if (!expense.isRecurring && 
          expense.date.isAfter(fromDate) && 
          expense.date.isBefore(toDate)) {
        manualUpcoming.add(UpcomingExpenseItem(
          expense: expense,
          isRecurringTemplate: false,
          isGeneratedInstance: false,
        ));
      }
    }

    return manualUpcoming;
  }

  /// Get recurring template upcoming expenses
  Future<List<UpcomingExpenseItem>> _getRecurringTemplateUpcoming(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    final templates = await _recurringService.getRecurringTemplates();
    final templateUpcoming = <UpcomingExpenseItem>[];

    for (final template in templates) {
      final nextDate = template.nextBillingDate;
      if (nextDate != null && 
          nextDate.isAfter(fromDate) && 
          nextDate.isBefore(toDate)) {
        templateUpcoming.add(UpcomingExpenseItem(
          expense: template,
          isRecurringTemplate: true,
          nextOccurrenceDate: nextDate,
          recurringTemplateId: template.id,
        ));
      }
    }

    return templateUpcoming;
  }

  /// Get generated instance upcoming expenses
  Future<List<UpcomingExpenseItem>> _getGeneratedInstanceUpcoming(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    final allExpenses = await _expenseRepo.getAllExpenses();
    final generatedUpcoming = <UpcomingExpenseItem>[];

    for (final expense in allExpenses) {
      // Look for generated instances (non-recurring expenses that were created by recurring service)
      // We can identify these by checking if they have a recurring template ID or other indicators
      if (!expense.isRecurring && 
          expense.date.isAfter(fromDate) && 
          expense.date.isBefore(toDate) &&
          _isGeneratedInstance(expense)) {
        generatedUpcoming.add(UpcomingExpenseItem(
          expense: expense,
          isRecurringTemplate: false,
          isGeneratedInstance: true,
        ));
      }
    }

    return generatedUpcoming;
  }

  /// Determine if an expense is a generated instance from a recurring template
  bool _isGeneratedInstance(Expense expense) {
    // This is a heuristic - in a real implementation, you might have a field
    // to track the source template, or use other indicators
    return expense.title.contains('(Generated)') || 
           expense.notes?.contains('Generated from recurring') == true;
  }
}

/// Summary of upcoming expenses with breakdowns
class UpcomingExpensesSummary {
  final double totalAmount;
  final double recurringAmount;
  final double manualAmount;
  final int totalCount;
  final int recurringCount;
  final int manualCount;
  final DateTime fromDate;
  final DateTime toDate;

  UpcomingExpensesSummary({
    required this.totalAmount,
    required this.recurringAmount,
    required this.manualAmount,
    required this.totalCount,
    required this.recurringCount,
    required this.manualCount,
    required this.fromDate,
    required this.toDate,
  });

  /// Get the percentage of recurring expenses
  double get recurringPercentage => totalAmount > 0 ? (recurringAmount / totalAmount) * 100 : 0;

  /// Get the percentage of manual expenses
  double get manualPercentage => totalAmount > 0 ? (manualAmount / totalAmount) * 100 : 0;

  /// Check if there are any upcoming expenses
  bool get hasUpcomingExpenses => totalCount > 0;

  /// Check if there are any recurring upcoming expenses
  bool get hasRecurringUpcoming => recurringCount > 0;

  /// Check if there are any manual upcoming expenses
  bool get hasManualUpcoming => manualCount > 0;
} 