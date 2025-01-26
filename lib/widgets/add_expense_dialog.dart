import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/account.dart';
import 'package:intl/intl.dart';
import '../utils/formatters.dart';
import 'picker_button.dart';
import 'picker_sheet.dart';

class AddExpenseDialog extends StatefulWidget {
  final bool isFixed;

  const AddExpenseDialog({
    super.key,
    required this.isFixed,
  });

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _amount = '0';
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  String? _selectedAccountId;
  final _dateFormat = DateFormat.yMMMd();

  void _addDigit(String digit) {
    setState(() {
      if (_amount == '0') {
        _amount = digit;
      } else {
        _amount += digit;
      }
    });
  }

  void _addDoubleZero() {
    setState(() {
      if (_amount != '0') {
        _amount += '00';
      }
    });
  }

  void _addDecimalPoint() {
    if (!_amount.contains('.')) {
      setState(() {
        _amount += '.';
      });
    }
  }

  void _deleteDigit() {
    setState(() {
      if (_amount.length > 1) {
        _amount = _amount.substring(0, _amount.length - 1);
      } else {
        _amount = '0';
      }
    });
  }

  void _submit() async {
    final hasTitle = _titleController.text.trim().isNotEmpty;
    final hasAccount = _selectedAccountId != null;
    final hasAmount = _amount != '0';

    if (!hasTitle) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an expense name'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!hasAccount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an account'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!hasAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Format amount to have two decimal places if needed
    double amount;
    if (_amount.contains('.')) {
      amount = double.parse(_amount);
    } else {
      amount = double.parse('$_amount.00');
    }

    final expense = Expense(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      amount: amount,
      date: _selectedDate,
      category: _selectedCategory?.trim() ?? 'Uncategorized',
      isFixed: widget.isFixed,
      accountId: _selectedAccountId!,
      createdAt: DateTime.now(),
    );

    Navigator.of(context).pop(expense);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedAccount = _selectedAccountId != null
        ? DefaultAccounts.defaultAccounts
            .firstWhere((account) => account.id == _selectedAccountId)
        : null;
    ExpenseCategory? selectedCategory;
    if (_selectedCategory != null) {
      selectedCategory = ExpenseCategories.findByName(_selectedCategory!);
      if (selectedCategory == null) {
        // If category not found, clear the selection
        _selectedCategory = null;
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.colorScheme.surface,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          widget.isFixed ? 'Add Fixed Expense' : 'Add Variable Expense',
          style: theme.textTheme.titleMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 56, 16, 56),
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
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              Text(
                                _amount == '0' ? '0.00' : _amount,
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
                            hintText: 'What was the expense?',
                            hintStyle: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8),
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
                              label: selectedAccount?.name ?? 'Select Account',
                              icon: selectedAccount?.icon,
                              iconColor: selectedAccount?.color,
                              onTap: () {
                                PickerSheet.show(
                                  context: context,
                                  title: 'Select Account',
                                  children: DefaultAccounts.defaultAccounts
                                      .map(
                                        (account) => ListTile(
                                          leading: Icon(account.icon,
                                              color: account.color),
                                          title: Text(account.name),
                                          selected:
                                              _selectedAccountId == account.id,
                                          onTap: () {
                                            setState(() => _selectedAccountId =
                                                account.id);
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
                              label:
                                  selectedCategory?.name ?? 'Select Category',
                              icon: selectedCategory?.icon,
                              onTap: () {
                                PickerSheet.show(
                                  context: context,
                                  title: 'Select Category',
                                  children: ExpenseCategories.values
                                      .map(
                                        (category) => ListTile(
                                          leading: Icon(category.icon),
                                          title: Text(category.name),
                                          selected: _selectedCategory ==
                                              category.name,
                                          onTap: () {
                                            setState(() => _selectedCategory =
                                                category.name);
                                            Navigator.pop(context);
                                          },
                                        ),
                                      )
                                      .toList(),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: theme.colorScheme.surface, //Number pad background
              padding:
                  const EdgeInsets.fromLTRB(16, 0, 16, 32), //Number pad padding
              child: _buildNumberPad(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    final theme = Theme.of(context);
    final selectedCategory = _selectedCategory != null
        ? ExpenseCategories.findByName(_selectedCategory!)
        : null;
    final selectedAccount = _selectedAccountId != null
        ? DefaultAccounts.defaultAccounts
            .firstWhere((account) => account.id == _selectedAccountId)
        : null;

    return Column(
      children: [
        Row(
          children: [
            _buildNumberPadButton('1', onPressed: () => _addDigit('1')),
            _buildNumberPadButton('2', onPressed: () => _addDigit('2')),
            _buildNumberPadButton('3', onPressed: () => _addDigit('3')),
            _buildNumberPadButton(
              'backspace',
              onPressed: _deleteDigit,
              isAction: true,
            ),
          ],
        ),
        Row(
          children: [
            _buildNumberPadButton('4', onPressed: () => _addDigit('4')),
            _buildNumberPadButton('5', onPressed: () => _addDigit('5')),
            _buildNumberPadButton('6', onPressed: () => _addDigit('6')),
            _buildNumberPadButton(
              'date',
              onPressed: _selectDate,
              isAction: true,
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildNumberPadButton('7',
                          onPressed: () => _addDigit('7')),
                      _buildNumberPadButton('8',
                          onPressed: () => _addDigit('8')),
                      _buildNumberPadButton('9',
                          onPressed: () => _addDigit('9')),
                    ],
                  ),
                  Row(
                    children: [
                      _buildNumberPadButton('.', onPressed: _addDecimalPoint),
                      _buildNumberPadButton('0',
                          onPressed: () => _addDigit('0')),
                      _buildNumberPadButton('00', onPressed: _addDoubleZero),
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
    return Expanded(
      flex: 1,
      child: AspectRatio(
        aspectRatio: isLarge ? 0.5 : 1,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Material(
            color: text == 'save'
                ? theme.colorScheme.primary
                : text == 'date'
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(24),
              child: Center(
                child: _buildButtonContent(text, isAction, theme),
              ),
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
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w800,
          ),
        );
      default:
        return Text(
          text,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        );
    }
  }
}
