import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../models/expense_category.dart';
import '../../repositories/category_repository.dart';
import 'picker_button.dart';
import '../sheets/picker_sheet.dart';
import '../sheets/add_category_sheet.dart';
import '../common/app_input.dart';
import '../../utils/icons.dart';
import '../../theme/theme.dart';
import '../../theme/design_tokens.dart';
import '../common/icon_container.dart';

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
    final fixedExpenseColor = theme.colorScheme.fixedExpenseColor;
    final variableExpenseColor = theme.colorScheme.variableExpenseColor;

    // Custom widget for SVG icon in PickerButton
    Widget _buildSvgIcon(String assetPath, Color color) {
      return IconContainer.svg(
        svgPath: assetPath,
        iconColor: color,
        backgroundColor: color.withOpacity(0.1),
        size: IconContainerSize.medium,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: DesignTokens.spacingSm),
        Container(
          width: double.infinity,
          alignment: Alignment.topLeft,
          child: AppInput(
            controller: titleController,
            hintText: 'Type expense name',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        // Category selector
        SizedBox(height: DesignTokens.spacingSm),
        PickerButton(
          label: selectedCategory?.name ?? 'Select Category',
          icon: selectedCategory?.icon ?? AppIcons.category,
          onTap: onCategoryTap,
        ),
        
        // Expense Type selector (if not subscription)
        if (expenseType != ExpenseType.subscription) ...[
          SizedBox(height: DesignTokens.spacingSm),
          TextButton(
            onPressed: () => onExpenseTypeChanged(!isFixedExpense),
            style: TextButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainer,
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              padding: DesignTokens.paddingSymmetric(
                horizontal: DesignTokens.spacingMd,
                vertical: DesignTokens.spacingMd,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: DesignTokens.borderRadius(DesignTokens.radiusInput),
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
                SizedBox(width: DesignTokens.spacingMd),
                Expanded(
                  child: Text(
                    isFixedExpense ? 'Fixed' : 'Variable',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: DesignTokens.iconButton,
                ),
              ],
            ),
          ),
        ],
        
        // Only keep the billing cycle selector for subscription expenses
        if (expenseType == ExpenseType.subscription) ...[
          SizedBox(height: DesignTokens.spacingSm),
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