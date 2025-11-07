import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import 'package:uuid/uuid.dart';

/// Service for managing and automating recurring expenses of all types.
/// 
/// Handles processing of all recurring expenses including:
/// - Subscriptions (ExpenseType.subscription)
/// - Fixed expenses (ExpenseType.fixed)
/// - Variable expenses (ExpenseType.variable)
/// 
/// Uses frequency enum for scheduling recurring expenses.
class RecurringExpenseService {
  final ExpenseRepository _expenseRepo;
  final _uuid = Uuid();

  RecurringExpenseService(this._expenseRepo);

  /// Process all recurring expenses to create new expense entries for due/overdue items
  Future<int> processRecurringExpenses() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int processedCount = 0;
    
    // Get all active recurring expense templates
    final expenses = await _expenseRepo.getAllExpenses();
    final recurringExpenses = expenses.where((expense) => 
      expense.isRecurring == true &&
      (expense.endDate == null || expense.endDate!.isAfter(today))
    ).toList();
    
    for (final template in recurringExpenses) {
      final nextDate = template.nextBillingDate;
      
      // If next date is null, in the past, or today - process it
      if (nextDate != null && 
          (nextDate.isBefore(today) || 
           nextDate.isAtSameMomentAs(DateTime(today.year, today.month, today.day)))) {
        
        // Create a new expense entry based on the template
        final newExpense = template.copyWith(
          id: _uuid.v4(),
          date: nextDate,
          createdAt: now,
          isRecurring: false, // This is a generated instance
          nextBillingDate: null, // Clear this for the instance
          // Keep the original type for the generated instance
        );
        
        await _expenseRepo.addExpense(newExpense);
        
        // Update the template with the next date
        final updatedTemplate = template.copyWith(
          nextBillingDate: _calculateNextDate(template),
        );
        
        await _expenseRepo.updateExpense(updatedTemplate);
        processedCount++;
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
        return lastDate.add(const Duration(days: 1));
        
      case ExpenseFrequency.weekly:
        return lastDate.add(const Duration(days: 7));
        
      case ExpenseFrequency.biWeekly:
        return lastDate.add(const Duration(days: 14));
        
      case ExpenseFrequency.monthly:
        return DateTime(
          lastDate.year,
          lastDate.month + 1,
          lastDate.day,
        );
        
      case ExpenseFrequency.quarterly:
        return DateTime(
          lastDate.year,
          lastDate.month + 3,
          lastDate.day,
        );
        
      case ExpenseFrequency.yearly:
        return DateTime(
          lastDate.year + 1,
          lastDate.month,
          lastDate.day,
        );
        
      case ExpenseFrequency.oneTime:
      case ExpenseFrequency.custom:
        return lastDate;
    }
  }

  /// Get all recurring expense templates
  Future<List<Expense>> getRecurringTemplates() async {
    final expenses = await _expenseRepo.getAllExpenses();
    return expenses.where((expense) => expense.isRecurring == true).toList();
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

  /// Example: Create a recurring expense template
  /// This is a helper method to demonstrate how to create recurring expenses
  Future<Expense> createRecurringTemplate({
    required String title,
    required double amount,
    required ExpenseType type,
    required ExpenseFrequency frequency,
    required String categoryId,
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final now = DateTime.now();
    final start = startDate ?? now;
    
    // Calculate the first next billing date
    DateTime? nextBillingDate;
    switch (frequency) {
      case ExpenseFrequency.daily:
        nextBillingDate = start.add(const Duration(days: 1));
        break;
      case ExpenseFrequency.weekly:
        nextBillingDate = start.add(const Duration(days: 7));
        break;
      case ExpenseFrequency.biWeekly:
        nextBillingDate = start.add(const Duration(days: 14));
        break;
      case ExpenseFrequency.monthly:
        nextBillingDate = DateTime(start.year, start.month + 1, start.day);
        break;
      case ExpenseFrequency.quarterly:
        nextBillingDate = DateTime(start.year, start.month + 3, start.day);
        break;
      case ExpenseFrequency.yearly:
        nextBillingDate = DateTime(start.year + 1, start.month, start.day);
        break;
      case ExpenseFrequency.oneTime:
      case ExpenseFrequency.custom:
        nextBillingDate = null;
    }
    
    final template = Expense(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      date: start,
      createdAt: now,
      categoryId: categoryId,
      type: type,
      accountId: accountId,
      isRecurring: true,
      frequency: frequency,
      nextBillingDate: nextBillingDate,
      endDate: endDate,
      necessity: ExpenseNecessity.discretionary, // Default, can be updated
      status: ExpenseStatus.paid,
    );
    
    await _expenseRepo.addExpense(template);
    return template;
  }
} 