import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';
import '../utils/formatters.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

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

/// Service for managing and analyzing subscription expenses
class SubscriptionService {
  final ExpenseRepository _expenseRepo;
  final CategoryRepository _categoryRepo;
  final _dateFormat = DateFormat.yMMMd();
  final _uuid = Uuid();

  SubscriptionService(this._expenseRepo, this._categoryRepo);

  /// Retrieves all subscription expenses and enhances them with status information
  Future<List<SubscriptionData>> getSubscriptions() async {
    final expenses = await _expenseRepo.getAllExpenses();
    final subscriptions = expenses
        .where((expense) => expense.type == ExpenseType.subscription)
        .toList();
    
    return _enhanceSubscriptions(subscriptions);
  }

  /// Retrieves subscriptions for a specific month
  Future<List<SubscriptionData>> getSubscriptionsForMonth(DateTime month) async {
    final expenses = await _expenseRepo.getAllExpenses();
    final subscriptions = expenses
        .where((expense) => 
            expense.type == ExpenseType.subscription &&
            expense.date.year == month.year &&
            expense.date.month == month.month)
        .toList();
    
    return _enhanceSubscriptions(subscriptions);
  }

  /// Calculates a summary of subscription costs for a specific month
  Future<SubscriptionSummary> getSubscriptionSummaryForMonth(DateTime month) async {
    final subscriptions = await getSubscriptionsForMonth(month);
    
    // Calculate monthly costs
    final monthlySubscriptions = subscriptions
        .where((sub) => sub.expense.billingCycle == 'Monthly')
        .toList();
    
    final yearlySubscriptions = subscriptions
        .where((sub) => sub.expense.billingCycle == 'Yearly')
        .toList();
    
    final monthlyBillingAmount = monthlySubscriptions.fold(
        0.0, (sum, sub) => sum + sub.expense.amount);
    
    final yearlyBillingAmount = yearlySubscriptions.fold(
        0.0, (sum, sub) => sum + sub.expense.amount);
    
    // Count the full yearly amount in the month it was paid
    // We still keep the monthly equivalent for reference
    final yearlyBillingMonthlyEquivalent = yearlyBillingAmount / 12;
    
    // Use the monthly equivalent approach to match what getSubscriptionSummary() does
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

  /// Retrieves subscriptions filtered by status
  Future<List<SubscriptionData>> getSubscriptionsByStatus(SubscriptionStatus status) async {
    final allSubscriptions = await getSubscriptions();
    return allSubscriptions.where((sub) => sub.status == status).toList();
  }

  /// Calculates a summary of subscription costs and statistics
  Future<SubscriptionSummary> getSubscriptionSummary() async {
    final subscriptions = await getSubscriptions();
    
    // Calculate monthly costs
    final monthlySubscriptions = subscriptions
        .where((sub) => sub.expense.billingCycle == 'Monthly')
        .toList();
    
    final yearlySubscriptions = subscriptions
        .where((sub) => sub.expense.billingCycle == 'Yearly')
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

  /// Updates the next billing date for a subscription based on its billing cycle
  DateTime calculateNextBillingDate(Expense subscription) {
    final lastBillingDate = subscription.nextBillingDate ?? subscription.date;
    final billingCycle = subscription.billingCycle ?? 'Monthly';
    
    if (billingCycle == 'Monthly') {
      // Add one month to the last billing date
      return DateTime(
        lastBillingDate.year,
        lastBillingDate.month + 1,
        lastBillingDate.day,
      );
    } else if (billingCycle == 'Yearly') {
      // Add one year to the last billing date
      return DateTime(
        lastBillingDate.year + 1,
        lastBillingDate.month,
        lastBillingDate.day,
      );
    }
    
    // Default fallback
    return lastBillingDate;
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
    
    // Check if overdue (billing date is in the past)
    if (billingDate.isBefore(today)) {
      return SubscriptionStatus.overdue;
    }
    
    // Check if due soon (within next 3 days)
    final threeDaysFromNow = today.add(const Duration(days: 3));
    if (!billingDate.isAfter(threeDaysFromNow)) {
      return SubscriptionStatus.dueSoon;
    }
    
    return SubscriptionStatus.active;
  }

  /// Formats a date for display, with special handling for today and tomorrow
  String formatDate(DateTime? date) {
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

  /// Process recurring subscriptions to create new expense entries for due/overdue subscriptions
  /// 
  /// @deprecated Use RecurringExpenseService.processRecurringExpenses() instead.
  /// This method is kept for backward compatibility but will be removed in a future version.
  @Deprecated('Use RecurringExpenseService.processRecurringExpenses() instead')
  Future<int> processRecurringSubscriptions() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int processedCount = 0;
    
    // Get all active recurring subscription templates
    final expenses = await _expenseRepo.getAllExpenses();
    final subscriptions = expenses.where((expense) => 
      expense.type == ExpenseType.subscription && 
      expense.isRecurring == true &&
      (expense.endDate == null || expense.endDate!.isAfter(today))
    ).toList();
    
    for (final subscription in subscriptions) {
      final nextBillingDate = subscription.nextBillingDate;
      
      // If next billing date is null, in the past, or today - process it
      if (nextBillingDate != null && 
          (nextBillingDate.isBefore(today) || 
           nextBillingDate.isAtSameMomentAs(DateTime(today.year, today.month, today.day)))) {
        
        // Create a new expense entry based on the subscription
        // Keep the original subscription type for consistency
        final newExpense = subscription.copyWith(
          id: _uuid.v4(),
          date: nextBillingDate,
          createdAt: now,
          isRecurring: false, // This is a generated instance
          nextBillingDate: null, // Clear this for the instance
          // Keep the original subscription type for consistency
        );
        
        await _expenseRepo.addExpense(newExpense);
        
        // Update the subscription template with the next billing date
        final updatedSubscription = subscription.copyWith(
          nextBillingDate: calculateNextBillingDate(subscription),
        );
        
        await _expenseRepo.updateExpense(updatedSubscription);
        processedCount++;
      }
    }
    
    return processedCount;
  }

  /// Enhances a list of subscription expenses with additional data and status
  List<SubscriptionData> _enhanceSubscriptions(List<Expense> subscriptions) {
    return subscriptions.map((subscription) {
      final nextBillingDate = subscription.nextBillingDate;
      final status = getSubscriptionStatus(nextBillingDate);
      final billingCycle = subscription.billingCycle ?? 'Monthly';
      
      // Calculate monthly equivalent cost
      double monthlyEquivalentCost = subscription.amount;
      if (billingCycle == 'Yearly') {
        monthlyEquivalentCost = subscription.amount / 12;
      }
      
      return SubscriptionData(
        expense: subscription,
        status: status,
        nextBillingDate: nextBillingDate,
        formattedNextBillingDate: formatDate(nextBillingDate),
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