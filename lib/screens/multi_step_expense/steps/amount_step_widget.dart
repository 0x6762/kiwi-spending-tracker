import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../controllers/expense_form_controller.dart';
import '../../../widgets/forms/number_pad.dart';
import '../../../widgets/forms/picker_button.dart';
import '../../../widgets/sheets/picker_sheet.dart';
import '../../../utils/formatters.dart';

class AmountStepWidget extends StatefulWidget {
  final VoidCallback? onNext;

  const AmountStepWidget({
    super.key,
    required this.onNext,
  });

  @override
  State<AmountStepWidget> createState() => _AmountStepWidgetState();
}

class _AmountStepWidgetState extends State<AmountStepWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isAccountPickerVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateAccountPickerVisibility(String amount) {
    final shouldShow = amount != '0' && amount.isNotEmpty;
    if (shouldShow != _isAccountPickerVisible) {
      setState(() {
        _isAccountPickerVisible = shouldShow;
      });
      
      if (shouldShow) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
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

  Widget _buildDynamicAmountDisplay(ThemeData theme, String amount, double availableWidth) {
    final formattedAmount = formatCurrency(double.tryParse(amount) ?? 0);
    
    // Detect decimal separator (could be '.' or ',' depending on locale)
    String integerPart;
    String decimalPart = '';
    
    if (formattedAmount.contains(',') && formattedAmount.lastIndexOf(',') > formattedAmount.lastIndexOf('.')) {
      // BRL format: "R$ 1.234,56" - comma is decimal separator
      final parts = formattedAmount.split(',');
      integerPart = parts[0];
      if (amount.contains('.') && parts.length > 1) {
        decimalPart = ',${amount.split('.')[1]}';
      }
    } else {
      // USD format: "$1,234.56" - period is decimal separator
      final parts = formattedAmount.split('.');
      integerPart = parts[0];
      if (amount.contains('.') && parts.length > 1) {
        decimalPart = '.${amount.split('.')[1]}';
      }
    }
    
    // Try different font sizes starting from largest
    final fontSizes = [48.0, 40.0, 32.0, 24.0, 20.0, 16.0, 14.0, 12.0];
    
    for (final fontSize in fontSizes) {
      final decimalFontSize = fontSize * 0.75; // Decimal part is 75% of main font size
      
      // Calculate combined width of integer and decimal parts
      final integerWidth = _calculateTextWidth(
        integerPart,
        _getTextStyle(theme, fontSize, FontWeight.w700),
      );
      
      final decimalWidth = decimalPart.isNotEmpty ? _calculateTextWidth(
        decimalPart,
        _getTextStyle(theme, decimalFontSize, FontWeight.w500),
      ) : 0.0;
      
      final totalWidth = integerWidth + decimalWidth;
      
      if (totalWidth <= availableWidth) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              integerPart,
              style: _getTextStyle(theme, fontSize, FontWeight.w700),
            ),
            if (decimalPart.isNotEmpty)
              Text(
                decimalPart,
                style: _getTextStyle(theme, decimalFontSize, FontWeight.w500).copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        );
      }
    }
    
    // Fallback to smallest size if nothing fits
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          integerPart,
          style: _getTextStyle(theme, 10.0, FontWeight.w700),
        ),
        if (decimalPart.isNotEmpty)
          Text(
            decimalPart,
            style: _getTextStyle(theme, 8.0, FontWeight.w500).copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  double _calculateTextWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width;
  }

  TextStyle _getTextStyle(ThemeData theme, double fontSize, FontWeight fontWeight) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: theme.colorScheme.onSurface,
      fontFamily: 'Inter',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();

    return Consumer<ExpenseFormController>(
      builder: (context, controller, child) {
        // Update account picker visibility based on amount
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateAccountPickerVisibility(controller.amount);
        });

        return Column(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and Amount section moved to top left
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date display
                        GestureDetector(
                          onTap: () => _selectDate(context, controller),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  dateFormat.format(controller.selectedDate),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Amount display
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return SizedBox(
                              width: double.infinity,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: _buildDynamicAmountDisplay(
                                      theme, 
                                      controller.amount, 
                                      constraints.maxWidth - 48, // Account for padding + buffer
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            // Animated Account picker (positioned above the NumberPad)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: _isAccountPickerVisible && controller.selectedAccount != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Payment method label
                                Padding(
                                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                                  child: Text(
                                    'Payment method',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                // Account picker button
                                PickerButton(
                                  label: controller.selectedAccount!.name,
                                  icon: controller.selectedAccount!.icon,
                                  iconColor: controller.selectedAccount!.color,
                                  onTap: () => _showAccountPicker(context, controller),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                );
              },
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
                onDatePressed: () => _selectDate(context, controller),
                onSubmitPressed: widget.onNext ?? () {},
                submitButtonText: 'Next',
              ),
            ),
          ],
        );
      },
    );
  }
} 