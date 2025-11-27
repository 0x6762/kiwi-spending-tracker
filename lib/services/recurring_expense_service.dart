import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../providers/expense_state_manager.dart';
import 'package:uuid/uuid.dart';

/// Service for managing and automating recurring expenses.
/// 
/// Handles processing of subscription expenses only (ExpenseType.subscription).
/// Subscriptions are the only expense type that can be auto-recurring with frequency.
/// 
/// Fixed and variable expenses are manually entered and do not use auto-recurring.
/// Uses frequency enum (monthly/yearly) for scheduling subscription expenses.
class RecurringExpenseService {
  final ExpenseRepository _expenseRepo;
  final ExpenseStateManager? _expenseStateManager;
  final _uuid = Uuid();

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
} 