import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/expense.dart';
import '../../models/expense_category.dart';
import '../../models/account.dart';
import 'picker_button.dart';
import '../../utils/icons.dart';

class ExpenseFormFields extends StatelessWidget {
  final TextEditingController titleController;
  final ExpenseCategory? selectedCategory;
  final Account? selectedAccount;
  final bool isFixedExpense;
  final ExpenseType expenseType;
  final VoidCallback onCategoryTap;
  final VoidCallback onAccountTap;
  final Function(bool) onExpenseTypeChanged;
  final String billingCycle;
  final VoidCallback onBillingCycleTap;
  
  // We still keep these parameters to maintain backward compatibility
  // but they're not used in the UI anymore
  final DateTime dueDate;
  final VoidCallback onDueDateTap;
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
    required this.onExpenseTypeChanged,
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

    // Custom widget for SVG icon in PickerButton
    Widget _buildSvgIcon(String assetPath, Color color) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SvgPicture.asset(
          assetPath,
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      );
    }

    // Define the colors for expense types
    final fixedExpenseColor = const Color(0xFFCF5825); // Orange
    final variableExpenseColor = const Color(0xFF8056E4); // Purple

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
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
        
        // Account and Category selectors
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
        
        // Expense Type selector (if not subscription)
        if (expenseType != ExpenseType.subscription) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => onExpenseTypeChanged(!isFixedExpense),
            style: TextButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainer,
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              padding: const EdgeInsets.only(
                left: 12,
                right: 16,
                top: 12,
                bottom: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSvgIcon(
                  isFixedExpense 
                    ? 'assets/icons/fixed_expense.svg' 
                    : 'assets/icons/variable_expense.svg',
                  isFixedExpense ? fixedExpenseColor : variableExpenseColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isFixedExpense ? 'Fixed' : 'One time',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
        
        // Only keep the billing cycle selector for subscription expenses
        if (expenseType == ExpenseType.subscription) ...[
          const SizedBox(height: 8),
          PickerButton(
            label: billingCycle,
            icon: AppIcons.calendar,
            onTap: onBillingCycleTap,
          ),
        ],
      ],
    );
  }
} 