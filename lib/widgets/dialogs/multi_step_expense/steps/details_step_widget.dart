import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/expense_form_controller.dart';
import '../../../../models/expense.dart';
import '../../../../models/account.dart';
import '../../../forms/picker_button.dart';
import '../../../sheets/picker_sheet.dart';
import '../../../../utils/icons.dart';

class DetailsStepWidget extends StatelessWidget {
  final VoidCallback? onSubmit;

  const DetailsStepWidget({
    super.key,
    required this.onSubmit,
  });

  void _showAccountPicker(BuildContext context, ExpenseFormController controller) async {
    await controller.accountRepo.loadAccounts();
    final accounts = await controller.accountRepo.getAllAccounts();
    accounts.sort((a, b) {
      if (a.isDefault != b.isDefault) {
        return a.isDefault ? -1 : 1;
      }
      return a.name.compareTo(b.name);
    });

    if (!context.mounted) return;

    PickerSheet.show(
      context: context,
      title: 'Select Account',
      children: accounts.map(
        (account) => ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: account.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              account.icon,
              color: account.color,
            ),
          ),
          title: Text(account.name),
          selected: controller.selectedAccount?.id == account.id,
          onTap: () {
            controller.setAccount(account);
            Navigator.pop(context);
          },
        ),
      ).toList(),
    );
  }

  void _showExpenseTypePicker(BuildContext context, ExpenseFormController controller) {
    PickerSheet.show(
      context: context,
      title: 'Expense Type',
      children: [
        ListTile(
          title: const Text('Variable'),
          selected: !controller.isFixedExpense,
          onTap: () {
            controller.setFixedExpense(false);
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('Fixed'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    // Expense name
                    TextFormField(
                      initialValue: controller.expenseName,
                      onChanged: controller.setExpenseName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Expense name (optional)',
                        hintStyle: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainer,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Account picker
                    if (controller.selectedAccount != null)
                      PickerButton(
                        label: controller.selectedAccount!.name,
                        icon: controller.selectedAccount!.icon,
                        iconColor: controller.selectedAccount!.color,
                        onTap: () => _showAccountPicker(context, controller),
                      ),
                    const SizedBox(height: 12),
                    
                    // Expense type picker (if not subscription)
                    if (controller.initialType != ExpenseType.subscription)
                      PickerButton(
                        label: controller.isFixedExpense ? 'Fixed' : 'Variable',
                        icon: AppIcons.category,
                        onTap: () => _showExpenseTypePicker(context, controller),
                      ),
                    const SizedBox(height: 12),
                    
                    // Billing cycle picker (if subscription)
                    if (controller.initialType == ExpenseType.subscription)
                      PickerButton(
                        label: controller.billingCycle,
                        icon: AppIcons.calendar,
                        onTap: () => _showBillingCyclePicker(context, controller),
                      ),
                  ],
                ),
              ),
            ),
            // Submit button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  controller.isEditMode ? 'Update' : 'Add Expense',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
} 