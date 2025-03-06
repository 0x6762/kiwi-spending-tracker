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
import '../repositories/account_repository.dart';
import '../widgets/app_bar.dart';
import '../utils/icons.dart';
import 'dart:math' as math;
import 'number_pad.dart';

class AddExpenseDialog extends StatefulWidget {
  final ExpenseType type;
  final CategoryRepository categoryRepo;
  final AccountRepository accountRepo;
  final void Function(Expense expense) onExpenseAdded;
  final Expense? expense;

  const AddExpenseDialog({
    super.key,
    required this.type,
    required this.categoryRepo,
    required this.accountRepo,
    required this.onExpenseAdded,
    this.expense,
  });

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController(text: '0');
  final _notesController = TextEditingController();
  final _scrollController = ScrollController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  String _selectedAccountId = DefaultAccounts.checking.id;
  Account? _selectedAccount;
  ExpenseCategory? _selectedCategoryInfo;
  final _dateFormat = DateFormat.yMMMd();
  
  // New state variables for type-specific fields
  String _billingCycle = 'Monthly'; // For subscriptions
  DateTime _nextBillingDate = DateTime.now(); // For subscriptions
  DateTime _dueDate = DateTime.now(); // For fixed expenses
  bool _isFixedExpense = false; // New state variable for fixed expense checkbox

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      // Initialize form with existing expense data
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
      _notesController.text = widget.expense!.notes ?? '';
      _selectedDate = widget.expense!.date;
      _selectedAccountId = widget.expense!.accountId;
      _billingCycle = widget.expense!.billingCycle ?? 'Monthly';
      _nextBillingDate = widget.expense!.nextBillingDate ?? DateTime.now();
      _dueDate = widget.expense!.dueDate ?? DateTime.now();
      _isFixedExpense = widget.expense!.type == ExpenseType.fixed; // Initialize checkbox state
      
      // Load category and account
      _loadCategory(widget.expense!.categoryId);
      _loadAccount(widget.expense!.accountId);
    } else {
      // Load default account
      _loadAccount(_selectedAccountId);
      // Initialize fixed expense checkbox based on the provided type
      _isFixedExpense = widget.type == ExpenseType.fixed;
    }
  }

  Future<void> _loadCategory(String? categoryId) async {
    if (categoryId != null) {
      final category = await widget.categoryRepo.findCategoryById(categoryId);
      setState(() => _selectedCategoryInfo = category);
    }
  }

  Future<void> _loadAccount(String accountId) async {
    final account = await widget.accountRepo.findAccountById(accountId);
    setState(() => _selectedAccount = account);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
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
    
    // Ensure default categories are loaded
    await repo.loadCategories();
    
    // Get all categories and sort by name
    final categories = await repo.getAllCategories();
    categories.sort((a, b) => a.name.compareTo(b.name));

    if (!mounted) return;

    PickerSheet.show(
      context: context,
      title: 'Select Category',
      children: [
        // Add Category button
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              AppIcons.add,
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
        const Divider(),
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

  void _showAccountPicker() async {
    // Ensure accounts are loaded
    await widget.accountRepo.loadAccounts();
    
    // Get all accounts and sort by name
    final accounts = await widget.accountRepo.getAllAccounts();
    accounts.sort((a, b) {
      // First sort by default status (default accounts first)
      if (a.isDefault != b.isDefault) {
        return a.isDefault ? -1 : 1;
      }
      // Then sort by name
      return a.name.compareTo(b.name);
    });

    if (!mounted) return;

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
          selected: _selectedAccountId == account.id,
          onTap: () {
            setState(() {
              _selectedAccountId = account.id;
              _selectedAccount = account;
            });
            Navigator.pop(context);
          },
        ),
      ).toList(),
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
    
    // Determine the expense type based on widget.type and _isFixedExpense
    ExpenseType expenseType;
    if (widget.type == ExpenseType.subscription) {
      expenseType = ExpenseType.subscription;
    } else {
      expenseType = _isFixedExpense ? ExpenseType.fixed : ExpenseType.variable;
    }
    
    // Determine necessity based on category (this is a simple implementation)
    // In a real app, you might want to let the user choose or have a more sophisticated algorithm
    ExpenseNecessity necessity;
    if (_selectedCategoryInfo!.name.toLowerCase().contains('groceries') ||
        _selectedCategoryInfo!.name.toLowerCase().contains('utilities') ||
        _selectedCategoryInfo!.name.toLowerCase().contains('rent') ||
        _selectedCategoryInfo!.name.toLowerCase().contains('mortgage')) {
      necessity = ExpenseNecessity.essential;
    } else if (_selectedCategoryInfo!.name.toLowerCase().contains('savings') ||
               _selectedCategoryInfo!.name.toLowerCase().contains('investment')) {
      necessity = ExpenseNecessity.savings;
    } else {
      necessity = ExpenseNecessity.discretionary;
    }
    
    // Determine if recurring and frequency
    final bool isRecurring = expenseType == ExpenseType.subscription || expenseType == ExpenseType.fixed;
    final ExpenseFrequency frequency = expenseType == ExpenseType.subscription
        ? (_billingCycle == 'Monthly' ? ExpenseFrequency.monthly : ExpenseFrequency.yearly)
        : (expenseType == ExpenseType.fixed ? ExpenseFrequency.monthly : ExpenseFrequency.oneTime);
    
    final expense = Expense(
      id: widget.expense?.id ?? const Uuid().v4(),
      title: _titleController.text.trim().isNotEmpty 
        ? _titleController.text.trim()
        : _selectedCategoryInfo!.name,
      amount: amount,
      date: _selectedDate,
      createdAt: widget.expense?.createdAt ?? DateTime.now(),
      categoryId: _selectedCategoryInfo!.id,
      notes: _notesController.text.trim(),
      type: expenseType,
      accountId: _selectedAccountId,
      billingCycle: expenseType == ExpenseType.subscription ? _billingCycle : null,
      nextBillingDate: expenseType == ExpenseType.subscription ? _nextBillingDate : null,
      dueDate: expenseType == ExpenseType.fixed ? _dueDate : null,
      // Add new fields
      necessity: necessity,
      isRecurring: isRecurring,
      frequency: frequency,
      status: ExpenseStatus.paid, // Default to paid
      // These fields could be added in a more advanced UI
      variableAmount: null,
      endDate: null,
      budgetId: null,
      paymentMethod: null,
      tags: null,
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
    final action = widget.expense != null ? 'Edit' : 'Add';
    if (widget.type == ExpenseType.subscription) {
      return '$action Subscription';
    } else {
      // For variable and fixed expenses, use the checkbox state
      return '$action Expense';
    }
  }

  Widget _buildTypeSpecificFields() {
    final theme = Theme.of(context);
    
    if (widget.type == ExpenseType.subscription) {
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
                    icon: AppIcons.calendar,
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
                    icon: AppIcons.calendar,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _nextBillingDate,
                        firstDate: DateTime(2000),
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
    } else {
      // For both variable and fixed expenses
      return Column(
        children: [
          if (_isFixedExpense) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PickerButton(
                label: _dateFormat.format(_dueDate),
                icon: AppIcons.calendar,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _dueDate = picked);
                  }
                },
              ),
            ),
          ],
        ],
      );
    }
  }

  void _onFixedExpenseChanged(bool? value) {
    setState(() {
      _isFixedExpense = value ?? false;
    });
    
    if (_isFixedExpense) {
      // Wait for the setState to complete and the new field to be added
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: theme.colorScheme.surface,
          resizeToAvoidBottomInset: false,
          appBar: KiwiAppBar(
            backgroundColor: theme.colorScheme.surface,
            title: _getDialogTitle(),
            leading: const Icon(AppIcons.close),
            onLeadingPressed: () => Navigator.pop(context),
          ),
          body: Column(
            children: [
              Container(
                color: theme.colorScheme.surface,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dateFormat.format(_selectedDate),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
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
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      Container(
                        color: theme.colorScheme.surface,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              alignment: Alignment.topLeft,
                              child: TextFormField(
                                controller: _titleController,
                                textAlign: TextAlign.start,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Type expense name',
                                  hintStyle: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  filled: true,
                                  fillColor: theme.colorScheme.surfaceContainer,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.surfaceContainerLowest,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.error,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_selectedAccount != null) PickerButton(
                              label: _selectedAccount!.name,
                              icon: _selectedAccount!.icon,
                              iconColor: _selectedAccount!.color,
                              onTap: _showAccountPicker,
                            ),
                            const SizedBox(height: 8),
                            PickerButton(
                              label: _selectedCategoryInfo?.name ?? 'Select Category',
                              icon: _selectedCategoryInfo?.icon ?? AppIcons.category,
                              onTap: _showCategoryPicker,
                            ),
                            
                            // Add Fixed Expense checkbox if not subscription
                            if (widget.type != ExpenseType.subscription) ...[
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () {
                                  _onFixedExpenseChanged(!_isFixedExpense);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: _isFixedExpense,
                                            onChanged: _onFixedExpenseChanged,
                                            activeColor: theme.colorScheme.primary,
                                          ),
                                          Text(
                                            'Fixed expense?',
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            
                            // Show due date field if fixed expense is checked
                            if (widget.type != ExpenseType.subscription && _isFixedExpense) ...[
                              const SizedBox(height: 24),
                              Text(
                                'Due Date',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              PickerButton(
                                label: _dateFormat.format(_dueDate),
                                icon: AppIcons.calendar,
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: _dueDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() => _dueDate = picked);
                                  }
                                },
                              ),
                            ],
                            
                            if (widget.type == ExpenseType.subscription) ...[
                              const SizedBox(height: 24),
                              Text(
                                'Billing Cycle / Due Date',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 16),
                              PickerButton(
                                label: _billingCycle,
                                icon: AppIcons.calendar,
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
                              const SizedBox(height: 8),
                              PickerButton(
                                label: _dateFormat.format(_nextBillingDate),
                                icon: AppIcons.calendar,
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: _nextBillingDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() => _nextBillingDate = picked);
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: theme.colorScheme.surface,
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                child: NumberPad(
                  onDigitPressed: _addDigit,
                  onDecimalPointPressed: _addDecimalPoint,
                  onDoubleZeroPressed: _addDoubleZero,
                  onBackspacePressed: _deleteDigit,
                  onDatePressed: _selectDate,
                  onSubmitPressed: _submit,
                  submitButtonText: widget.expense != null ? 'Update' : 'Add',
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
