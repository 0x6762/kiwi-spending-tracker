import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uuid/uuid.dart';
import '../../models/expense.dart';
import '../../models/expense_category.dart';
import '../../models/account.dart';
import 'package:intl/intl.dart';
import '../forms/picker_button.dart';
import '../sheets/picker_sheet.dart';
import '../sheets/add_category_sheet.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/account_repository.dart';
import '../common/app_bar.dart';
import '../../utils/icons.dart';
import 'dart:math' as math;
import '../forms/expense_form_fields.dart';
import '../forms/number_pad.dart';

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
  bool _isFixedExpense = false; // State variable for fixed expense checkbox

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      // Initialize form with existing expense data
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
      _notesController.text = widget.expense!.notes ?? '';
      
      // Use the due date if available, otherwise use the expense date
      if (widget.expense!.type == ExpenseType.fixed && widget.expense!.dueDate != null) {
        _selectedDate = widget.expense!.dueDate!;
      } else if (widget.expense!.type == ExpenseType.subscription && widget.expense!.nextBillingDate != null) {
        _selectedDate = widget.expense!.nextBillingDate!;
      } else {
        _selectedDate = widget.expense!.date;
      }
      
      _selectedAccountId = widget.expense!.accountId;
      _billingCycle = widget.expense!.billingCycle ?? 'Monthly';
      _isFixedExpense = widget.expense!.type == ExpenseType.fixed;
      
      // Load category and account
      _loadCategory(widget.expense!.categoryId);
      _loadAccount(widget.expense!.accountId);
    } else {
      // For new expenses, initialize with default values
      _amountController.text = '0'; // Will be cleared on tap
      
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

  void _showBillingCyclePicker() {
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
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

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

      // Always set status to paid, regardless of date
      final ExpenseStatus status = ExpenseStatus.paid;
      
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
        nextBillingDate: null,
        dueDate: null,
        // Add new fields
        necessity: necessity,
        isRecurring: isRecurring,
        frequency: frequency,
        status: status,
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

  void _onFixedExpenseChanged(bool value) {
    // Define the colors for expense types
    final fixedExpenseColor = const Color(0xFFCF5825); // Orange
    final variableExpenseColor = const Color(0xFF8056E4); // Purple
    
    // Instead of directly setting the value, show a picker sheet
    PickerSheet.show(
      context: context,
      title: 'Expense Type',
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: variableExpenseColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(
              'assets/icons/variable_expense.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                variableExpenseColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          title: const Text('Variable'),
          selected: !_isFixedExpense,
          onTap: () {
            setState(() => _isFixedExpense = false);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: fixedExpenseColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(
              'assets/icons/fixed_expense.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                fixedExpenseColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          title: const Text('Fixed'),
          selected: _isFixedExpense,
          onTap: () {
            setState(() => _isFixedExpense = true);
            Navigator.pop(context);
          },
        ),
      ],
    );
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
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                      top: 8.0,
                      bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 200 : 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date selector - simplified and moved to the top
                        GestureDetector(
                          onTap: _selectDate,
                          child: Row(
                            children: [
                              Text(
                                _dateFormat.format(_selectedDate),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 18,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Amount field - removed label and modified styling
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          decoration: InputDecoration(
                            prefixText: '\$ ',
                            prefixStyle: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                            filled: false,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.left,
                          readOnly: true, // Make it read-only since we're using the number pad
                          onTap: () {
                            // No need to clear on tap since we're using the number pad
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty || value == '0') {
                              return 'Please enter an amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Form fields (simplified to remove duplicate date fields)
                        ExpenseFormFields(
                          titleController: _titleController,
                          selectedCategory: _selectedCategoryInfo,
                          selectedAccount: _selectedAccount,
                          isFixedExpense: _isFixedExpense,
                          expenseType: widget.type,
                          onCategoryTap: _showCategoryPicker,
                          onAccountTap: _showAccountPicker,
                          onExpenseTypeChanged: _onFixedExpenseChanged,
                          // We're not using these date-related fields anymore
                          dueDate: _selectedDate,
                          onDueDateTap: _selectDate, // Just in case the component still needs this
                          billingCycle: _billingCycle,
                          onBillingCycleTap: _showBillingCyclePicker,
                          nextBillingDate: _selectedDate,
                          onNextBillingDateTap: _selectDate, // Just in case the component still needs this
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Custom number pad - now in a container with a fixed position at the bottom
                Container(
                  color: theme.colorScheme.surface,
                  child: NumberPad(
                    onDigitPressed: (digit) {
                      setState(() {
                        // If the current value is 0, replace it with the new digit
                        if (_amountController.text == '0') {
                          _amountController.text = digit;
                        } else {
                          // Check if we already have two decimal places
                          if (_amountController.text.contains('.')) {
                            final parts = _amountController.text.split('.');
                            if (parts.length > 1 && parts[1].length >= 2) {
                              // Already have two decimal places, don't add more digits
                              return;
                            }
                          }
                          _amountController.text += digit;
                        }
                      });
                    },
                    onDecimalPointPressed: () {
                      setState(() {
                        // Only add decimal point if it doesn't already contain one
                        if (!_amountController.text.contains('.')) {
                          _amountController.text += '.';
                        }
                      });
                    },
                    onDoubleZeroPressed: () {
                      setState(() {
                        // Only add 00 if the current value is not 0
                        if (_amountController.text != '0') {
                          _amountController.text += '00';
                        }
                      });
                    },
                    onBackspacePressed: () {
                      setState(() {
                        if (_amountController.text.isNotEmpty) {
                          _amountController.text = _amountController.text.substring(0, _amountController.text.length - 1);
                          // If we deleted everything, set it back to 0
                          if (_amountController.text.isEmpty) {
                            _amountController.text = '0';
                          }
                        }
                      });
                    },
                    onDatePressed: _selectDate,
                    onSubmitPressed: _submit,
                    submitButtonText: widget.expense != null ? 'Update' : 'Add',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
