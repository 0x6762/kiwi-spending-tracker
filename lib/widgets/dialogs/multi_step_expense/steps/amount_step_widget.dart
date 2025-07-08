import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/expense_form_controller.dart';
import '../../../forms/number_pad.dart';
import '../../../../utils/formatters.dart';
import '../../../../models/account.dart';
import '../../../forms/picker_button.dart';
import '../../../sheets/picker_sheet.dart';
import '../../../../utils/icons.dart';

class AmountStepWidget extends StatelessWidget {
  final VoidCallback? onNext;

  const AmountStepWidget({
    super.key,
    required this.onNext,
  });

  void _dummyCallback() {
    // Empty callback (not used when showDateButton is false)
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ExpenseFormController>(
      builder: (context, controller, child) {
        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question text
                    Text(
                      'How much did you spend?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Amount display
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          formatCurrency(double.tryParse(controller.amount) ?? 0)
                              .split('.')[0],
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (controller.amount.contains('.'))
                          Text(
                            '.${controller.amount.split('.')[1]}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Account picker
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: PickerButton(
                label: controller.selectedAccount?.name ?? 'Loading...',
                icon: controller.selectedAccount?.icon ?? AppIcons.wallet,
                iconColor: controller.selectedAccount?.color,
                onTap: () => _showAccountPicker(context, controller),
              ),
            ),
            // Number pad
            Container(
              color: theme.colorScheme.surface,
              padding: const EdgeInsets.all(16),
              child: NumberPad(
                onDigitPressed: (digit) {
                  String newAmount = controller.amount;
                  if (controller.amount == '0') {
                    newAmount = digit;
                  } else {
                    if (controller.amount.contains('.')) {
                      final parts = controller.amount.split('.');
                      if (parts.length > 1 && parts[1].length >= 2) {
                        return;
                      }
                    }
                    newAmount = controller.amount + digit;
                  }
                  controller.setAmount(newAmount);
                },
                onDecimalPointPressed: () {
                  if (!controller.amount.contains('.')) {
                    controller.setAmount(controller.amount + '.');
                  }
                },
                onBackspacePressed: () {
                  if (controller.amount.isNotEmpty) {
                    final newAmount = controller.amount.substring(0, controller.amount.length - 1);
                    controller.setAmount(newAmount.isEmpty ? '0' : newAmount);
                  }
                },
                onDatePressed: _dummyCallback,
                onSubmitPressed: onNext ?? () {},
                submitButtonText: 'Next',
                showDateButton: false,
              ),
            ),
          ],
        );
      },
    );
  }
} 