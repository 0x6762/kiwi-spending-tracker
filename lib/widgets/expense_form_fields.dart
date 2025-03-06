import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/account.dart';
import 'picker_button.dart';
import '../utils/icons.dart';

class ExpenseFormFields extends StatelessWidget {
  final TextEditingController titleController;
  final ExpenseCategory? selectedCategory;
  final Account? selectedAccount;
  final bool isFixedExpense;
  final ExpenseType expenseType;
  final VoidCallback onCategoryTap;
  final VoidCallback onAccountTap;
  final Function(bool?) onFixedExpenseChanged;
  final DateTime dueDate;
  final VoidCallback onDueDateTap;
  final String billingCycle;
  final VoidCallback onBillingCycleTap;
  final DateTime nextBillingDate;
  final VoidCallback onNextBillingDateTap;

  const ExpenseFormFields({
    super.key,
    required this.titleController,
    required this.selectedCategory,
    required this.selectedAccount,
    required this.isFixedExpense,
    required this.expenseType,
    required this.onCategoryTap,
    required this.onAccountTap,
    required this.onFixedExpenseChanged,
    required this.dueDate,
    required this.onDueDateTap,
    required this.billingCycle,
    required this.onBillingCycleTap,
    required this.nextBillingDate,
    required this.onNextBillingDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          alignment: Alignment.topLeft,
          child: TextFormField(
            controller: titleController,
            textAlign: TextAlign.start,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Type expense name',
              hintStyle: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: theme.colorScheme.surfaceContainerLowest,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (selectedAccount != null) PickerButton(
          label: selectedAccount!.name,
          icon: selectedAccount!.icon,
          iconColor: selectedAccount!.color,
          onTap: onAccountTap,
        ),
        const SizedBox(height: 8),
        PickerButton(
          label: selectedCategory?.name ?? 'Select Category',
          icon: selectedCategory?.icon ?? AppIcons.category,
          onTap: onCategoryTap,
        ),
        
        // Add Fixed Expense checkbox if not subscription
        if (expenseType != ExpenseType.subscription) ...[
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              onFixedExpenseChanged(!isFixedExpense);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: isFixedExpense,
                        onChanged: onFixedExpenseChanged,
                        activeColor: theme.colorScheme.primary,
                      ),
                      Text(
                        'Fixed expense?',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        
        // Show due date field if fixed expense is checked
        if (expenseType != ExpenseType.subscription && isFixedExpense) ...[
          const SizedBox(height: 24),
          Text(
            'Due Date',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          PickerButton(
            label: _formatDate(dueDate),
            icon: AppIcons.calendar,
            onTap: onDueDateTap,
          ),
        ],
        
        if (expenseType == ExpenseType.subscription) ...[
          const SizedBox(height: 24),
          Text(
            'Billing Cycle / Due Date',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          PickerButton(
            label: billingCycle,
            icon: AppIcons.calendar,
            onTap: onBillingCycleTap,
          ),
          const SizedBox(height: 8),
          PickerButton(
            label: _formatDate(nextBillingDate),
            icon: AppIcons.calendar,
            onTap: onNextBillingDateTap,
          ),
        ],
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
} 