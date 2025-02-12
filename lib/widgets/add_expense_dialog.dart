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
import 'add_category_sheet.dart';
import '../repositories/category_repository.dart';
import 'bottom_sheet.dart';

class AddExpenseDialog extends StatefulWidget {
  final bool isFixed;
  final CategoryRepository categoryRepo;
  final void Function(Expense expense) onExpenseAdded;

  const AddExpenseDialog({
    super.key,
    required this.isFixed,
    required this.categoryRepo,
    required this.onExpenseAdded,
  });

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  String _selectedAccountId = DefaultAccounts.checking.id;
  bool _isFixed = false;
  ExpenseCategory? _selectedCategoryInfo;
  final _dateFormat = DateFormat.yMMMd();

  @override
  void initState() {
    super.initState();
    _isFixed = widget.isFixed;
  }

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
      isFixed: widget.isFixed,
      accountId: _selectedAccountId,
    );

    widget.onExpenseAdded(expense);
    Navigator.pop(context);
  }

  void _addDigit(String digit) {
    setState(() {
      if (_amountController.text == '0') {
        _amountController.text = digit;
      } else {
        _amountController.text += digit;
      }
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
    if (!_amountController.text.contains('.')) {
      setState(() {
        _amountController.text += '.';
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedAccount = _selectedAccountId != null
        ? DefaultAccounts.defaultAccounts
            .firstWhere((account) => account.id == _selectedAccountId)
        : null;

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
                                _amountController.text == '0' ? '0.00' : _amountController.text,
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
                                  _selectedCategoryInfo?.name ?? 'Select Category',
                              icon: _selectedCategoryInfo?.icon,
                              onTap: _showCategoryPicker,
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
              color: theme.colorScheme.surface,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: _buildNumberPad(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    final theme = Theme.of(context);

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
