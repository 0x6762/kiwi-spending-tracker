import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/expense_form_controller.dart';
import '../../../../models/expense.dart';
import '../../../forms/picker_button.dart';
import '../../../sheets/picker_sheet.dart';
import '../../../../utils/icons.dart';

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

  void _showFrequencyPicker(BuildContext context, ExpenseFormController controller) {
    const frequencyOptions = [
      {'label': 'One-time', 'value': ExpenseFrequency.oneTime},
      {'label': 'Weekly', 'value': ExpenseFrequency.weekly},
      {'label': 'Bi-weekly', 'value': ExpenseFrequency.biWeekly},
      {'label': 'Monthly', 'value': ExpenseFrequency.monthly},
      {'label': 'Quarterly', 'value': ExpenseFrequency.quarterly},
      {'label': 'Yearly', 'value': ExpenseFrequency.yearly},
    ];

    PickerSheet.show(
      context: context,
      title: 'Frequency',
      children: frequencyOptions.map(
        (option) => ListTile(
          title: Text(option['label'] as String),
          selected: controller.frequency == option['value'],
          onTap: () {
            controller.setFrequency(option['value'] as ExpenseFrequency);
            Navigator.pop(context);
          },
        ),
      ).toList(),
    );
  }

  String _getFrequencyLabel(ExpenseFrequency frequency) {
    switch (frequency) {
      case ExpenseFrequency.oneTime:
        return 'One-time';
      case ExpenseFrequency.weekly:
        return 'Weekly';
      case ExpenseFrequency.biWeekly:
        return 'Bi-weekly';
      case ExpenseFrequency.monthly:
        return 'Monthly';
      case ExpenseFrequency.quarterly:
        return 'Quarterly';
      case ExpenseFrequency.yearly:
        return 'Yearly';
      default:
        return 'One-time';
    }
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
                    // Expense type section with label
                    // Expense type label
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 16),
                      child: Text(
                        'Expense type',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    // Expense type picker
                    PickerButton(
                      label: controller.isFixedExpense ? 'Fixed' : 'Variable',
                      icon: AppIcons.category,
                      onTap: () => _showExpenseTypePicker(context, controller),
                    ),
                    const SizedBox(height: 24),
                    
                    // Recurrency section
                    // Frequency label
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 16),
                      child: Text(
                        'Frequency',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    // Frequency picker
                    PickerButton(
                      label: _getFrequencyLabel(controller.frequency),
                      icon: AppIcons.calendar,
                      onTap: () => _showFrequencyPicker(context, controller),
                    ),
                    const SizedBox(height: 24),
                    
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
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
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