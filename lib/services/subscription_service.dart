import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';
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

/// Service for managing and analyzing subscription expenses.
/// 
/// Note: This service handles analytics, status tracking, and subscription-specific
/// data enhancement only. All recurring expense processing (including subscriptions)
/// is handled by RecurringExpenseService.
class SubscriptionService {
  final ExpenseRepository _expenseRepo;
  // ignore: unused_field
  final CategoryRepository _categoryRepo;
  final _dateFormat = DateFormat.yMMMd();

  SubscriptionService(this._expenseRepo, this._categoryRepo);

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

  /// Updates the next billing date for a subscription based on its billing cycle or frequency
  DateTime calculateNextBillingDate(Expense subscription) {
    final lastBillingDate = subscription.nextBillingDate ?? subscription.date;
    
    // Use frequency-based system
    switch (subscription.frequency) {
      case ExpenseFrequency.monthly:
        return DateTime(
          lastBillingDate.year,
          lastBillingDate.month + 1,
          lastBillingDate.day,
        );
      case ExpenseFrequency.yearly:
        return DateTime(
          lastBillingDate.year + 1,
          lastBillingDate.month,
          lastBillingDate.day,
        );
      default:
        // For other frequencies or oneTime, return the last billing date
        return lastBillingDate;
    }
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