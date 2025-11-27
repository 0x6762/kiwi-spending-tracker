import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';
import '../models/account.dart';
import 'unified_upcoming_service.dart';
import 'recurring_expense_service.dart';

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

class DailyMetrics {
  final double todayTotal;
  final double todayCreditCardTotal;
  final double averageDaily;
  final double averageWeekly;

  DailyMetrics({
    required this.todayTotal,
    required this.todayCreditCardTotal,
    required this.averageDaily,
    required this.averageWeekly,
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
  final double averageMonthly;

  MonthlyAnalytics({
    required this.totalSpent,
    required this.subscriptionExpenses,
    required this.fixedExpenses,
    required this.variableExpenses,
    required this.previousMonthTotal,
    required this.percentageChange,
    required this.isIncrease,
    required this.averageMonthly,
  });
}

class UpcomingExpensesAnalytics {
  final List<Expense> upcomingExpenses;
  final double totalAmount;
  final DateTime fromDate;

  UpcomingExpensesAnalytics({
    required this.upcomingExpenses,
    required this.totalAmount,
    required this.fromDate,
  });
}

class ExpenseAnalyticsService {
  final ExpenseRepository _expenseRepo;
  // ignore: unused_field
  final CategoryRepository _categoryRepo;

  ExpenseAnalyticsService(this._expenseRepo, this._categoryRepo);

  Future<List<CategorySpending>> getCategorySpending(
      List<Expense> expenses) async {
    if (expenses.isEmpty) return [];

    final now = DateTime.now();

    final effectiveExpenses = expenses
        .where((expense) =>
                expense.status == ExpenseStatus.paid &&
                expense.date.isBefore(now.add(
                    const Duration(days: 1))) // Include today, exclude future
            )
        .toList();

    if (effectiveExpenses.isEmpty) return [];

    final Map<String, double> totals = {};
    final double totalSpent =
        effectiveExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

    // Calculate raw totals
    for (final expense in effectiveExpenses) {
      final categoryId =
          expense.categoryId ?? CategoryRepository.uncategorizedId;
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

  /// Get monthly analytics from repository (legacy method)
  Future<MonthlyAnalytics> getMonthlyAnalytics(DateTime selectedMonth) async {
    // Get only paid expenses
    final expenses =
        await _expenseRepo.getEffectiveExpenses(asOfDate: DateTime.now());
    return getMonthlyAnalyticsFromExpenses(expenses, selectedMonth);
  }

  /// Get monthly analytics from provided expenses list
  /// Filters to paid expenses and calculates analytics
  MonthlyAnalytics getMonthlyAnalyticsFromExpenses(
      List<Expense> expenses, DateTime selectedMonth) {
    // Filter to only paid expenses (effective expenses)
    final now = DateTime.now();
    final effectiveExpenses = expenses
        .where((expense) =>
            expense.status != ExpenseStatus.cancelled &&
            expense.date.isBefore(now.add(const Duration(days: 1))))
        .toList();

    if (effectiveExpenses.isEmpty) {
      return MonthlyAnalytics(
        totalSpent: 0.0,
        subscriptionExpenses: 0.0,
        fixedExpenses: 0.0,
        variableExpenses: 0.0,
        previousMonthTotal: 0.0,
        percentageChange: 0.0,
        isIncrease: false,
        averageMonthly: 0.0,
      );
    }

    // Filter expenses for selected month
    final monthlyExpenses = effectiveExpenses
        .where((expense) =>
            expense.date.year == selectedMonth.year &&
            expense.date.month == selectedMonth.month)
        .toList();

    // Calculate totals for each expense type
    final subscriptionTotal = monthlyExpenses
        .where((expense) =>
            expense.type == ExpenseType.subscription &&
            (
                // Either it's not a recurring subscription (actual payment)
                expense.isRecurring == false ||
                    // OR it's a template from the selected month (not just today)
                    (expense.isRecurring == true &&
                        expense.date.year == selectedMonth.year &&
                        expense.date.month == selectedMonth.month)))
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
    final previousMonthTotal = effectiveExpenses
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

    // Calculate monthly average (based on last 6 months)
    final last6Months = List.generate(6, (index) {
      return DateTime(now.year, now.month - (5 - index));
    });

    double totalForAverage = 0.0;
    int monthsWithData = 0;

    for (final month in last6Months) {
      final monthExpenses = effectiveExpenses.where((expense) =>
          expense.date.year == month.year &&
          expense.date.month == month.month &&
          expense.status == ExpenseStatus.paid);

      final monthTotal =
          monthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
      if (monthTotal > 0) {
        totalForAverage += monthTotal;
        monthsWithData++;
      }
    }

    final averageMonthly =
        monthsWithData > 0 ? totalForAverage / monthsWithData : 0.0;

    return MonthlyAnalytics(
      totalSpent: monthlyTotal,
      subscriptionExpenses: subscriptionTotal,
      fixedExpenses: fixedTotal,
      variableExpenses: variableTotal,
      previousMonthTotal: previousMonthTotal,
      percentageChange: percentageChange,
      isIncrease: isIncrease,
      averageMonthly: averageMonthly,
    );
  }

  Future<Map<DateTime, double>> getMonthlyTotals(
      DateTime startDate, DateTime endDate) async {
    // Get only paid expenses
    final expenses =
        await _expenseRepo.getEffectiveExpenses(asOfDate: DateTime.now());
    final Map<DateTime, double> monthlyTotals = {};

    // Filter expenses within date range and group by month
    for (final expense in expenses) {
      if (expense.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(endDate.add(const Duration(days: 1)))) {
        // For subscription templates, include them in their creation month
        final monthKey = DateTime(expense.date.year, expense.date.month);
        if (expense.type == ExpenseType.subscription &&
            expense.isRecurring == true) {
          // Nothing to skip - we want to include subscription templates in their creation month
        }

        monthlyTotals[monthKey] =
            (monthlyTotals[monthKey] ?? 0.0) + expense.amount;
      }
    }

    return monthlyTotals;
  }

  DailyMetrics getDailyMetrics(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return DailyMetrics(
        todayTotal: 0.0,
        todayCreditCardTotal: 0.0,
        averageDaily: 0.0,
        averageWeekly: 0.0,
      );
    }

    final now = DateTime.now();

    // Filter to only include paid expenses (not pending or cancelled)
    final effectiveExpenses = expenses
        .where((expense) => expense.status == ExpenseStatus.paid)
        .toList();

    if (effectiveExpenses.isEmpty) {
      return DailyMetrics(
        todayTotal: 0.0,
        todayCreditCardTotal: 0.0,
        averageDaily: 0.0,
        averageWeekly: 0.0,
      );
    }

    double todayTotal = 0.0;
    double todayCreditCardTotal = 0.0;
    double monthlyTotal = 0.0;
    var daysWithExpenses =
        <int>{}; // Using int for day of month instead of DateTime

    for (final expense in effectiveExpenses) {
      // Skip expenses from other months early
      if (expense.date.year != now.year || expense.date.month != now.month) {
        continue;
      }

      final amount = expense.amount;
      monthlyTotal += amount;
      daysWithExpenses.add(expense.date.day);

      if (expense.date.day == now.day) {
        todayTotal += amount;
        if (expense.accountId == DefaultAccounts.creditCard.id) {
          todayCreditCardTotal += amount;
        }
      }
    }

    final averageDaily =
        daysWithExpenses.isEmpty ? 0.0 : monthlyTotal / daysWithExpenses.length;

    // Calculate weekly average (past 7 days including today)
    final sevenDaysAgo = now.subtract(const Duration(days: 6));
    final weekStart =
        DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day);
    final weekEnd = DateTime(now.year, now.month, now.day);

    final weekExpenses = effectiveExpenses.where((expense) =>
        expense.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        expense.date.isBefore(weekEnd.add(const Duration(days: 1))));

    final weekTotal =
        weekExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final averageWeekly =
        weekTotal / 7; // Always divide by 7 for consistent weekly average

    return DailyMetrics(
      todayTotal: todayTotal,
      todayCreditCardTotal: todayCreditCardTotal,
      averageDaily: averageDaily,
      averageWeekly: averageWeekly,
    );
  }

  // Updated method to use unified upcoming service
  Future<UpcomingExpensesAnalytics> getUpcomingExpenses(
      {DateTime? fromDate}) async {
    // Create unified service instance (read-only, doesn't need ExpenseStateManager)
    final recurringService = RecurringExpenseService(_expenseRepo, null);
    final upcomingService =
        UnifiedUpcomingService(_expenseRepo, recurringService);

    // Get comprehensive summary
    final summary = await upcomingService.getUpcomingExpensesSummary(
      fromDate: fromDate,
      daysAhead: 30,
    );

    // Get upcoming items with full context
    final upcomingItems = await upcomingService.getUpcomingExpenses(
      fromDate: fromDate,
      daysAhead: 30,
    );

    // Convert to existing format for backward compatibility
    final expenses = upcomingItems.map((item) => item.expense).toList();

    return UpcomingExpensesAnalytics(
      upcomingExpenses: expenses,
      totalAmount: summary.totalAmount,
      fromDate: summary.fromDate,
    );
  }
}
