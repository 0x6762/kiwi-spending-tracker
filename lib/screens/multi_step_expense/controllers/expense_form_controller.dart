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
  final Expense? initialExpense;

  // Form state
  String _amount = '0';
  ExpenseCategory? _selectedCategory;
  Account? _selectedAccount;
  DateTime _selectedDate = DateTime.now();
  String _expenseName = '';
  String _selectedAccountId = DefaultAccounts.checking.id;
  bool _isRecurring = false;
  ExpenseFrequency _frequency = ExpenseFrequency.oneTime;

  // Getters
  String get amount => _amount;
  ExpenseCategory? get selectedCategory => _selectedCategory;
  Account? get selectedAccount => _selectedAccount;
  DateTime get selectedDate => _selectedDate;
  String get expenseName => _expenseName;
  String get selectedAccountId => _selectedAccountId;
  bool get isRecurring => _isRecurring;
  ExpenseFrequency get frequency => _frequency;
  bool get isEditMode => initialExpense != null;

  ExpenseFormController({
    required this.categoryRepo,
    required this.accountRepo,
    this.initialExpense,
  }) {
    _initialize();
  }

  void _initialize() {
    _loadAccount(_selectedAccountId);

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
    _isRecurring = expense.isRecurring;
    _frequency = expense.frequency;

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

  void setRecurring(bool isRecurring) {
    _isRecurring = isRecurring;
    if (!isRecurring) {
      _frequency = ExpenseFrequency.oneTime;
    }
    notifyListeners();
  }

  void setFrequency(ExpenseFrequency frequency) {
    _frequency = frequency;
    // Automatically set isRecurring based on frequency
    _isRecurring = frequency != ExpenseFrequency.oneTime;
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

    // Determine necessity based on category
    final necessity = _determineNecessity();

    // Calculate next billing date for recurring expenses
    DateTime? nextBillingDate;
    if (_isRecurring && _frequency != ExpenseFrequency.oneTime) {
      final date = _selectedDate;
      switch (_frequency) {
        case ExpenseFrequency.daily:
          nextBillingDate = DateTime(date.year, date.month, date.day + 1);
          break;
        case ExpenseFrequency.weekly:
          nextBillingDate = DateTime(date.year, date.month, date.day + 7);
          break;
        case ExpenseFrequency.biWeekly:
          nextBillingDate = DateTime(date.year, date.month, date.day + 14);
          break;
        case ExpenseFrequency.monthly:
          nextBillingDate = DateTime(date.year, date.month + 1, date.day);
          break;
        case ExpenseFrequency.quarterly:
          nextBillingDate = DateTime(date.year, date.month + 3, date.day);
          break;
        case ExpenseFrequency.yearly:
          nextBillingDate = DateTime(date.year + 1, date.month, date.day);
          break;
        default:
          nextBillingDate = null;
      }
    }

    return Expense(
      id: initialExpense?.id ?? const Uuid().v4(),
      title: _expenseName.trim().isNotEmpty
          ? _expenseName.trim()
          : _selectedCategory!.name,
      amount: amount,
      date: _selectedDate,
      createdAt: initialExpense?.createdAt ?? DateTime.now(),
      categoryId: _selectedCategory!.id,
      notes: null,
      accountId: _selectedAccountId,
      nextBillingDate: nextBillingDate,
      dueDate: null,
      necessity: necessity,
      isRecurring: _isRecurring,
      frequency: _frequency,
      status: ExpenseStatus.paid,
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
