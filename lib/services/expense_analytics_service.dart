import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';

class CategorySpending {
  final String categoryId;
  final double amount;
  final double percentage;

  CategorySpending({
    required this.categoryId,
    required this.amount,
    required this.percentage,
  });
}

class MonthlyAnalytics {
  final double totalSpent;
  final double subscriptionExpenses;
  final double fixedExpenses;
  final double variableExpenses;
  final double previousMonthTotal;
  final double percentageChange;
  final bool isIncrease;

  MonthlyAnalytics({
    required this.totalSpent,
    required this.subscriptionExpenses,
    required this.fixedExpenses,
    required this.variableExpenses,
    required this.previousMonthTotal,
    required this.percentageChange,
    required this.isIncrease,
  });
}

class ExpenseAnalyticsService {
  final ExpenseRepository _expenseRepo;
  final CategoryRepository _categoryRepo;

  ExpenseAnalyticsService(this._expenseRepo, this._categoryRepo);

  Future<List<CategorySpending>> getCategorySpending(List<Expense> expenses) async {
    if (expenses.isEmpty) return [];

    final Map<String, double> totals = {};
    final double totalSpent = expenses.fold(0.0, (sum, expense) => sum + expense.amount);

    // Calculate raw totals
    for (final expense in expenses) {
      final categoryId = expense.categoryId ?? CategoryRepository.uncategorizedId;
      totals[categoryId] = (totals[categoryId] ?? 0.0) + expense.amount;
    }

    // Convert to percentages and create CategorySpending objects
    final List<CategorySpending> result = [];
    
    if (totalSpent > 0) {
      totals.forEach((categoryId, amount) {
        result.add(CategorySpending(
          categoryId: categoryId,
          amount: amount,
          percentage: (amount / totalSpent) * 100,
        ));
      });
    }

    // Sort by percentage (descending)
    result.sort((a, b) => b.percentage.compareTo(a.percentage));
    
    return result;
  }

  Future<MonthlyAnalytics> getMonthlyAnalytics(DateTime selectedMonth) async {
    final expenses = await _expenseRepo.getAllExpenses();
    
    // Return default values if there are no expenses
    if (expenses.isEmpty) {
      return MonthlyAnalytics(
        totalSpent: 0.0,
        subscriptionExpenses: 0.0,
        fixedExpenses: 0.0,
        variableExpenses: 0.0,
        previousMonthTotal: 0.0,
        percentageChange: 0.0,
        isIncrease: false,
      );
    }
    
    // Filter expenses for selected month
    final monthlyExpenses = expenses.where((expense) =>
        expense.date.year == selectedMonth.year &&
        expense.date.month == selectedMonth.month).toList();

    // Calculate totals for each expense type
    final subscriptionTotal = monthlyExpenses
        .where((expense) => expense.type == ExpenseType.subscription)
        .fold(0.0, (sum, expense) => sum + expense.amount);

    final fixedTotal = monthlyExpenses
        .where((expense) => expense.type == ExpenseType.fixed)
        .fold(0.0, (sum, expense) => sum + expense.amount);

    final variableTotal = monthlyExpenses
        .where((expense) => expense.type == ExpenseType.variable)
        .fold(0.0, (sum, expense) => sum + expense.amount);

    final monthlyTotal = subscriptionTotal + fixedTotal + variableTotal;

    // Calculate previous month total
    final previousMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    final previousMonthTotal = expenses
        .where((expense) =>
            expense.date.year == previousMonth.year &&
            expense.date.month == previousMonth.month)
        .fold(0.0, (sum, expense) => sum + expense.amount);

    // Calculate percentage change
    double percentageChange = 0;
    bool isIncrease = false;
    
    if (previousMonthTotal > 0) {
      final difference = monthlyTotal - previousMonthTotal;
      percentageChange = (difference / previousMonthTotal * 100).abs();
      isIncrease = difference > 0;
    }

    return MonthlyAnalytics(
      totalSpent: monthlyTotal,
      subscriptionExpenses: subscriptionTotal,
      fixedExpenses: fixedTotal,
      variableExpenses: variableTotal,
      previousMonthTotal: previousMonthTotal,
      percentageChange: percentageChange,
      isIncrease: isIncrease,
    );
  }

  Future<Map<DateTime, double>> getMonthlyTotals(DateTime startDate, DateTime endDate) async {
    final expenses = await _expenseRepo.getAllExpenses();
    final Map<DateTime, double> monthlyTotals = {};

    // Filter expenses within date range and group by month
    for (final expense in expenses) {
      if (expense.date.isAfter(startDate) && expense.date.isBefore(endDate)) {
        final monthKey = DateTime(expense.date.year, expense.date.month);
        monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0.0) + expense.amount;
      }
    }

    return monthlyTotals;
  }
} 