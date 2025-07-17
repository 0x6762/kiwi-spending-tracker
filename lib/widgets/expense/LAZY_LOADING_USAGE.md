# Lazy Loading Expense List Usage Guide

## Overview

The `LazyLoadingExpenseList` widget provides infinite scroll functionality for expense lists, automatically loading more data as the user scrolls. This is perfect for large datasets and provides a smooth user experience.

## Key Features

- **Infinite Scroll**: Automatically loads more expenses when user reaches the bottom
- **Pull to Refresh**: Swipe down to refresh the list
- **Date Grouping**: Groups expenses by date with daily totals (default: enabled)
- **Date Range Filtering**: Filter expenses by date range
- **Sorting Options**: Sort by date or amount, ascending or descending
- **Configurable Page Size**: Adjust how many items load per page
- **Loading Indicators**: Shows loading state at the bottom while fetching more data
- **Empty State**: Displays empty state when no expenses are found

## Basic Usage

```dart
import 'package:your_app/widgets/expense/lazy_loading_expense_list.dart';

LazyLoadingExpenseList(
  expenseRepo: expenseRepository,
  categoryRepo: categoryRepository,
  onTap: (expense) {
    // Handle expense tap
  },
  onDelete: (expense) {
    // Handle expense deletion
  },
)
```

## Advanced Usage with Filters

```dart
LazyLoadingExpenseList(
  expenseRepo: expenseRepository,
  categoryRepo: categoryRepository,
  onTap: _viewExpenseDetails,
  onDelete: _deleteExpense,
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime(2024, 12, 31),
  orderBy: 'amount',
  descending: false,
  pageSize: 50,
  showEmptyState: true,
  groupByDate: true, // Enable date grouping
)
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `expenseRepo` | `ExpenseRepository` | Required | Repository for expense data |
| `categoryRepo` | `CategoryRepository` | Required | Repository for category data |
| `onTap` | `Function(Expense)?` | null | Callback when expense is tapped |
| `onDelete` | `Function(Expense)?` | null | Callback when expense is deleted |
| `startDate` | `DateTime?` | null | Filter expenses from this date |
| `endDate` | `DateTime?` | null | Filter expenses until this date |
| `orderBy` | `String?` | null | Sort field ('date' or 'amount') |
| `descending` | `bool` | true | Sort direction |
| `pageSize` | `int` | 20 | Number of items per page |
| `showEmptyState` | `bool` | true | Show empty state when no data |
| `groupByDate` | `bool` | true | Group expenses by date with daily totals |

## Date Grouping Features

When `groupByDate` is enabled (default), the widget provides:

- **Daily Sections**: Expenses grouped by date
- **Section Headers**: "Today", "Yesterday", or formatted dates (outside cards)
- **Daily Totals**: Sum of all expenses for each day
- **Card Layout**: Each date group is contained within its own card component
- **Upcoming Expenses**: Future expenses grouped separately
- **Smart Sorting**: Upcoming first, then by date descending

### Example Output with Grouping:

```
Today • Total: $45.20
┌─────────────────────────────────────┐
│ Coffee Shop • $4.50                │
│ Groceries • $32.70                 │
│ Gas • $8.00                        │
└─────────────────────────────────────┘

Yesterday • Total: $28.15
┌─────────────────────────────────────┐
│ Lunch • $12.50                     │
│ Movie • $15.65                     │
└─────────────────────────────────────┘

Dec 15 • Total: $67.30
┌─────────────────────────────────────┐
│ Shopping • $45.00                  │
│ Dinner • $22.30                    │
└─────────────────────────────────────┘

Upcoming • Total: $29.99
┌─────────────────────────────────────┐
│ Netflix Subscription • $29.99      │
└─────────────────────────────────────┘
```

## Integration with Existing Screens

### Replace ExpenseList with LazyLoadingExpenseList

**Before:**
```dart
ExpenseList(
  expenses: expenses,
  categoryRepo: categoryRepo,
  onTap: _viewExpenseDetails,
  onDelete: _deleteExpense,
)
```

**After:**
```dart
LazyLoadingExpenseList(
  expenseRepo: expenseRepo,
  categoryRepo: categoryRepo,
  onTap: _viewExpenseDetails,
  onDelete: _deleteExpense,
  groupByDate: true, // Keep the date grouping
)
```

### Example: All Expenses Screen

```dart
class AllExpensesScreen extends StatefulWidget {
  final ExpenseRepository expenseRepo;
  final CategoryRepository categoryRepo;
  final AccountRepository accountRepo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Expenses')),
      body: LazyLoadingExpenseList(
        expenseRepo: expenseRepo,
        categoryRepo: categoryRepo,
        onTap: _viewExpenseDetails,
        onDelete: _deleteExpense,
        orderBy: 'date',
        descending: true,
        pageSize: 20,
        groupByDate: true, // Enable date grouping
      ),
    );
  }
}
```

## Performance Benefits

1. **Memory Efficient**: Only loads visible data + buffer
2. **Fast Initial Load**: Shows first page quickly
3. **Smooth Scrolling**: No lag when scrolling through large lists
4. **Network Friendly**: Loads data in chunks, reducing server load
5. **Smart Grouping**: Groups data efficiently without performance impact

## Best Practices

1. **Page Size**: Use 20-50 items per page for optimal performance
2. **Error Handling**: Implement proper error handling in your callbacks
3. **Loading States**: The widget handles loading states automatically
4. **Refresh**: Users can pull to refresh to reload data
5. **Filters**: Use date ranges to limit data for better performance
6. **Grouping**: Keep `groupByDate: true` for better UX unless you need a simple list

## Database Requirements

Make sure your `ExpenseRepository` implements these methods:

```dart
abstract class ExpenseRepository {
  Future<List<Expense>> getExpensesPaginated({
    int limit = 20,
    int offset = 0,
    String? orderBy,
    bool descending = true,
  });
  
  Future<int> getExpensesCount();
  
  Future<List<Expense>> getExpensesByDateRangePaginated(
    DateTime start,
    DateTime end, {
    int limit = 20,
    int offset = 0,
  });
  
  Future<int> getExpensesByDateRangeCount(DateTime start, DateTime end);
}
```

## Troubleshooting

### List not loading more data
- Check if `_hasMoreData` is true
- Verify database queries return correct data
- Ensure `pageSize` is reasonable (not too large)

### Performance issues
- Reduce `pageSize` if loading is slow
- Add database indexes on frequently queried fields
- Consider caching strategies for repeated queries

### Empty state showing incorrectly
- Check if `showEmptyState` is set to true
- Verify database has data
- Ensure date filters are not too restrictive

### Date grouping not working
- Ensure `groupByDate` is set to true
- Check that expenses have valid dates
- Verify the grouping logic handles edge cases 