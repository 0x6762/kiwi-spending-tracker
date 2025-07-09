import 'package:flutter/material.dart';
import '../../../../models/expense.dart';
import '../../../../models/expense_category.dart';
import '../../../../models/account.dart';
import '../../../../repositories/category_repository.dart';
import '../../../../repositories/account_repository.dart';
import 'package:uuid/uuid.dart';

class ExpenseFormController extends ChangeNotifier {
  final CategoryRepository categoryRepo;
  final AccountRepository accountRepo;
  final ExpenseType initialType;
  final Expense? initialExpense;

  // Form state
  String _amount = '0';
  ExpenseCategory? _selectedCategory;
  Account? _selectedAccount;
  DateTime _selectedDate = DateTime.now();
  String _expenseName = '';
  String _selectedAccountId = DefaultAccounts.checking.id;
  bool _isFixedExpense = false;
  String _billingCycle = 'Monthly';

  // Getters
  String get amount => _amount;
  ExpenseCategory? get selectedCategory => _selectedCategory;
  Account? get selectedAccount => _selectedAccount;
  DateTime get selectedDate => _selectedDate;
  String get expenseName => _expenseName;
  String get selectedAccountId => _selectedAccountId;
  bool get isFixedExpense => _isFixedExpense;
  String get billingCycle => _billingCycle;
  bool get isEditMode => initialExpense != null;

  ExpenseFormController({
    required this.categoryRepo,
    required this.accountRepo,
    required this.initialType,
    this.initialExpense,
  }) {
    _initialize();
  }

  void _initialize() {
    _loadAccount(_selectedAccountId);
    _isFixedExpense = initialType == ExpenseType.fixed;
    
    if (initialExpense != null) {
      _initializeFromExpense();
    }
  }

  Future<void> _initializeFromExpense() async {
    final expense = initialExpense!;
    _amount = expense.amount.toString();
    _selectedAccountId = expense.accountId;
    _expenseName = expense.title;
    _selectedDate = expense.date;
    _billingCycle = expense.billingCycle ?? 'Monthly';
    _isFixedExpense = expense.type == ExpenseType.fixed;
    
    await _loadCategory(expense.categoryId);
    await _loadAccount(expense.accountId);
    notifyListeners();
  }

  Future<void> _loadCategory(String? categoryId) async {
    if (categoryId != null) {
      final category = await categoryRepo.findCategoryById(categoryId);
      _selectedCategory = category;
    }
  }

  Future<void> _loadAccount(String accountId) async {
    final account = await accountRepo.findAccountById(accountId);
    _selectedAccount = account;
  }

  // Setters
  void setAmount(String amount) {
    _amount = amount;
    notifyListeners();
  }

  void setCategory(ExpenseCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setAccount(Account account) {
    _selectedAccount = account;
    _selectedAccountId = account.id;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setExpenseName(String name) {
    _expenseName = name;
    notifyListeners();
  }

  void setFixedExpense(bool isFixed) {
    _isFixedExpense = isFixed;
    notifyListeners();
  }

  void setBillingCycle(String cycle) {
    _billingCycle = cycle;
    notifyListeners();
  }

  // Validation
  bool canProceedFromStep(int step) {
    switch (step) {
      case 0: // Amount step
        return _amount != '0' && _amount.isNotEmpty && _selectedAccount != null;
      case 1: // Category step
        return _selectedCategory != null;
      case 2: // Details step
        return true; // All required fields are now validated in previous steps
      default:
        return false;
    }
  }

  // Expense creation
  Expense createExpense() {
    if (!canProceedFromStep(2)) {
      throw Exception('Cannot create expense: invalid form state');
    }

    final amount = double.parse(_amount);
    
    // Determine the expense type based on initialType and _isFixedExpense
    ExpenseType expenseType;
    if (initialType == ExpenseType.subscription) {
      expenseType = ExpenseType.subscription;
    } else {
      expenseType = _isFixedExpense ? ExpenseType.fixed : ExpenseType.variable;
    }
    
    // Determine necessity based on category
    final necessity = _determineNecessity();
    
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
    
    return Expense(
      id: initialExpense?.id ?? const Uuid().v4(),
      title: _expenseName.trim().isNotEmpty ? _expenseName.trim() : _selectedCategory!.name,
      amount: amount,
      date: _selectedDate,
      createdAt: initialExpense?.createdAt ?? DateTime.now(),
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
} 