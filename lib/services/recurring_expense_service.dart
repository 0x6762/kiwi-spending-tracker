import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../providers/expense_state_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

/// Enum representing the status of a subscription
enum SubscriptionStatus {
  active,    // Normal active subscription
  dueSoon,   // Due within the next 3 days
  overdue,   // Past the billing date
}

/// Model for enhanced subscription data
class SubscriptionData {
  final Expense expense;
  final SubscriptionStatus status;
  final DateTime? nextBillingDate;
  final String formattedNextBillingDate;
  final String billingCycle;
  final double monthlyEquivalentCost;
  final bool isRecurring;

  SubscriptionData({
    required this.expense,
    required this.status,
    required this.nextBillingDate,
    required this.formattedNextBillingDate,
    required this.billingCycle,
    required this.monthlyEquivalentCost,
    required this.isRecurring,
  });
}

/// Summary of subscription costs and statistics
class SubscriptionSummary {
  final double totalMonthlyAmount;
  final double monthlyBillingAmount;
  final double yearlyBillingMonthlyEquivalent;
  final int totalSubscriptions;
  final int activeSubscriptions;
  final int dueSoonSubscriptions;
  final int overdueSubscriptions;

  SubscriptionSummary({
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
/// Handles processing of subscription expenses only (ExpenseType.subscription).
/// Subscriptions are the only expense type that can be auto-recurring with frequency.
/// 
/// Fixed and variable expenses are manually entered and do not use auto-recurring.
/// Uses frequency enum (monthly/yearly) for scheduling subscription expenses.
/// 
/// Also provides subscription analytics, status tracking, and data enhancement.
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
    
    // Get all active recurring expense templates (subscriptions only)
    final expenses = await _expenseRepo.getAllExpenses();
    final recurringExpenses = expenses.where((expense) => 
      expense.type == ExpenseType.subscription &&
      expense.isRecurring == true &&
      (expense.endDate == null || expense.endDate!.isAfter(today))
    ).toList();
    
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
              nextDate.isAtSameMomentAs(DateTime(today.year, today.month, today.day)))) {
        
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
        debugPrint('Warning: Reached max iterations for template ${template.id}. '
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
  /// Only supports monthly and yearly frequencies (subscriptions only)
  DateTime _calculateNextDate(Expense template) {
    final lastDate = template.nextBillingDate ?? template.date;
    
    // Use frequency to calculate next date (subscriptions only support monthly/yearly)
    switch (template.frequency) {
      case ExpenseFrequency.monthly:
        return DateTime(
          lastDate.year,
          lastDate.month + 1,
          lastDate.day,
        );
        
      case ExpenseFrequency.yearly:
        return DateTime(
          lastDate.year + 1,
          lastDate.month,
          lastDate.day,
        );
        
      default:
        // For unsupported frequencies, return the last date
        return lastDate;
    }
  }

  /// Get all recurring expense templates (subscriptions only)
  Future<List<Expense>> getRecurringTemplates() async {
    final expenses = await _expenseRepo.getAllExpenses();
    return expenses.where((expense) => 
      expense.type == ExpenseType.subscription &&
      expense.isRecurring == true
    ).toList();
  }

  /// Get recurring templates by type
  Future<List<Expense>> getRecurringTemplatesByType(ExpenseType type) async {
    final templates = await getRecurringTemplates();
    return templates.where((expense) => expense.type == type).toList();
  }

  /// Get upcoming recurring expenses (templates that will generate expenses soon)
  Future<List<Expense>> getUpcomingRecurringExpenses({int daysAhead = 30}) async {
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

  /// Example: Create a recurring subscription template
  /// This is a helper method to demonstrate how to create recurring subscriptions
  /// Only supports subscription type with monthly or yearly frequency
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
      type: ExpenseType.subscription, // Only subscriptions can be recurring
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
  // Subscription Analytics Methods (merged from SubscriptionService)
  // ============================================================================

  /// Retrieves all subscription templates and enhances them with status information
  /// Only returns templates (isRecurring == true), not generated instances
  Future<List<SubscriptionData>> getSubscriptions() async {
    final expenses = await _expenseRepo.getAllExpenses();
    return getSubscriptionsFromExpenses(expenses);
  }

  /// Get subscriptions from provided expenses list
  /// Only returns templates (isRecurring == true), not generated instances
  List<SubscriptionData> getSubscriptionsFromExpenses(List<Expense> expenses) {
    final subscriptions = expenses
        .where((expense) => 
            expense.type == ExpenseType.subscription &&
            expense.isRecurring == true)
        .toList();
    
    return _enhanceSubscriptions(subscriptions);
  }

  /// Retrieves subscription templates for a specific month
  /// Returns templates that have a nextBillingDate in the specified month
  /// Only returns templates (isRecurring == true), not generated instances
  Future<List<SubscriptionData>> getSubscriptionsForMonth(DateTime month) async {
    final expenses = await _expenseRepo.getAllExpenses();
    return getSubscriptionsForMonthFromExpenses(expenses, month);
  }

  /// Get subscriptions for a specific month from provided expenses list
  List<SubscriptionData> getSubscriptionsForMonthFromExpenses(
      List<Expense> expenses, DateTime month) {
    final subscriptions = expenses
        .where((expense) => 
            expense.type == ExpenseType.subscription &&
            expense.isRecurring == true &&
            expense.nextBillingDate != null &&
            expense.nextBillingDate!.year == month.year &&
            expense.nextBillingDate!.month == month.month)
        .toList();
    
    return _enhanceSubscriptions(subscriptions);
  }

  /// Calculates a summary of subscription costs for a specific month
  /// Note: Returns summary for all active subscription templates, not just those due in the month
  Future<SubscriptionSummary> getSubscriptionSummaryForMonth(DateTime month) async {
    final expenses = await _expenseRepo.getAllExpenses();
    return getSubscriptionSummaryForMonthFromExpenses(expenses, month);
  }

  /// Calculate subscription summary from provided expenses list
  SubscriptionSummary getSubscriptionSummaryForMonthFromExpenses(
      List<Expense> expenses, DateTime month) {
    // Use all subscription templates for the summary, not just those due in the month
    final subscriptions = getSubscriptionsFromExpenses(expenses);
    
    final monthlySubscriptions = subscriptions
        .where((sub) => sub.expense.frequency == ExpenseFrequency.monthly)
        .toList();
    
    final yearlySubscriptions = subscriptions
        .where((sub) => sub.expense.frequency == ExpenseFrequency.yearly)
        .toList();
    
    final monthlyBillingAmount = monthlySubscriptions.fold(
        0.0, (sum, sub) => sum + sub.expense.amount);
    
    final yearlyBillingAmount = yearlySubscriptions.fold(
        0.0, (sum, sub) => sum + sub.expense.amount);
    
    final yearlyBillingMonthlyEquivalent = yearlyBillingAmount / 12;
    
    final totalMonthlyAmount = monthlyBillingAmount + yearlyBillingMonthlyEquivalent;
    
    final activeCount = subscriptions.where((sub) => sub.status == SubscriptionStatus.active).length;
    final dueSoonCount = subscriptions.where((sub) => sub.status == SubscriptionStatus.dueSoon).length;
    final overdueCount = subscriptions.where((sub) => sub.status == SubscriptionStatus.overdue).length;
    
    return SubscriptionSummary(
      totalMonthlyAmount: totalMonthlyAmount,
      monthlyBillingAmount: monthlyBillingAmount,
      yearlyBillingMonthlyEquivalent: yearlyBillingMonthlyEquivalent,
      totalSubscriptions: subscriptions.length,
      activeSubscriptions: activeCount,
      dueSoonSubscriptions: dueSoonCount,
      overdueSubscriptions: overdueCount,
    );
  }

  /// Retrieves subscriptions filtered by status
  Future<List<SubscriptionData>> getSubscriptionsByStatus(SubscriptionStatus status) async {
    final expenses = await _expenseRepo.getAllExpenses();
    return getSubscriptionsByStatusFromExpenses(expenses, status);
  }

  /// Get subscriptions filtered by status from provided expenses list
  List<SubscriptionData> getSubscriptionsByStatusFromExpenses(
      List<Expense> expenses, SubscriptionStatus status) {
    final allSubscriptions = getSubscriptionsFromExpenses(expenses);
    return allSubscriptions.where((sub) => sub.status == status).toList();
  }

  /// Calculates a summary of subscription costs and statistics
  Future<SubscriptionSummary> getSubscriptionSummary() async {
    final expenses = await _expenseRepo.getAllExpenses();
    return getSubscriptionSummaryFromExpenses(expenses);
  }

  /// Calculate subscription summary from provided expenses list
  SubscriptionSummary getSubscriptionSummaryFromExpenses(List<Expense> expenses) {
    final subscriptions = getSubscriptionsFromExpenses(expenses);
    
    // Calculate monthly costs based on frequency
    final monthlySubscriptions = subscriptions
        .where((sub) => sub.expense.frequency == ExpenseFrequency.monthly)
        .toList();
    
    final yearlySubscriptions = subscriptions
        .where((sub) => sub.expense.frequency == ExpenseFrequency.yearly)
        .toList();
    
    final monthlyBillingAmount = monthlySubscriptions.fold(
        0.0, (sum, sub) => sum + sub.expense.amount);
    
    final yearlyBillingAmount = yearlySubscriptions.fold(
        0.0, (sum, sub) => sum + sub.expense.amount);
    
    final yearlyBillingMonthlyEquivalent = yearlyBillingAmount / 12;
    final totalMonthlyAmount = monthlyBillingAmount + yearlyBillingMonthlyEquivalent;
    
    // Count subscriptions by status
    final activeCount = subscriptions.where((sub) => sub.status == SubscriptionStatus.active).length;
    final dueSoonCount = subscriptions.where((sub) => sub.status == SubscriptionStatus.dueSoon).length;
    final overdueCount = subscriptions.where((sub) => sub.status == SubscriptionStatus.overdue).length;
    
    return SubscriptionSummary(
      totalMonthlyAmount: totalMonthlyAmount,
      monthlyBillingAmount: monthlyBillingAmount,
      yearlyBillingMonthlyEquivalent: yearlyBillingMonthlyEquivalent,
      totalSubscriptions: subscriptions.length,
      activeSubscriptions: activeCount,
      dueSoonSubscriptions: dueSoonCount,
      overdueSubscriptions: overdueCount,
    );
  }

  /// Determines the status of a subscription based on its next billing date
  SubscriptionStatus getSubscriptionStatus(DateTime? nextBillingDate) {
    if (nextBillingDate == null) {
      return SubscriptionStatus.active;
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final billingDate = DateTime(
      nextBillingDate.year,
      nextBillingDate.month,
      nextBillingDate.day,
    );
    
    if (billingDate.isBefore(today)) {
      return SubscriptionStatus.overdue;
    }
    
    final threeDaysFromNow = today.add(const Duration(days: 3));
    if (!billingDate.isAfter(threeDaysFromNow)) {
      return SubscriptionStatus.dueSoon;
    }
    
    return SubscriptionStatus.active;
  }

  /// Formats a date for display, with special handling for today and tomorrow
  String formatSubscriptionDate(DateTime? date) {
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

  /// Enhances a list of subscription expenses with additional data and status
  List<SubscriptionData> _enhanceSubscriptions(List<Expense> subscriptions) {
    return subscriptions.map((subscription) {
      final nextBillingDate = subscription.nextBillingDate;
      final status = getSubscriptionStatus(nextBillingDate);
      
      // Determine billing cycle from frequency
      String billingCycle;
      if (subscription.frequency == ExpenseFrequency.monthly) {
        billingCycle = 'Monthly';
      } else if (subscription.frequency == ExpenseFrequency.yearly) {
        billingCycle = 'Yearly';
      } else {
        // Default to Monthly for other frequencies
        billingCycle = 'Monthly';
      }
      
      // Calculate monthly equivalent cost
      double monthlyEquivalentCost = subscription.amount;
      if (subscription.frequency == ExpenseFrequency.yearly) {
        monthlyEquivalentCost = subscription.amount / 12;
      }
      
      return SubscriptionData(
        expense: subscription,
        status: status,
        nextBillingDate: nextBillingDate,
        formattedNextBillingDate: formatSubscriptionDate(nextBillingDate),
        billingCycle: billingCycle,
        monthlyEquivalentCost: monthlyEquivalentCost,
        isRecurring: subscription.isRecurring,
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