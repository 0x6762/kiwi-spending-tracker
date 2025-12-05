import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/expense_form_controller.dart';
import '../../../models/expense.dart';
import '../../../widgets/forms/picker_button.dart';
import '../../../widgets/sheets/picker_sheet.dart';
import '../../../widgets/common/app_input.dart';
import '../../../widgets/common/app_button.dart';
import '../../../utils/icons.dart';

class DetailsStepWidget extends StatelessWidget {
  final VoidCallback? onSubmit;

  const DetailsStepWidget({
    super.key,
    required this.onSubmit,
  });

  void _showFrequencyPicker(
      BuildContext context, ExpenseFormController controller) {
    // Frequency is only available for subscriptions
    final frequencyOptions = [
      {'label': 'Monthly', 'value': ExpenseFrequency.monthly},
      {'label': 'Yearly', 'value': ExpenseFrequency.yearly},
    ];

    PickerSheet.show(
      context: context,
      title: 'Billing Cycle',
      children: frequencyOptions
          .map(
            (option) => ListTile(
              title: Text(option['label'] as String),
              selected: controller.frequency == option['value'],
              onTap: () {
                controller.setFrequency(option['value'] as ExpenseFrequency);
                Navigator.pop(context);
              },
            ),
          )
          .toList(),
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

    return Selector<ExpenseFormController, bool>(
      selector: (_, controller) => controller.canProceedFromStep(2),
      shouldRebuild: (prev, next) => prev != next,
      builder: (context, canProceed, child) {
        final controller =
            Provider.of<ExpenseFormController>(context, listen: false);

        return Selector<ExpenseFormController, String>(
          selector: (_, controller) => controller.expenseName,
          shouldRebuild: (prev, next) => prev != next,
          builder: (context, expenseName, child) {
            return Selector<ExpenseFormController, bool>(
              selector: (_, controller) => controller.isRecurring,
              shouldRebuild: (prev, next) => prev != next,
              builder: (context, isRecurring, child) {
                return Selector<ExpenseFormController, ExpenseFrequency>(
                  selector: (_, controller) => controller.frequency,
                  shouldRebuild: (prev, next) => prev != next,
                  builder: (context, frequency, child) {
                    return Selector<ExpenseFormController, bool>(
                      selector: (_, controller) => controller.isEditMode,
                      shouldRebuild: (prev, next) => prev != next,
                      builder: (context, isEditMode, child) {
                        return Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Expense name
                                    AppInput(
                                      initialValue: expenseName,
                                      hintText: 'Expense name (optional)',
                                      onChanged: controller.setExpenseName,
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      hintStyle:
                                          theme.textTheme.titleSmall?.copyWith(
                                        color: theme
                                            .colorScheme.onSurfaceVariant
                                            .withOpacity(0.7),
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Recurring toggle
                                    SwitchListTile(
                                      title: Text(
                                        'Recurring Expense',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      subtitle: Text(
                                        'Enable for expenses that repeat regularly',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      value: isRecurring,
                                      onChanged: (value) =>
                                          controller.setRecurring(value),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 4),
                                    ),

                                    // Frequency section - only when recurring is enabled
                                    if (isRecurring) ...[
                                      const SizedBox(height: 24),
                                      // Frequency label
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 4, bottom: 16),
                                        child: Text(
                                          'Billing Cycle',
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                      // Frequency picker
                                      PickerButton(
                                        label: _getFrequencyLabel(frequency),
                                        icon: AppIcons.calendar,
                                        onTap: () => _showFrequencyPicker(
                                            context, controller),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            // Submit button
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              child: AppButton.primary(
                                text: isEditMode ? 'Update' : 'Add Expense',
                                onPressed: canProceed && onSubmit != null
                                    ? onSubmit!
                                    : null,
                                isExpanded: true,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
