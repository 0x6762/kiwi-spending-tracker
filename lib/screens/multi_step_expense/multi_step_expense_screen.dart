import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/expense.dart';
import '../../../repositories/category_repository.dart';
import '../../../repositories/account_repository.dart';
import '../../widgets/common/app_bar.dart';
import '../../../utils/icons.dart';
import 'controllers/expense_form_controller.dart';
import 'steps/amount_step_widget.dart';
import 'steps/category_step_widget.dart';
import 'steps/details_step_widget.dart';

class MultiStepExpenseScreen extends StatefulWidget {
  final ExpenseType type;
  final CategoryRepository categoryRepo;
  final AccountRepository accountRepo;
  final void Function(Expense expense) onExpenseAdded;
  final Expense? expense;

  const MultiStepExpenseScreen({
    super.key,
    required this.type,
    required this.categoryRepo,
    required this.accountRepo,
    required this.onExpenseAdded,
    this.expense,
  });

  @override
  State<MultiStepExpenseScreen> createState() => _MultiStepExpenseScreenState();
}

class _MultiStepExpenseScreenState extends State<MultiStepExpenseScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;
  late ExpenseFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExpenseFormController(
      categoryRepo: widget.categoryRepo,
      accountRepo: widget.accountRepo,
      initialType: widget.type,
      initialExpense: widget.expense,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
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

  void _submitExpense() async {
    try {
      final expense = _controller.createExpense();
      widget.onExpenseAdded(expense);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating expense: $e')),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Material(
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
                RepaintBoundary(
                  child: AmountStepWidget(
                    onNext: _nextStep,
                  ),
                ),
                RepaintBoundary(
                  child: CategoryStepWidget(
                    onNext: _nextStep,
                  ),
                ),
                RepaintBoundary(
                  child: DetailsStepWidget(
                    onSubmit: _submitExpense,
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