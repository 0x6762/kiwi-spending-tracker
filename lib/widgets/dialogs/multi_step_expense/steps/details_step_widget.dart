import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../controllers/expense_form_controller.dart';
import '../../../../models/expense.dart';
import '../../../forms/picker_button.dart';
import '../../../sheets/picker_sheet.dart';
import '../../../common/app_input.dart';
import '../../../common/app_button.dart';
import '../../../../utils/icons.dart';
import '../../../../theme/theme.dart';

class DetailsStepWidget extends StatelessWidget {
  final VoidCallback? onSubmit;

  const DetailsStepWidget({
    super.key,
    required this.onSubmit,
  });

  // Custom widget for SVG icon in expense type picker
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

  void _showExpenseTypePicker(BuildContext context, ExpenseFormController controller) {
    PickerSheet.show(
      context: context,
      title: 'Expense Type',
      children: [
        ListTile(
          title: const Text('Variable'),
          selected: controller.selectedExpenseType == ExpenseType.variable,
          onTap: () {
            controller.setExpenseType(ExpenseType.variable);
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('Fixed'),
          selected: controller.selectedExpenseType == ExpenseType.fixed,
          onTap: () {
            controller.setExpenseType(ExpenseType.fixed);
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('Subscription'),
          selected: controller.selectedExpenseType == ExpenseType.subscription,
          onTap: () {
            controller.setExpenseType(ExpenseType.subscription);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void _showFrequencyPicker(BuildContext context, ExpenseFormController controller) {
    final isSubscription = controller.selectedExpenseType == ExpenseType.subscription;
    
    final frequencyOptions = isSubscription 
      ? [
          {'label': 'Monthly', 'value': ExpenseFrequency.monthly},
          {'label': 'Yearly', 'value': ExpenseFrequency.yearly},
        ]
      : [
          {'label': 'One-time', 'value': ExpenseFrequency.oneTime},
          {'label': 'Weekly', 'value': ExpenseFrequency.weekly},
          {'label': 'Bi-weekly', 'value': ExpenseFrequency.biWeekly},
          {'label': 'Monthly', 'value': ExpenseFrequency.monthly},
          {'label': 'Quarterly', 'value': ExpenseFrequency.quarterly},
          {'label': 'Yearly', 'value': ExpenseFrequency.yearly},
        ];

    PickerSheet.show(
      context: context,
      title: isSubscription ? 'Billing Cycle' : 'Frequency',
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

  String _getExpenseTypeIcon(ExpenseType type) {
    switch (type) {
      case ExpenseType.fixed:
        return 'assets/icons/fixed_expense.svg';
      case ExpenseType.subscription:
        return 'assets/icons/subscription.svg';
      case ExpenseType.variable:
      default:
        return 'assets/icons/variable_expense.svg';
    }
  }

  Color _getExpenseTypeColor(ExpenseType type, ThemeData theme) {
    switch (type) {
      case ExpenseType.fixed:
        return theme.colorScheme.fixedExpenseColor;
      case ExpenseType.subscription:
        return theme.colorScheme.subscriptionColor;
      case ExpenseType.variable:
      default:
        return theme.colorScheme.variableExpenseColor;
    }
  }

  String _getExpenseTypeLabel(ExpenseType type) {
    switch (type) {
      case ExpenseType.fixed:
        return 'Fixed';
      case ExpenseType.subscription:
        return 'Subscription';
      case ExpenseType.variable:
      default:
        return 'Variable';
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
                    TextButton(
                      onPressed: () => _showExpenseTypePicker(context, controller),
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
                            _getExpenseTypeIcon(controller.selectedExpenseType),
                            _getExpenseTypeColor(controller.selectedExpenseType, theme),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _getExpenseTypeLabel(controller.selectedExpenseType),
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
                    const SizedBox(height: 24),
                    
                    // Frequency section - always visible
                    const SizedBox(height: 24),
                    // Frequency label
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 16),
                      child: Text(
                        controller.selectedExpenseType == ExpenseType.subscription 
                          ? 'Billing Cycle' 
                          : 'Frequency',
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
                    AppInput(
                      initialValue: controller.expenseName,
                      hintText: 'Expense name (optional)',
                      onChanged: controller.setExpenseName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      hintStyle: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
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
              child: AppButton.primary(
                text: controller.isEditMode ? 'Update' : 'Add Expense',
                onPressed: onSubmit,
                isExpanded: true,
              ),
            ),
          ],
        );
      },
    );
  }
} 