import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';
import '../utils/formatters.dart';
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

  SubscriptionData({
    required this.expense,
    required this.status,
    required this.nextBillingDate,
    required this.formattedNextBillingDate,
    required this.billingCycle,
    required this.monthlyEquivalentCost,
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

  SubscriptionService(this._expenseRepo, this._categoryRepo);

  /// Retrieves all subscription expenses and enhances them with status information
  Future<List<SubscriptionData>> getSubscriptions() async {
    final expenses = await _expenseRepo.getAllExpenses();
    final subscriptions = expenses
        .where((expense) => expense.type == ExpenseType.subscription)
        .toList();
    
    return _enhanceSubscriptions(subscriptions);
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