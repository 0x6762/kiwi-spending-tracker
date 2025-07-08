import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/expense.dart';
import '../../models/expense_category.dart';
import '../../models/account.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/account_repository.dart';
import '../common/app_bar.dart';
import '../../utils/icons.dart';
import '../../utils/formatters.dart';
import '../forms/number_pad.dart';
import '../forms/picker_button.dart';
import '../sheets/picker_sheet.dart';
import '../sheets/add_category_sheet.dart';
import 'package:intl/intl.dart';

class MultiStepExpenseDialog extends StatefulWidget {
  final ExpenseType type;
  final CategoryRepository categoryRepo;
  final AccountRepository accountRepo;
  final void Function(Expense expense) onExpenseAdded;
  final Expense? expense;

  const MultiStepExpenseDialog({
    super.key,
    required this.type,
    required this.categoryRepo,
    required this.accountRepo,
    required this.onExpenseAdded,
    this.expense,
  });

  @override
  State<MultiStepExpenseDialog> createState() => _MultiStepExpenseDialogState();
}

class _MultiStepExpenseDialogState extends State<MultiStepExpenseDialog> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Form data
  String _amount = '0';
  ExpenseCategory? _selectedCategory;
  Account? _selectedAccount;
  DateTime _selectedDate = DateTime.now();
  String _expenseName = '';
  String _selectedAccountId = DefaultAccounts.checking.id;
  bool _isFixedExpense = false;
  String _billingCycle = 'Monthly';

  @override
  void initState() {
    super.initState();
    _loadAccount(_selectedAccountId);
    _isFixedExpense = widget.type == ExpenseType.fixed;
    
    if (widget.expense != null) {
      _initializeFromExpense();
    }
  }

  Future<void> _initializeFromExpense() async {
    final expense = widget.expense!;
    _amount = expense.amount.toString();
    _selectedAccountId = expense.accountId;
    _expenseName = expense.title;
    _selectedDate = expense.date;
    _billingCycle = expense.billingCycle ?? 'Monthly';
    _isFixedExpense = expense.type == ExpenseType.fixed;
    
    await _loadCategory(expense.categoryId);
    await _loadAccount(expense.accountId);
  }

  Future<void> _loadCategory(String? categoryId) async {
    if (categoryId != null) {
      final category = await widget.categoryRepo.findCategoryById(categoryId);
      setState(() => _selectedCategory = category);
    }
  }

  Future<void> _loadAccount(String accountId) async {
    final account = await widget.accountRepo.findAccountById(accountId);
    setState(() => _selectedAccount = account);
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentStep = page;
    });
  }

  bool _canProceedFromStep(int step) {
    switch (step) {
      case 0: // Amount step
        return _amount != '0' && _amount.isNotEmpty;
      case 1: // Category step
        return _selectedCategory != null;
      case 2: // Details step
        return _selectedAccount != null;
      default:
        return false;
    }
  }

  void _submitExpense() async {
    if (!_canProceedFromStep(2)) return;

    final amount = double.parse(_amount);
    
    // Determine the expense type based on widget.type and _isFixedExpense
    ExpenseType expenseType;
    if (widget.type == ExpenseType.subscription) {
      expenseType = ExpenseType.subscription;
    } else {
      expenseType = _isFixedExpense ? ExpenseType.fixed : ExpenseType.variable;
    }
    
    // Determine necessity based on category
    ExpenseNecessity necessity = _determineNecessity();
    
    // Determine if recurring and frequency
    final bool isRecurring = expenseType == ExpenseType.subscription || expenseType == ExpenseType.fixed;
    final ExpenseFrequency frequency = expenseType == ExpenseType.subscription
        ? (_billingCycle == 'Monthly' ? ExpenseFrequency.monthly : ExpenseFrequency.yearly)
        : (expenseType == ExpenseType.fixed ? ExpenseFrequency.monthly : ExpenseFrequency.oneTime);

    // Calculate next billing date for recurring subscriptions
    DateTime? nextBillingDate;
    if (expenseType == ExpenseType.subscription) {
      if (_billingCycle == 'Monthly') {
        nextBillingDate = DateTime(
          _selectedDate.year, 
          _selectedDate.month + 1, 
          _selectedDate.day,
        );
      } else if (_billingCycle == 'Yearly') {
        nextBillingDate = DateTime(
          _selectedDate.year + 1, 
          _selectedDate.month, 
          _selectedDate.day,
        );
      }
    }
    
    final expense = Expense(
      id: widget.expense?.id ?? const Uuid().v4(),
      title: _expenseName.trim().isNotEmpty ? _expenseName.trim() : _selectedCategory!.name,
      amount: amount,
      date: _selectedDate,
      createdAt: widget.expense?.createdAt ?? DateTime.now(),
      categoryId: _selectedCategory!.id,
      notes: null,
      type: expenseType,
      accountId: _selectedAccountId,
      billingCycle: expenseType == ExpenseType.subscription ? _billingCycle : null,
      nextBillingDate: nextBillingDate,
      dueDate: null,
      necessity: necessity,
      isRecurring: isRecurring,
      frequency: frequency,
      status: ExpenseStatus.paid,
      variableAmount: null,
      endDate: null,
      budgetId: null,
      paymentMethod: null,
      tags: null,
    );

    widget.onExpenseAdded(expense);
    Navigator.pop(context);
  }

  ExpenseNecessity _determineNecessity() {
    if (_selectedCategory == null) return ExpenseNecessity.discretionary;
    
    final categoryName = _selectedCategory!.name.toLowerCase();
    if (categoryName.contains('groceries') ||
        categoryName.contains('utilities') ||
        categoryName.contains('rent') ||
        categoryName.contains('mortgage')) {
      return ExpenseNecessity.essential;
    } else if (categoryName.contains('savings') ||
               categoryName.contains('investment')) {
      return ExpenseNecessity.savings;
    } else {
      return ExpenseNecessity.discretionary;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
            title: _getStepTitle(),
            leading: _currentStep > 0 
                ? const Icon(AppIcons.back)
                : const Icon(AppIcons.close),
            onLeadingPressed: _currentStep > 0 ? _previousStep : () => Navigator.pop(context),
            actions: [
              // Step indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_currentStep + 1} of $_totalSteps',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _AmountStep(
                amount: _amount,
                onAmountChanged: (value) => setState(() => _amount = value),
                onNext: _canProceedFromStep(0) ? _nextStep : null,
                selectedDate: _selectedDate,
                onDateChanged: (date) => setState(() => _selectedDate = date),
              ),
              _CategoryStep(
                selectedCategory: _selectedCategory,
                categoryRepo: widget.categoryRepo,
                onCategorySelected: (category) => setState(() => _selectedCategory = category),
                onNext: _canProceedFromStep(1) ? _nextStep : null,
              ),
              _DetailsStep(
                selectedAccount: _selectedAccount,
                accountRepo: widget.accountRepo,
                expenseType: widget.type,
                isFixedExpense: _isFixedExpense,
                onFixedExpenseChanged: (value) => setState(() => _isFixedExpense = value),
                expenseName: _expenseName,
                onExpenseNameChanged: (value) => setState(() => _expenseName = value),
                billingCycle: _billingCycle,
                onBillingCycleChanged: (value) => setState(() => _billingCycle = value),
                onAccountSelected: (account) => setState(() {
                  _selectedAccount = account;
                  _selectedAccountId = account.id;
                }),
                onSubmit: _canProceedFromStep(2) ? _submitExpense : null,
                isEditMode: widget.expense != null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStepTitle() {
    final action = widget.expense != null ? 'Edit' : 'Add';
    switch (_currentStep) {
      case 0:
        return '$action Expense';
      case 1:
        return 'Select Category';
      case 2:
        return 'Expense Details';
      default:
        return '$action Expense';
    }
  }
}

// Step 1: Amount Input
class _AmountStep extends StatelessWidget {
  final String amount;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback? onNext;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const _AmountStep({
    required this.amount,
    required this.onAmountChanged,
    required this.onNext,
    required this.selectedDate,
    required this.onDateChanged,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();

    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Date display
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    dateFormat.format(selectedDate),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Amount display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formatCurrency(double.tryParse(amount) ?? 0).split('.')[0],
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (amount.contains('.'))
                      Text(
                        '.${amount.split('.')[1]}',
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
              String newAmount = amount;
              if (amount == '0') {
                newAmount = digit;
              } else {
                if (amount.contains('.')) {
                  final parts = amount.split('.');
                  if (parts.length > 1 && parts[1].length >= 2) {
                    return;
                  }
                }
                newAmount = amount + digit;
              }
              onAmountChanged(newAmount);
            },
            onDecimalPointPressed: () {
              if (!amount.contains('.')) {
                onAmountChanged(amount + '.');
              }
            },
            onDoubleZeroPressed: () {
              if (amount != '0') {
                onAmountChanged(amount + '00');
              }
            },
            onBackspacePressed: () {
              if (amount.isNotEmpty) {
                final newAmount = amount.substring(0, amount.length - 1);
                onAmountChanged(newAmount.isEmpty ? '0' : newAmount);
              }
            },
            onDatePressed: () => _selectDate(context),
            onSubmitPressed: onNext ?? () {},
            submitButtonText: 'Next',
          ),
        ),
      ],
    );
  }
}

// Step 2: Category Selection
class _CategoryStep extends StatelessWidget {
  final ExpenseCategory? selectedCategory;
  final CategoryRepository categoryRepo;
  final ValueChanged<ExpenseCategory> onCategorySelected;
  final VoidCallback? onNext;

  const _CategoryStep({
    required this.selectedCategory,
    required this.categoryRepo,
    required this.onCategorySelected,
    required this.onNext,
  });

  void _showCategoryPicker(BuildContext context) async {
    final repo = categoryRepo;
    
    // Ensure default categories are loaded
    await repo.loadCategories();
    
    // Get all categories and sort by name
    final categories = await repo.getAllCategories();
    categories.sort((a, b) => a.name.compareTo(b.name));

    if (!context.mounted) return;

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
                categoryRepo: categoryRepo,
                onCategoryAdded: () {
                  // Will refresh categories when picker is shown again
                },
              ),
            );
            // Show picker sheet again after category is added
            if (context.mounted) {
              _showCategoryPicker(context);
            }
          },
        ),
        const Divider(),
        ...categories.map(
          (category) => ListTile(
            leading: Icon(category.icon),
            title: Text(category.name),
            selected: selectedCategory?.id == category.id,
            onTap: () {
              onCategorySelected(category);
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Select Category button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 24),
                  child: PickerButton(
                    label: selectedCategory?.name ?? 'Select Category',
                    icon: selectedCategory?.icon ?? AppIcons.category,
                    onTap: () => _showCategoryPicker(context),
                  ),
                ),
                
                // Recently used categories
                FutureBuilder<List<ExpenseCategory>>(
                  future: _loadRecentCategories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }

                    final recentCategories = snapshot.data ?? [];
                    
                    if (recentCategories.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recently Used',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: recentCategories.length,
                          itemBuilder: (context, index) {
                            final category = recentCategories[index];
                            final isSelected = selectedCategory?.id == category.id;
                            
                            return Material(
                              color: isSelected 
                                  ? theme.colorScheme.primary.withOpacity(0.1)
                                  : theme.colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                onTap: () => onCategorySelected(category),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: isSelected
                                        ? Border.all(color: theme.colorScheme.primary, width: 2)
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          category.icon,
                                          color: theme.colorScheme.primary,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          category.name,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onSurface,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        // Next button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Next',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<List<ExpenseCategory>> _loadRecentCategories() async {
    try {
      // For now, we'll load all categories and return the first 6 as "recent"
      // In a real implementation, you'd track usage and sort by most recent
      await categoryRepo.loadCategories();
      final categories = await categoryRepo.getAllCategories();
      
      // Return up to 6 categories as recent ones
      return categories.take(6).toList();
    } catch (e) {
      return [];
    }
  }
}

// Step 3: Details (Account, Type, Name)
class _DetailsStep extends StatelessWidget {
  final Account? selectedAccount;
  final AccountRepository accountRepo;
  final ExpenseType expenseType;
  final bool isFixedExpense;
  final ValueChanged<bool> onFixedExpenseChanged;
  final String expenseName;
  final ValueChanged<String> onExpenseNameChanged;
  final String billingCycle;
  final ValueChanged<String> onBillingCycleChanged;
  final ValueChanged<Account> onAccountSelected;
  final VoidCallback? onSubmit;
  final bool isEditMode;

  const _DetailsStep({
    required this.selectedAccount,
    required this.accountRepo,
    required this.expenseType,
    required this.isFixedExpense,
    required this.onFixedExpenseChanged,
    required this.expenseName,
    required this.onExpenseNameChanged,
    required this.billingCycle,
    required this.onBillingCycleChanged,
    required this.onAccountSelected,
    required this.onSubmit,
    required this.isEditMode,
  });

  void _showAccountPicker(BuildContext context) async {
    await accountRepo.loadAccounts();
    final accounts = await accountRepo.getAllAccounts();
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
          selected: selectedAccount?.id == account.id,
          onTap: () {
            onAccountSelected(account);
            Navigator.pop(context);
          },
        ),
      ).toList(),
    );
  }

  void _showExpenseTypePicker(BuildContext context) {
    PickerSheet.show(
      context: context,
      title: 'Expense Type',
      children: [
        ListTile(
          title: const Text('Variable'),
          selected: !isFixedExpense,
          onTap: () {
            onFixedExpenseChanged(false);
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('Fixed'),
          selected: isFixedExpense,
          onTap: () {
            onFixedExpenseChanged(true);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void _showBillingCyclePicker(BuildContext context) {
    PickerSheet.show(
      context: context,
      title: 'Billing Cycle',
      children: ['Monthly', 'Yearly'].map(
        (cycle) => ListTile(
          title: Text(cycle),
          selected: billingCycle == cycle,
          onTap: () {
            onBillingCycleChanged(cycle);
            Navigator.pop(context);
          },
        ),
      ).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Expense name
                TextFormField(
                  initialValue: expenseName,
                  onChanged: onExpenseNameChanged,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Expense name (optional)',
                    hintStyle: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Account picker
                if (selectedAccount != null)
                  PickerButton(
                    label: selectedAccount!.name,
                    icon: selectedAccount!.icon,
                    iconColor: selectedAccount!.color,
                    onTap: () => _showAccountPicker(context),
                  ),
                const SizedBox(height: 12),
                
                // Expense type picker (if not subscription)
                if (expenseType != ExpenseType.subscription)
                  PickerButton(
                    label: isFixedExpense ? 'Fixed' : 'Variable',
                    icon: AppIcons.category,
                    onTap: () => _showExpenseTypePicker(context),
                  ),
                const SizedBox(height: 12),
                
                // Billing cycle picker (if subscription)
                if (expenseType == ExpenseType.subscription)
                  PickerButton(
                    label: billingCycle,
                    icon: AppIcons.calendar,
                    onTap: () => _showBillingCyclePicker(context),
                  ),
              ],
            ),
          ),
        ),
        // Submit button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              isEditMode ? 'Update' : 'Add Expense',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
} 