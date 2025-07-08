import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/expense_form_controller.dart';
import '../../../../models/expense.dart';
import '../../../forms/picker_button.dart';
import '../../../sheets/picker_sheet.dart';
import '../../../../utils/icons.dart';
import '../../../common/primary_button.dart';

class DetailsStepWidget extends StatelessWidget {
  final VoidCallback? onSubmit;

  const DetailsStepWidget({
    super.key,
    required this.onSubmit,
  });

  void _showExpenseTypePicker(BuildContext context, ExpenseFormController controller) {
    PickerSheet.show(
      context: context,
      title: 'Expense Type',
      children: [
        ListTile(
          leading: SvgPicture.asset(
            'assets/icons/variable_expense.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              const Color(0xFF8056E4),
              BlendMode.srcIn,
            ),
          ),
          title: const Text('Variable Expense'),
          selected: !controller.isFixedExpense,
          onTap: () {
            controller.setFixedExpense(false);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: SvgPicture.asset(
            'assets/icons/fixed_expense.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              const Color(0xFFCF5825),
              BlendMode.srcIn,
            ),
          ),
          title: const Text('Fixed Expense'),
          selected: controller.isFixedExpense,
          onTap: () {
            controller.setFixedExpense(true);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void _showBillingCyclePicker(BuildContext context, ExpenseFormController controller) {
    PickerSheet.show(
      context: context,
      title: 'Billing Cycle',
      children: ['Monthly', 'Yearly'].map(
        (cycle) => ListTile(
          leading: SvgPicture.asset(
            'assets/icons/subscription.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              const Color(0xFF2196F3),
              BlendMode.srcIn,
            ),
          ),
          title: Text(cycle),
          selected: controller.billingCycle == cycle,
          onTap: () {
            controller.setBillingCycle(cycle);
            Navigator.pop(context);
          },
        ),
      ).toList(),
    );
  }

  Future<void> _selectDate(BuildContext context, ExpenseFormController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.setDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();

    return Consumer<ExpenseFormController>(
      builder: (context, controller, child) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question text
                    Text(
                      'Expense date',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Date picker
                    PickerButton(
                      label: dateFormat.format(controller.selectedDate),
                      icon: AppIcons.calendar,
                      onTap: () => _selectDate(context, controller),
                    ),
                    const SizedBox(height: 24),
                    
                    // Optional detail section
                    Text(
                      'Optional detail',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Expense type picker (if not subscription)
                    if (controller.initialType != ExpenseType.subscription)
                      _ExpenseTypePickerButton(
                        label: controller.isFixedExpense ? 'Fixed Expense' : 'Variable Expense',
                        isFixed: controller.isFixedExpense,
                        onTap: () => _showExpenseTypePicker(context, controller),
                      ),
                    
                    // Billing cycle picker (if subscription)
                    if (controller.initialType == ExpenseType.subscription)
                      _SubscriptionPickerButton(
                        label: controller.billingCycle,
                        onTap: () => _showBillingCyclePicker(context, controller),
                      ),
                    const SizedBox(height: 12),
                    
                    // Expense name
                    TextFormField(
                      initialValue: controller.expenseName,
                      onChanged: controller.setExpenseName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Expense name (optional)',
                        hintStyle: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainer,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Submit button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: PrimaryButton(
                text: controller.isEditMode ? 'Update' : 'Add Expense',
                onPressed: onSubmit,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ExpenseTypePickerButton extends StatelessWidget {
  final String label;
  final bool isFixed;
  final VoidCallback onTap;

  const _ExpenseTypePickerButton({
    required this.label,
    required this.isFixed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconPath = isFixed ? 'assets/icons/fixed_expense.svg' : 'assets/icons/variable_expense.svg';
    final iconColor = isFixed ? const Color(0xFFCF5825) : const Color(0xFF8056E4);
    
    return TextButton(
      onPressed: onTap,
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              iconPath,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                iconColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
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
    );
  }
}

class _SubscriptionPickerButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SubscriptionPickerButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const subscriptionColor = Color(0xFF2196F3);
    
    return TextButton(
      onPressed: onTap,
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: subscriptionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              'assets/icons/subscription.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                subscriptionColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
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
    );
  }
} 