import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../providers/expense_state_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

/// Enum representing the status of a recurring expense
enum RecurringExpenseStatus {
  active, // Normal active recurring expense
  dueSoon, // Due within the next 3 days
  overdue, // Past the billing date
}

/// Model for enhanced recurring expense data
class RecurringExpenseData {
  final Expense expense;
  final RecurringExpenseStatus status;
  final DateTime? nextBillingDate;
  final String formattedNextBillingDate;
  final String billingCycle;
  final double monthlyEquivalentCost;
  final bool isRecurring;

  RecurringExpenseData({
    required this.expense,
    required this.status,
    required this.nextBillingDate,
    required this.formattedNextBillingDate,
    required this.billingCycle,
    required this.monthlyEquivalentCost,
    required this.isRecurring,
  });
}

/// Summary of recurring expense costs and statistics
class RecurringExpenseSummary {
  final double totalMonthlyAmount;
  final double monthlyBillingAmount;
  final double yearlyBillingMonthlyEquivalent;
  final int totalSubscriptions;
  final int activeSubscriptions;
  final int dueSoonSubscriptions;
  final int overdueSubscriptions;

  RecurringExpenseSummary({
    required this.totalMonthlyAmount,
    required this.monthlyBillingAmount,
    required this.yearlyBillingMonthlyEquivalent,
    required this.totalSubscriptions,
    required this.activeSubscriptions,
    required this.dueSoonSubscriptions,
    required this.overdueSubscriptions,
  });
}

/// Service for managing and automating recurring expenses.
///
/// Handles processing of all recurring expenses (isRecurring == true).
/// Any expense can be recurring with a frequency setting.
///
/// Uses frequency enum for scheduling recurring expenses.
/// Also provides recurring expense analytics, status tracking, and data enhancement.
class RecurringExpenseService {
  final ExpenseRepository _expenseRepo;
  final ExpenseStateManager? _expenseStateManager;
  final _uuid = Uuid();
  final _dateFormat = DateFormat.yMMMd();

  RecurringExpenseService(this._expenseRepo, [this._expenseStateManager]);

  /// Process all recurring expenses to create new expense entries for due/overdue items
  /// Processes all overdue cycles for each template until caught up
  Future<int> processRecurringExpenses() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int processedCount = 0;

    // Get all active recurring expense templates
    final expenses = await _expenseRepo.getAllExpenses();
    final recurringExpenses = expenses
        .where((expense) =>
            expense.isRecurring == true &&
            (expense.endDate == null || expense.endDate!.isAfter(today)))
        .toList();

    // Collect all changes for batch processing
    final expensesToAdd = <Expense>[];
    final expensesToUpdate = <Expense>[];

    for (final template in recurringExpenses) {
      // Keep processing until all overdue cycles are caught up
      // Safety limit: max 100 iterations per template to prevent infinite loops
      int iterations = 0;
      const maxIterations = 100;

      var currentTemplate = template;
      var nextDate = currentTemplate.nextBillingDate;

      // Process all overdue cycles for this template
      while (nextDate != null &&
          iterations < maxIterations &&
          (nextDate.isBefore(today) ||
              nextDate.isAtSameMomentAs(
                  DateTime(today.year, today.month, today.day)))) {
        // Check if template has expired
        if (currentTemplate.endDate != null &&
            currentTemplate.endDate!.isBefore(nextDate)) {
          // Template expired before this date, stop processing
          break;
        }

        // Create a new expense entry based on the template
        final newExpense = currentTemplate.copyWith(
          id: _uuid.v4(),
          date: nextDate,
          createdAt: now,
          isRecurring: false, // This is a generated instance
          nextBillingDate: null, // Clear this for the instance
          // Keep the original type for the generated instance
        );

        // Calculate the next billing date
        final calculatedNextDate = _calculateNextDate(currentTemplate);

        // Update the template with the next date
        currentTemplate = currentTemplate.copyWith(
          nextBillingDate: calculatedNextDate,
        );

        // Collect for batch processing
        expensesToAdd.add(newExpense);
        expensesToUpdate.add(currentTemplate);

        // Update for next iteration
        nextDate = calculatedNextDate;
        processedCount++;
        iterations++;
      }

      // Safety check: if we hit max iterations, log a warning
      if (iterations >= maxIterations) {
        debugPrint(
            'Warning: Reached max iterations for template ${template.id}. '
            'There may be more overdue cycles to process.');
      }
    }

    // Process all changes in a single batch
    if (expensesToAdd.isNotEmpty || expensesToUpdate.isNotEmpty) {
      if (_expenseStateManager != null) {
        await _expenseStateManager!.processBatchExpenses(
          expensesToAdd: expensesToAdd,
          expensesToUpdate: expensesToUpdate,
        );
      } else {
        // Fallback to direct repository calls if ExpenseStateManager not provided
        for (final expense in expensesToAdd) {
          await _expenseRepo.addExpense(expense);
        }
        for (final expense in expensesToUpdate) {
          await _expenseRepo.updateExpense(expense);
        }
      }
    }

    return processedCount;
  }

  /// Calculate the next occurrence date based on frequency.
  DateTime _calculateNextDate(Expense template) {
    final lastDate = template.nextBillingDate ?? template.date;

    // Use frequency to calculate next date
    switch (template.frequency) {
      case ExpenseFrequency.daily:
        return DateTime(lastDate.year, lastDate.month, lastDate.day + 1);

      case ExpenseFrequency.weekly:
        return DateTime(lastDate.year, lastDate.month, lastDate.day + 7);

      case ExpenseFrequency.biWeekly:
        return DateTime(lastDate.year, lastDate.month, lastDate.day + 14);

      case ExpenseFrequency.monthly:
        return DateTime(lastDate.year, lastDate.month + 1, lastDate.day);

      case ExpenseFrequency.quarterly:
        return DateTime(lastDate.year, lastDate.month + 3, lastDate.day);

      case ExpenseFrequency.yearly:
        return DateTime(lastDate.year + 1, lastDate.month, lastDate.day);

      case ExpenseFrequency.oneTime:
      case ExpenseFrequency.custom:
        // For unsupported frequencies, return the last date
        return lastDate;
    }
  }

  /// Get all recurring expense templates
  Future<List<Expense>> getRecurringTemplates() async {
    final expenses = await _expenseRepo.getAllExpenses();
    return expenses.where((expense) => expense.isRecurring == true).toList();
  }

  /// Get upcoming recurring expenses (templates that will generate expenses soon)
  Future<List<Expense>> getUpcomingRecurringExpenses(
      {int daysAhead = 30}) async {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: daysAhead));

    final templates = await getRecurringTemplates();
    final upcoming = <Expense>[];

    for (final template in templates) {
      final nextDate = template.nextBillingDate;
      if (nextDate != null &&
          nextDate.isAfter(now) &&
          nextDate.isBefore(futureDate)) {
        upcoming.add(template);
      }
    }

    // Sort by next billing date
    upcoming.sort((a, b) {
      final aDate = a.nextBillingDate ?? DateTime(9999, 12, 31);
      final bDate = b.nextBillingDate ?? DateTime(9999, 12, 31);
      return aDate.compareTo(bDate);
    });

    return upcoming;
  }

  /// Get overdue recurring expenses (templates that should have generated expenses)
  Future<List<Expense>> getOverdueRecurringExpenses() async {
    final now = DateTime.now();
    final templates = await getRecurringTemplates();

    return templates.where((template) {
      final nextDate = template.nextBillingDate;
      return nextDate != null && nextDate.isBefore(now);
    }).toList();
  }

  /// Calculate total monthly cost for recurring expenses
  Future<double> getMonthlyRecurringCost() async {
    final templates = await getRecurringTemplates();
    double total = 0.0;

    for (final template in templates) {
      switch (template.frequency) {
        case ExpenseFrequency.daily:
          total += template.amount * 30; // Approximate monthly
          break;
        case ExpenseFrequency.weekly:
          total += template.amount * 4.33; // Average weeks per month
          break;
        case ExpenseFrequency.biWeekly:
          total += template.amount * 2.17; // Average bi-weeks per month
          break;
        case ExpenseFrequency.monthly:
          total += template.amount;
          break;
        case ExpenseFrequency.quarterly:
          total += template.amount / 3;
          break;
        case ExpenseFrequency.yearly:
          total += template.amount / 12;
          break;
        case ExpenseFrequency.oneTime:
        case ExpenseFrequency.custom:
          // Don't include in monthly calculation
          break;
      }
    }

    return total;
  }

  /// Create a recurring expense template
  /// This is a helper method to demonstrate how to create recurring expenses
  Future<Expense> createRecurringTemplate({
    required String title,
    required double amount,
    required ExpenseFrequency frequency,
    required String categoryId,
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final now = DateTime.now();
    final start = startDate ?? now;

    // Calculate the first next billing date (only monthly/yearly supported)
    DateTime? nextBillingDate;
    switch (frequency) {
      case ExpenseFrequency.monthly:
        nextBillingDate = DateTime(start.year, start.month + 1, start.day);
        break;
      case ExpenseFrequency.yearly:
        nextBillingDate = DateTime(start.year + 1, start.month, start.day);
        break;
      default:
        nextBillingDate = null;
    }

    final template = Expense(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      date: start,
      createdAt: now,
      categoryId: categoryId,
      accountId: accountId,
      isRecurring: true,
      frequency: frequency,
      nextBillingDate: nextBillingDate,
      endDate: endDate,
      necessity: ExpenseNecessity.discretionary, // Default, can be updated
      status: ExpenseStatus.paid,
    );

    if (_expenseStateManager != null) {
      await _expenseStateManager!.addExpense(template);
    } else {
      await _expenseRepo.addExpense(template);
    }
    return template;
  }

  // ============================================================================
  // Recurring Expense Analytics Methods
  // ============================================================================

  /// Retrieves all recurring expense templates and enhances them with status information
  /// Only returns templates (isRecurring == true), not generated instances
  Future<List<RecurringExpenseData>> getRecurringExpenses() async {
    final expenses = await _expenseRepo.getAllExpenses();
    return getRecurringExpensesFromExpenses(expenses);
  }

  /// Get recurring expenses from provided expenses list
  /// Only returns templates (isRecurring == true), not generated instances
  List<RecurringExpenseData> getRecurringExpensesFromExpenses(
      List<Expense> expenses) {
    final recurringExpenses =
        expenses.where((expense) => expense.isRecurring == true).toList();

    return _enhanceRecurringExpenses(recurringExpenses);
  }

  /// Retrieves recurring expense templates for a specific month
  /// Returns templates that have a nextBillingDate in the specified month
  /// Only returns templates (isRecurring == true), not generated instances
  Future<List<RecurringExpenseData>> getRecurringExpensesForMonth(
      DateTime month) async {
    final expenses = await _expenseRepo.getAllExpenses();
    return getRecurringExpensesForMonthFromExpenses(expenses, month);
  }

  /// Get recurring expenses for a specific month from provided expenses list
  List<RecurringExpenseData> getRecurringExpensesForMonthFromExpenses(
      List<Expense> expenses, DateTime month) {
    final recurringExpenses = expenses
        .where((expense) =>
            expense.isRecurring == true &&
            expense.nextBillingDate != null &&
            expense.nextBillingDate!.year == month.year &&
            expense.nextBillingDate!.month == month.month)
        .toList();

    return _enhanceRecurringExpenses(recurringExpenses);
  }

  /// Calculates a summary of recurring expense costs for a specific month
  /// Note: Returns summary for all active recurring expense templates, not just those due in the month
  Future<RecurringExpenseSummary> getRecurringExpenseSummaryForMonth(
      DateTime month) async {
    final expenses = await _expenseRepo.getAllExpenses();
    return getRecurringExpenseSummaryForMonthFromExpenses(expenses, month);
  }

  /// Calculate recurring expense summary from provided expenses list
  RecurringExpenseSummary getRecurringExpenseSummaryForMonthFromExpenses(
      List<Expense> expenses, DateTime month) {
    // Use all recurring expense templates for the summary, not just those due in the month
    final recurringExpenses = getRecurringExpensesFromExpenses(expenses);

    final monthlyRecurringExpenses = recurringExpenses
        .where((re) => re.expense.frequency == ExpenseFrequency.monthly)
        .toList();

    final yearlyRecurringExpenses = recurringExpenses
        .where((re) => re.expense.frequency == ExpenseFrequency.yearly)
        .toList();

    final monthlyBillingAmount = monthlyRecurringExpenses.fold(
        0.0, (sum, re) => sum + re.expense.amount);

    final yearlyBillingAmount =
        yearlyRecurringExpenses.fold(0.0, (sum, re) => sum + re.expense.amount);

    final yearlyBillingMonthlyEquivalent = yearlyBillingAmount / 12;

    final totalMonthlyAmount =
        monthlyBillingAmount + yearlyBillingMonthlyEquivalent;

    final activeCount = recurringExpenses
        .where((re) => re.status == RecurringExpenseStatus.active)
        .length;
    final dueSoonCount = recurringExpenses
        .where((re) => re.status == RecurringExpenseStatus.dueSoon)
        .length;
    final overdueCount = recurringExpenses
        .where((re) => re.status == RecurringExpenseStatus.overdue)
        .length;

    return RecurringExpenseSummary(
      totalMonthlyAmount: totalMonthlyAmount,
      monthlyBillingAmount: monthlyBillingAmount,
      yearlyBillingMonthlyEquivalent: yearlyBillingMonthlyEquivalent,
      totalSubscriptions: recurringExpenses.length,
      activeSubscriptions: activeCount,
      dueSoonSubscriptions: dueSoonCount,
      overdueSubscriptions: overdueCount,
    );
  }

  /// Retrieves recurring expenses filtered by status
  Future<List<RecurringExpenseData>> getRecurringExpensesByStatus(
      RecurringExpenseStatus status) async {
    final expenses = await _expenseRepo.getAllExpenses();
    return getRecurringExpensesByStatusFromExpenses(expenses, status);
  }

  /// Get recurring expenses filtered by status from provided expenses list
  List<RecurringExpenseData> getRecurringExpensesByStatusFromExpenses(
      List<Expense> expenses, RecurringExpenseStatus status) {
    final allRecurringExpenses = getRecurringExpensesFromExpenses(expenses);
    return allRecurringExpenses.where((re) => re.status == status).toList();
  }

  /// Calculates a summary of recurring expense costs and statistics
  Future<RecurringExpenseSummary> getRecurringExpenseSummary() async {
    final expenses = await _expenseRepo.getAllExpenses();
    return getRecurringExpenseSummaryFromExpenses(expenses);
  }

  /// Calculate recurring expense summary from provided expenses list
  RecurringExpenseSummary getRecurringExpenseSummaryFromExpenses(
      List<Expense> expenses) {
    final recurringExpenses = getRecurringExpensesFromExpenses(expenses);

    // Calculate monthly costs based on frequency
    final monthlyRecurringExpenses = recurringExpenses
        .where((re) => re.expense.frequency == ExpenseFrequency.monthly)
        .toList();

    final yearlyRecurringExpenses = recurringExpenses
        .where((re) => re.expense.frequency == ExpenseFrequency.yearly)
        .toList();

    final monthlyBillingAmount = monthlyRecurringExpenses.fold(
        0.0, (sum, re) => sum + re.expense.amount);

    final yearlyBillingAmount =
        yearlyRecurringExpenses.fold(0.0, (sum, re) => sum + re.expense.amount);

    final yearlyBillingMonthlyEquivalent = yearlyBillingAmount / 12;
    final totalMonthlyAmount =
        monthlyBillingAmount + yearlyBillingMonthlyEquivalent;

    // Count recurring expenses by status
    final activeCount = recurringExpenses
        .where((re) => re.status == RecurringExpenseStatus.active)
        .length;
    final dueSoonCount = recurringExpenses
        .where((re) => re.status == RecurringExpenseStatus.dueSoon)
        .length;
    final overdueCount = recurringExpenses
        .where((re) => re.status == RecurringExpenseStatus.overdue)
        .length;

    return RecurringExpenseSummary(
      totalMonthlyAmount: totalMonthlyAmount,
      monthlyBillingAmount: monthlyBillingAmount,
      yearlyBillingMonthlyEquivalent: yearlyBillingMonthlyEquivalent,
      totalSubscriptions: recurringExpenses.length,
      activeSubscriptions: activeCount,
      dueSoonSubscriptions: dueSoonCount,
      overdueSubscriptions: overdueCount,
    );
  }

  /// Determines the status of a recurring expense based on its next billing date
  RecurringExpenseStatus getRecurringExpenseStatus(DateTime? nextBillingDate) {
    if (nextBillingDate == null) {
      return RecurringExpenseStatus.active;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final billingDate = DateTime(
      nextBillingDate.year,
      nextBillingDate.month,
      nextBillingDate.day,
    );

    if (billingDate.isBefore(today)) {
      return RecurringExpenseStatus.overdue;
    }

    final threeDaysFromNow = today.add(const Duration(days: 3));
    if (!billingDate.isAfter(threeDaysFromNow)) {
      return RecurringExpenseStatus.dueSoon;
    }

    return RecurringExpenseStatus.active;
  }

  /// Formats a date for display, with special handling for today and tomorrow
  String formatRecurringExpenseDate(DateTime? date) {
    if (date == null) return 'Unknown';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateToFormat = DateTime(date.year, date.month, date.day);

    if (dateToFormat == today) {
      return 'Today';
    } else if (dateToFormat == tomorrow) {
      return 'Tomorrow';
    } else {
      return _dateFormat.format(date);
    }
  }

  /// Enhances a list of recurring expense templates with additional data and status
  List<RecurringExpenseData> _enhanceRecurringExpenses(
      List<Expense> recurringExpenses) {
    return recurringExpenses.map((recurringExpense) {
      final nextBillingDate = recurringExpense.nextBillingDate;
      final status = getRecurringExpenseStatus(nextBillingDate);

      // Determine billing cycle from frequency
      String billingCycle;
      if (recurringExpense.frequency == ExpenseFrequency.monthly) {
        billingCycle = 'Monthly';
      } else if (recurringExpense.frequency == ExpenseFrequency.yearly) {
        billingCycle = 'Yearly';
      } else {
        // Default to Monthly for other frequencies
        billingCycle = 'Monthly';
      }

      // Calculate monthly equivalent cost
      double monthlyEquivalentCost = recurringExpense.amount;
      if (recurringExpense.frequency == ExpenseFrequency.yearly) {
        monthlyEquivalentCost = recurringExpense.amount / 12;
      }

      return RecurringExpenseData(
        expense: recurringExpense,
        status: status,
        nextBillingDate: nextBillingDate,
        formattedNextBillingDate: formatRecurringExpenseDate(nextBillingDate),
        billingCycle: billingCycle,
        monthlyEquivalentCost: monthlyEquivalentCost,
        isRecurring: recurringExpense.isRecurring,
      );
    }).toList()
      ..sort((a, b) {
        // Sort by status first (overdue, then due soon, then active)
        if (a.status != b.status) {
          return a.status.index.compareTo(b.status.index);
        }

        // Then sort by next billing date
        if (a.nextBillingDate != null && b.nextBillingDate != null) {
          return a.nextBillingDate!.compareTo(b.nextBillingDate!);
        } else if (a.nextBillingDate != null) {
          return -1;
        } else if (b.nextBillingDate != null) {
          return 1;
        }

        // Finally sort by title
        return a.expense.title.compareTo(b.expense.title);
      });
  }
}
