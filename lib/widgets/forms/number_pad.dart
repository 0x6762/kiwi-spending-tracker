import 'package:flutter/material.dart';
import '../../utils/icons.dart';
import '../common/primary_button.dart';

class NumberPad extends StatelessWidget {
  final void Function(String) onDigitPressed;
  final VoidCallback onDecimalPointPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback onDatePressed;
  final VoidCallback onSubmitPressed;
  final String submitButtonText;
  final bool showDateButton;
  
  const NumberPad({
    super.key,
    required this.onDigitPressed,
    required this.onDecimalPointPressed,
    required this.onBackspacePressed,
    required this.onDatePressed,
    required this.onSubmitPressed,
    this.submitButtonText = 'Add',
    this.showDateButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 3x4 Number pad grid
        Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildNumberPadButton(context, '1', onPressed: () => onDigitPressed('1'))),
                Expanded(child: _buildNumberPadButton(context, '2', onPressed: () => onDigitPressed('2'))),
                Expanded(child: _buildNumberPadButton(context, '3', onPressed: () => onDigitPressed('3'))),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildNumberPadButton(context, '4', onPressed: () => onDigitPressed('4'))),
                Expanded(child: _buildNumberPadButton(context, '5', onPressed: () => onDigitPressed('5'))),
                Expanded(child: _buildNumberPadButton(context, '6', onPressed: () => onDigitPressed('6'))),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildNumberPadButton(context, '7', onPressed: () => onDigitPressed('7'))),
                Expanded(child: _buildNumberPadButton(context, '8', onPressed: () => onDigitPressed('8'))),
                Expanded(child: _buildNumberPadButton(context, '9', onPressed: () => onDigitPressed('9'))),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildNumberPadButton(context, '.', onPressed: onDecimalPointPressed)),
                Expanded(child: _buildNumberPadButton(context, '0', onPressed: () => onDigitPressed('0'))),
                Expanded(
                  child: _buildNumberPadButton(
                    context,
                    'backspace',
                    onPressed: onBackspacePressed,
                    isAction: true,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Separate submit button
        Container(
          width: double.infinity,
          child: _buildSubmitButton(context),
        ),
      ],
    );
  }

  Widget _buildNumberPadButton(
    BuildContext context,
    String text, {
    VoidCallback? onPressed,
    bool isAction = false,
    bool isLarge = false,
  }) {
    final theme = Theme.of(context);
    return AspectRatio(
      aspectRatio: 1.4,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: _buildButtonContent(context, text, isAction),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return PrimaryButton(
      text: submitButtonText,
      onPressed: onSubmitPressed,
    );
  }

  Widget _buildButtonContent(BuildContext context, String text, bool isAction) {
    final theme = Theme.of(context);
    switch (text) {
      case 'backspace':
        return Icon(
          AppIcons.backspace,
          color: theme.colorScheme.onSurfaceVariant,
          size: 24,
        );
      default:
        return Text(
          text,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        );
    }
  }
} 