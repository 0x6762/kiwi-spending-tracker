import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/account.dart';
import 'package:intl/intl.dart';
import 'picker_button.dart';
import 'picker_sheet.dart';
import 'add_category_sheet.dart';
import '../repositories/category_repository.dart';
import 'dart:math' as math;

class AddExpenseDialog extends StatefulWidget {
  final ExpenseType type;
  final CategoryRepository categoryRepo;
  final void Function(Expense expense) onExpenseAdded;

  const AddExpenseDialog({
    super.key,
    required this.type,
    required this.categoryRepo,
    required this.onExpenseAdded,
  });

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController(text: '0');
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  String _selectedAccountId = DefaultAccounts.checking.id;
  ExpenseCategory? _selectedCategoryInfo;
  final _dateFormat = DateFormat.yMMMd();
  
  // New state variables for type-specific fields
  String _billingCycle = 'Monthly'; // For subscriptions
  DateTime _nextBillingDate = DateTime.now(); // For subscriptions
  DateTime _dueDate = DateTime.now(); // For fixed expenses

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateSelectedCategoryInfo() async {
    if (_selectedCategory != null) {
      final repo = widget.categoryRepo;
      final category = await repo.findCategoryByName(_selectedCategory!);
      setState(() {
        _selectedCategoryInfo = category;
      });
    } else {
      setState(() {
        _selectedCategoryInfo = null;
      });
    }
  }

  void _showCategoryPicker() async {
    final repo = widget.categoryRepo;
    final categories = await repo.getAllCategories();
    categories.sort((a, b) => a.name.compareTo(b.name));

    if (!mounted) return;

    PickerSheet.show(
      context: context,
      title: 'Select Category',
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(
            'Create Category',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () async {
            Navigator.pop(context); // Close picker sheet
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => AddCategorySheet(
                categoryRepo: widget.categoryRepo,
                onCategoryAdded: () {
                  // Will refresh categories when picker is shown again
                },
              ),
            );
            // Show picker sheet again after category is added
            if (mounted) {
              _showCategoryPicker();
            }
          },
        ),
        ...categories.map(
          (category) => ListTile(
            leading: Icon(category.icon),
            title: Text(category.name),
            selected: _selectedCategoryInfo?.id == category.id,
            onTap: () {
              setState(() => _selectedCategoryInfo = category);
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_selectedCategoryInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    if (_amountController.text == '0') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    final amount = double.parse(_amountController.text);
    final expense = Expense(
      id: const Uuid().v4(),
      title: _titleController.text.trim().isNotEmpty 
        ? _titleController.text.trim()
        : _selectedCategoryInfo!.name,
      amount: amount,
      date: _selectedDate,
      createdAt: DateTime.now(),
      categoryId: _selectedCategoryInfo!.id,
      notes: _notesController.text.trim(),
      type: widget.type,
      accountId: _selectedAccountId,
      // Add new fields based on type
      billingCycle: widget.type == ExpenseType.subscription ? _billingCycle : null,
      nextBillingDate: widget.type == ExpenseType.subscription ? _nextBillingDate : null,
      dueDate: widget.type == ExpenseType.fixed ? _dueDate : null,
    );

    widget.onExpenseAdded(expense);
    Navigator.pop(context);
  }

  void _addDigit(String digit) {
    setState(() {
      final currentText = _amountController.text;
      
      // If current text is '0' and no decimal point, replace the 0
      if (currentText == '0' && !currentText.contains('.')) {
        _amountController.text = digit;
        return;
      }

      // If we have a decimal point, check number of decimal places
      if (currentText.contains('.')) {
        final decimalPlaces = currentText.split('.')[1].length;
        if (decimalPlaces >= 2) return; // Limit to 2 decimal places
      }

      _amountController.text += digit;
    });
  }

  void _addDoubleZero() {
    setState(() {
      if (_amountController.text != '0') {
        _amountController.text += '00';
      }
    });
  }

  void _addDecimalPoint() {
    setState(() {
      if (!_amountController.text.contains('.')) {
        _amountController.text += '.';
      }
    });
  }

  void _deleteDigit() {
    setState(() {
      if (_amountController.text.length > 1) {
        _amountController.text = _amountController.text.substring(0, _amountController.text.length - 1);
      } else {
        _amountController.text = '0';
      }
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getDialogTitle() {
    switch (widget.type) {
      case ExpenseType.subscription:
        return 'Add Subscription';
      case ExpenseType.fixed:
        return 'Add Fixed Expense';
      case ExpenseType.variable:
        return 'Add Variable Expense';
    }
  }

  Widget _buildTypeSpecificFields() {
    final theme = Theme.of(context);
    
    switch (widget.type) {
      case ExpenseType.subscription:
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: PickerButton(
                      label: _billingCycle,
                      icon: Icons.calendar_view_month,
                      onTap: () {
                        PickerSheet.show(
                          context: context,
                          title: 'Billing Cycle',
                          children: ['Monthly', 'Yearly'].map(
                            (cycle) => ListTile(
                              title: Text(cycle),
                              selected: _billingCycle == cycle,
                              onTap: () {
                                setState(() => _billingCycle = cycle);
                                Navigator.pop(context);
                              },
                            ),
                          ).toList(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: PickerButton(
                      label: _dateFormat.format(_nextBillingDate),
                      icon: Icons.event_repeat,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _nextBillingDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _nextBillingDate = picked);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      
      case ExpenseType.fixed:
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PickerButton(
                label: _dateFormat.format(_dueDate),
                icon: Icons.event,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _dueDate = picked);
                  }
                },
              ),
            ),
          ],
        );
      
      case ExpenseType.variable:
        return const SizedBox.shrink(); // No additional fields needed
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedAccount = DefaultAccounts.defaultAccounts
        .firstWhere((a) => a.id == _selectedAccountId);

    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: theme.colorScheme.surface,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.surface,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              _getDialogTitle(),
              style: theme.textTheme.titleSmall,
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Text(
                                    '\$',
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatAmount(_amountController.text),
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _dateFormat.format(_selectedDate),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: theme.colorScheme.surface,
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: TextFormField(
                            controller: _titleController,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Expense Name',
                              hintStyle: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: PickerButton(
                                label: selectedAccount.name,
                                icon: selectedAccount.icon,
                                iconColor: selectedAccount.color,
                                onTap: () {
                                  PickerSheet.show(
                                    context: context,
                                    title: 'Select Account',
                                    children: DefaultAccounts.defaultAccounts
                                        .map(
                                          (account) => ListTile(
                                            leading: Icon(account.icon, color: account.color),
                                            title: Text(account.name),
                                            selected: _selectedAccountId == account.id,
                                            onTap: () {
                                              setState(() => _selectedAccountId = account.id);
                                              Navigator.pop(context);
                                            },
                                          ),
                                        )
                                        .toList(),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: PickerButton(
                                label: _selectedCategoryInfo?.name ?? 'Select Category',
                                icon: _selectedCategoryInfo?.icon,
                                onTap: _showCategoryPicker,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildTypeSpecificFields(),
                    ],
                  ),
                ),
              ),
              Container(
                color: theme.colorScheme.surface,
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                child: _buildNumberPad(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: _buildNumberPadButton('1', onPressed: () => _addDigit('1'))),
            Expanded(child: _buildNumberPadButton('2', onPressed: () => _addDigit('2'))),
            Expanded(child: _buildNumberPadButton('3', onPressed: () => _addDigit('3'))),
            Expanded(
              child: _buildNumberPadButton(
                'backspace',
                onPressed: _deleteDigit,
                isAction: true,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildNumberPadButton('4', onPressed: () => _addDigit('4'))),
            Expanded(child: _buildNumberPadButton('5', onPressed: () => _addDigit('5'))),
            Expanded(child: _buildNumberPadButton('6', onPressed: () => _addDigit('6'))),
            Expanded(
              child: _buildNumberPadButton(
                'date',
                onPressed: _selectDate,
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
                      Expanded(child: _buildNumberPadButton('7', onPressed: () => _addDigit('7'))),
                      Expanded(child: _buildNumberPadButton('8', onPressed: () => _addDigit('8'))),
                      Expanded(child: _buildNumberPadButton('9', onPressed: () => _addDigit('9'))),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildNumberPadButton('.', onPressed: _addDecimalPoint)),
                      Expanded(child: _buildNumberPadButton('0', onPressed: () => _addDigit('0'))),
                      Expanded(child: _buildNumberPadButton('00', onPressed: _addDoubleZero)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildNumberPadButton(
                'save',
                onPressed: _submit,
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
    String text, {
    VoidCallback? onPressed,
    bool isAction = false,
    bool isLarge = false,
  }) {
    final theme = Theme.of(context);
    return AspectRatio(
      aspectRatio: isLarge ? 0.6 : 1.2,
      child: Padding(
        padding: const EdgeInsets.all(3),
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
              child: _buildButtonContent(text, isAction, theme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(String text, bool isAction, ThemeData theme) {
    switch (text) {
      case 'backspace':
        return Icon(
          Icons.backspace_outlined,
          color: theme.colorScheme.onSurface,
          size: 24,
        );
      case 'date':
        return Icon(
          Icons.calendar_today,
          color: theme.colorScheme.primary,
          size: 24,
        );
      case 'save':
        return Text(
          'Add',
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

  String _formatAmount(String amount) {
    if (amount == '0') return '0';
    if (amount.contains('.')) {
      final parts = amount.split('.');
      if (parts[1].isEmpty) return amount; // Just show the decimal point
      return parts[0] + '.' + parts[1].substring(0, math.min(parts[1].length, 2)); // Limit to 2 decimal places
    }
    return amount;
  }
}
