import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/expense_form_controller.dart';
import '../../../forms/number_pad.dart';
import '../../../../utils/formatters.dart';

class AmountStepWidget extends StatelessWidget {
  final VoidCallback? onNext;

  const AmountStepWidget({
    super.key,
    required this.onNext,
  });

  void _dummyCallback() {
    // Empty callback (not used when showDateButton is false)
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ExpenseFormController>(
      builder: (context, controller, child) {
        return Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Amount display
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          formatCurrency(double.tryParse(controller.amount) ?? 0)
                              .split('.')[0],
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (controller.amount.contains('.'))
                          Text(
                            '.${controller.amount.split('.')[1]}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Number pad
            Container(
              color: theme.colorScheme.surface,
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
                onDoubleZeroPressed: () {
                  if (controller.amount != '0') {
                    controller.setAmount(controller.amount + '00');
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