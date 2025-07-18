# Unified Upcoming Service - Implementation Guide

## Overview

The `UnifiedUpcomingService` provides a single, consistent interface for handling all upcoming expenses, whether they are:
- **Manual expenses** created by users with future dates
- **Recurring templates** that will generate expenses soon
- **Generated instances** created by the recurring expense service

## Key Benefits

### **1. Single Source of Truth**
- One service handles all upcoming expense logic
- Consistent date handling and sorting
- Unified filtering and grouping options

### **2. Clear Expense Classification**
- Distinguishes between recurring templates and manual expenses
- Provides context about expense origins
- Enables smart UI decisions based on expense type

### **3. Flexible Querying**
- Time-based queries (today, this week, this month, custom range)
- Type-based filtering (recurring vs manual)
- Comprehensive summaries with breakdowns

### **4. Enhanced User Experience**
- Better expense type descriptions
- Accurate date predictions for recurring expenses
- Improved sorting and grouping

## Architecture

### **Core Components**

#### **1. UpcomingExpenseItem**
```dart
class UpcomingExpenseItem {
  final Expense expense;
  final bool isRecurringTemplate;
  final bool isGeneratedInstance;
  final DateTime? nextOccurrenceDate;
  final String? recurringTemplateId;
}
```

**Purpose**: Wraps an expense with additional context about its nature and timing.

#### **2. UpcomingExpensesSummary**
```dart
class UpcomingExpensesSummary {
  final double totalAmount;
  final double recurringAmount;
  final double manualAmount;
  final int totalCount;
  final int recurringCount;
  final int manualCount;
  final DateTime fromDate;
  final DateTime toDate;
}
```

**Purpose**: Provides aggregated statistics about upcoming expenses.

### **Service Dependencies**
- `ExpenseRepository`: For accessing expense data
- `RecurringExpenseService`: For recurring expense logic

## Usage Examples

### **1. Basic Upcoming Expenses**
```dart
final upcomingService = UnifiedUpcomingService(expenseRepo, recurringService);

// Get all upcoming expenses in the next 30 days
final upcoming = await upcomingService.getUpcomingExpenses(daysAhead: 30);

// Get upcoming expenses from a specific date
final fromDate = DateTime(2024, 1, 1);
final upcoming = await upcomingService.getUpcomingExpenses(
  fromDate: fromDate,
  daysAhead: 60,
);
```

### **2. Filtered Queries**
```dart
// Get only manual upcoming expenses
final manualUpcoming = await upcomingService.getUpcomingExpenses(
  daysAhead: 30,
  includeRecurringTemplates: false,
  includeGeneratedInstances: false,
);

// Get only recurring template upcoming expenses
final recurringUpcoming = await upcomingService.getUpcomingExpenses(
  daysAhead: 30,
  includeManualExpenses: false,
  includeGeneratedInstances: false,
);
```

### **3. Time-Based Queries**
```dart
// Get expenses due today
final todayExpenses = await upcomingService.getExpensesDueToday();

// Get expenses due this week
final weekExpenses = await upcomingService.getExpensesDueThisWeek();

// Get expenses due this month
final monthExpenses = await upcomingService.getExpensesDueThisMonth();
```

### **4. Type-Based Queries**
```dart
// Get upcoming expenses grouped by type
final grouped = await upcomingService.getUpcomingExpensesByType(daysAhead: 30);

// Get upcoming expenses for a specific type
final subscriptionUpcoming = await upcomingService.getUpcomingExpensesByType(
  type: ExpenseType.subscription,
  daysAhead: 30,
);
```

### **5. Summary and Analytics**
```dart
// Get comprehensive summary
final summary = await upcomingService.getUpcomingExpensesSummary(daysAhead: 30);

print('Total upcoming: ${summary.totalAmount}');
print('Recurring: ${summary.recurringAmount} (${summary.recurringPercentage}%)');
print('Manual: ${summary.manualAmount} (${summary.manualPercentage}%)');
print('Total count: ${summary.totalCount}');
```

### **6. Overdue Detection**
```dart
// Get overdue recurring expenses
final overdue = await upcomingService.getOverdueRecurringExpenses();

if (overdue.isNotEmpty) {
  print('Found ${overdue.length} overdue recurring expenses');
  // Process overdue expenses
}
```

## Integration with Existing Code

### **1. Replace Current Upcoming Logic**

#### **Before (Current Implementation)**
```dart
// In expense_analytics_service.dart
Future<UpcomingExpensesAnalytics> getUpcomingExpenses({DateTime? fromDate}) async {
  final referenceDate = fromDate ?? DateTime.now();
  final upcomingExpenses = await _expenseRepo.getUpcomingExpenses(fromDate: referenceDate);
  
  final totalAmount = upcomingExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  
  return UpcomingExpensesAnalytics(
    upcomingExpenses: upcomingExpenses,
    totalAmount: totalAmount,
    fromDate: referenceDate,
  );
}
```

#### **After (Using Unified Service)**
```dart
// In expense_analytics_service.dart
Future<UpcomingExpensesAnalytics> getUpcomingExpenses({DateTime? fromDate}) async {
  final upcomingService = UnifiedUpcomingService(_expenseRepo, _recurringService);
  final summary = await upcomingService.getUpcomingExpensesSummary(
    fromDate: fromDate,
    daysAhead: 30,
  );
  
  // Convert to existing format for backward compatibility
  final upcomingItems = await upcomingService.getUpcomingExpenses(
    fromDate: fromDate,
    daysAhead: 30,
  );
  
  final expenses = upcomingItems.map((item) => item.expense).toList();
  
  return UpcomingExpensesAnalytics(
    upcomingExpenses: expenses,
    totalAmount: summary.totalAmount,
    fromDate: summary.fromDate,
  );
}
```

### **2. Update UI Components**

#### **Upcoming Expenses Card**
```dart
class UpcomingExpensesCard extends StatelessWidget {
  final UpcomingExpensesSummary summary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard.standard(
      onTap: onTap,
      child: Column(
        children: [
          Text('Upcoming'),
          Text(formatCurrency(summary.totalAmount)),
          if (summary.hasRecurringUpcoming)
            Text('${summary.recurringCount} recurring'),
          if (summary.hasManualUpcoming)
            Text('${summary.manualCount} manual'),
        ],
      ),
    );
  }
}
```

#### **Upcoming Expenses Screen**
```dart
class UpcomingExpensesScreen extends StatefulWidget {
  @override
  State<UpcomingExpensesScreen> createState() => _UpcomingExpensesScreenState();
}

class _UpcomingExpensesScreenState extends State<UpcomingExpensesScreen> {
  late UnifiedUpcomingService _upcomingService;
  List<UnifiedUpcomingService.UpcomingExpenseItem> _upcomingItems = [];
  UpcomingExpensesSummary? _summary;

  @override
  void initState() {
    super.initState();
    _upcomingService = UnifiedUpcomingService(widget.repository, widget.recurringService);
    _loadUpcomingExpenses();
  }

  Future<void> _loadUpcomingExpenses() async {
    final upcoming = await _upcomingService.getUpcomingExpenses(daysAhead: 30);
    final summary = await _upcomingService.getUpcomingExpensesSummary(daysAhead: 30);
    
    setState(() {
      _upcomingItems = upcoming;
      _summary = summary;
    });
  }

  Widget _buildUpcomingItem(UnifiedUpcomingService.UpcomingExpenseItem item) {
    return ListTile(
      title: Text(item.expense.title),
      subtitle: Text('${item.typeDescription} - ${_formatDate(item.effectiveDate)}'),
      trailing: Text(formatCurrency(item.displayAmount)),
      leading: Icon(
        item.isRecurringTemplate ? Icons.repeat : Icons.schedule,
        color: item.isRecurringTemplate ? Colors.blue : Colors.grey,
      ),
    );
  }
}
```

## Migration Strategy

### **Phase 1: Add Unified Service (Current)**
- ✅ Create `UnifiedUpcomingService`
- ✅ Add comprehensive documentation
- ✅ Test with existing data

### **Phase 2: Gradual Integration**
- Update `ExpenseAnalyticsService` to use unified service
- Update UI components to show expense type context
- Add new UI features (filtering, grouping)

### **Phase 3: Full Migration**
- Replace all existing upcoming expense logic
- Remove duplicate code from other services
- Optimize performance and caching

### **Phase 4: Enhanced Features**
- Add smart notifications for upcoming expenses
- Implement predictive upcoming expenses
- Add expense templates and quick actions

## Benefits for Different User Types

### **For End Users**
- **Clearer Information**: Know which expenses are recurring vs manual
- **Better Planning**: See accurate upcoming expense totals
- **Reduced Confusion**: No duplicate expenses in lists

### **For Developers**
- **Simplified Code**: One service instead of multiple approaches
- **Better Testing**: Centralized logic is easier to test
- **Easier Maintenance**: Single source of truth for upcoming logic

### **For Product Managers**
- **Better Analytics**: Detailed breakdowns of upcoming expenses
- **Enhanced Features**: Foundation for notifications and predictions
- **Improved UX**: More intuitive expense management

## Future Enhancements

### **1. Smart Notifications**
```dart
// Get expenses due in the next 3 days
final urgentExpenses = await upcomingService.getUpcomingExpenses(daysAhead: 3);
if (urgentExpenses.isNotEmpty) {
  // Send notification
}
```

### **2. Predictive Upcoming Expenses**
```dart
// Predict expenses based on recurring patterns
final predictedExpenses = await upcomingService.getPredictedExpenses(
  monthsAhead: 3,
);
```

### **3. Expense Templates**
```dart
// Quick creation of common upcoming expenses
final template = await upcomingService.createExpenseTemplate(
  title: 'Monthly Rent',
  amount: 1200.0,
  frequency: ExpenseFrequency.monthly,
);
```

### **4. Budget Integration**
```dart
// Check if upcoming expenses fit within budget
final budgetImpact = await upcomingService.getBudgetImpact(
  budgetId: 'monthly_budget',
  daysAhead: 30,
);
```

## Conclusion

The `UnifiedUpcomingService` provides a robust foundation for handling all upcoming expenses in a consistent, user-friendly way. It eliminates the confusion between recurring templates and manual expenses while providing rich context for better decision-making.

The service is designed to be:
- **Backward Compatible**: Can work alongside existing code
- **Extensible**: Easy to add new features and capabilities
- **Performant**: Efficient queries and caching strategies
- **User-Friendly**: Clear classification and helpful context

This unified approach will significantly improve the user experience while making the codebase more maintainable and feature-rich. 