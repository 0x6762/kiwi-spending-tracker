# Recurring Expense Service

The `RecurringExpenseService` provides unified automation for all types of recurring expenses, not just subscriptions.

## Features

- **Universal Automation**: Works with all expense types (subscription, fixed, variable)
- **Frequency-Based**: Uses `ExpenseFrequency` enum for consistent date calculations
- **Template System**: Maintains templates separate from generated instances
- **Automatic Processing**: Runs on app startup to process due/overdue expenses

## How It Works

### 1. Template vs Instance

**Template** (`isRecurring: true`):
- Stays in database as a "template"
- Has `nextBillingDate` for automation
- Used to generate actual expense instances

**Instance** (`isRecurring: false`):
- Generated when template is due
- Appears in expense lists
- Counts toward totals and analytics

### 2. Automation Process

```dart
// On app startup
final processedCount = await recurringExpenseService.processRecurringExpenses();
```

The service:
1. Finds all templates with `isRecurring: true`
2. Checks if `nextBillingDate` is due/overdue
3. Creates new expense instance
4. Updates template with next billing date

### 3. Supported Frequencies

- `daily` - Every day
- `weekly` - Every 7 days
- `biWeekly` - Every 14 days
- `monthly` - Every month
- `quarterly` - Every 3 months
- `yearly` - Every year

## Usage Examples

### Creating a Recurring Template

```dart
// Monthly utility bill
final utilityTemplate = await recurringExpenseService.createRecurringTemplate(
  title: 'Electricity Bill',
  amount: 150.0,
  type: ExpenseType.fixed,
  frequency: ExpenseFrequency.monthly,
  categoryId: 'utilities',
  accountId: 'checking',
);

// Weekly grocery budget
final groceryTemplate = await recurringExpenseService.createRecurringTemplate(
  title: 'Weekly Groceries',
  amount: 100.0,
  type: ExpenseType.variable,
  frequency: ExpenseFrequency.weekly,
  categoryId: 'groceries',
  accountId: 'checking',
);
```

### Querying Recurring Expenses

```dart
// Get all templates
final templates = await recurringExpenseService.getRecurringTemplates();

// Get templates by type
final subscriptionTemplates = await recurringExpenseService.getRecurringTemplatesByType(ExpenseType.subscription);

// Get upcoming expenses (next 30 days)
final upcoming = await recurringExpenseService.getUpcomingRecurringExpenses(daysAhead: 30);

// Get overdue templates
final overdue = await recurringExpenseService.getOverdueRecurringExpenses();

// Calculate monthly recurring cost
final monthlyCost = await recurringExpenseService.getMonthlyRecurringCost();
```

## Migration from Subscription Service

The new service replaces the subscription-specific automation:

**Before** (Subscription Service):
- Only worked with `ExpenseType.subscription`
- Used `billingCycle` field
- Limited to Monthly/Yearly

**After** (Recurring Expense Service):
- Works with all expense types
- Uses `frequency` field
- Supports all frequencies

## Integration

The service is automatically initialized in `main.dart` and processes recurring expenses on app startup. It's available throughout the app via dependency injection.

```dart
// Access in widgets
final recurringService = Provider.of<RecurringExpenseService>(context, listen: false);
``` 