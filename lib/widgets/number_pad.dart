import 'package:flutter/material.dart';
import '../utils/icons.dart';

class NumberPad extends StatelessWidget {
  final void Function(String) onDigitPressed;
  final VoidCallback onDecimalPointPressed;
  final VoidCallback onDoubleZeroPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback onDatePressed;
  final VoidCallback onSubmitPressed;
  final String submitButtonText;
  
  const NumberPad({
    super.key,
    required this.onDigitPressed,
    required this.onDecimalPointPressed,
    required this.onDoubleZeroPressed,
    required this.onBackspacePressed,
    required this.onDatePressed,
    required this.onSubmitPressed,
    this.submitButtonText = 'Add',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: _buildNumberPadButton(context, '1', onPressed: () => onDigitPressed('1'))),
            Expanded(child: _buildNumberPadButton(context, '2', onPressed: () => onDigitPressed('2'))),
            Expanded(child: _buildNumberPadButton(context, '3', onPressed: () => onDigitPressed('3'))),
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
        Row(
          children: [
            Expanded(child: _buildNumberPadButton(context, '4', onPressed: () => onDigitPressed('4'))),
            Expanded(child: _buildNumberPadButton(context, '5', onPressed: () => onDigitPressed('5'))),
            Expanded(child: _buildNumberPadButton(context, '6', onPressed: () => onDigitPressed('6'))),
            Expanded(
              child: _buildNumberPadButton(
                context,
                'date',
                onPressed: onDatePressed,
                isAction: true,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
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
                      Expanded(child: _buildNumberPadButton(context, '00', onPressed: onDoubleZeroPressed)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildNumberPadButton(
                context,
                'save',
                onPressed: onSubmitPressed,
                isAction: true,
                isLarge: true,
              ),
            ),
          ],
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
      aspectRatio: isLarge ? 0.7 : 1.4,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: text == 'save'
              ? theme.colorScheme.primary
              : text == 'date'
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : theme.colorScheme.surfaceContainer,
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

  Widget _buildButtonContent(BuildContext context, String text, bool isAction) {
    final theme = Theme.of(context);
    switch (text) {
      case 'backspace':
        return Icon(
          AppIcons.backspace,
          color: theme.colorScheme.onSurfaceVariant,
          size: 24,
        );
      case 'date':
        return Icon(
          AppIcons.calendar,
          color: theme.colorScheme.primary,
          size: 24,
        );
      case 'save':
        return Text(
          submitButtonText,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w800,
          ),
        );
      default:
        return Text(
          text,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        );
    }
  }
} 