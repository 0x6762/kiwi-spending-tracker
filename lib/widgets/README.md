# Widgets Directory Structure

This directory contains all the reusable UI components (widgets) used throughout the Kiwi Spending Tracker app. To maintain a clean and organized codebase, widgets are categorized into subdirectories based on their purpose and functionality.

## Directory Structure

```
lib/widgets/
├── common/         # Common UI components used across the app
├── expense/        # Expense-related display widgets
├── forms/          # Form components and input widgets
├── charts/         # Data visualization and chart widgets
├── sheets/         # Bottom sheet components
├── dialogs/        # Dialog components
└── index.dart      # Main export file for easy imports
```

## Usage

You can import widgets in two ways:

### 1. Using the main index file (recommended)

```dart
import '../widgets/index.dart';
```

This will give you access to all widgets through their respective namespaces:

```dart
// Examples
KiwiAppBar(...);                 // common widget
ExpenseList(...);                // expense widget
NumberPad(...);                  // forms widget
MonthlyExpenseChart(...);        // charts widget
PickerSheet.show(...);           // sheets widget
AddExpenseDialog(...);           // dialogs widget
```

### 2. Importing specific widget categories

```dart
import '../widgets/expense/index.dart';
import '../widgets/forms/index.dart';
```

## Categories

### Common Widgets

Basic UI components used throughout the app:
- `app_bar.dart`: Custom app bar component

### Expense Widgets

Widgets for displaying expense data:
- `expense_list.dart`: List of expenses
- `expense_summary.dart`: Summary of expenses

- `today_spending_card.dart`: Card showing today's spending
- `expense_filter_row.dart`: Filter controls for expenses
- `category_statistics.dart`: Statistics for expense categories

### Form Widgets

Input components and form-related widgets:
- `expense_form_fields.dart`: Form fields for expense entry
- `number_pad.dart`: Custom numeric keypad
- `amount_display.dart`: Display for monetary amounts
- `picker_button.dart`: Button for selection pickers
- `voice_input_button.dart`: Button for voice input

### Chart Widgets

Data visualization components:
- `monthly_expense_chart.dart`: Chart showing monthly expenses

### Sheet Widgets

Bottom sheet components:
- `picker_sheet.dart`: Sheet for selection pickers
- `bottom_sheet.dart`: Base bottom sheet component
- `add_category_sheet.dart`: Sheet for adding categories
- `add_account_sheet.dart`: Sheet for adding accounts
- `color_picker_sheet.dart`: Sheet for color selection
- `expense_type_sheet.dart`: Sheet for selecting expense types

### Dialog Widgets

Dialog components:
- `add_expense_dialog.dart`: Dialog for adding expenses
- `delete_confirmation_dialog.dart`: Dialog for confirming deletions 