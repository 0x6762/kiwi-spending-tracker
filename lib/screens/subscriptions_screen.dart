import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/account_repository.dart';
import '../widgets/expense_list.dart';
import '../widgets/app_bar.dart';
import '../utils/formatters.dart';
import 'expense_detail_screen.dart';

class SubscriptionsScreen extends StatefulWidget {
  final ExpenseRepository repository;
  final CategoryRepository categoryRepo;
  final AccountRepository accountRepo;

  const SubscriptionsScreen({
    super.key,
    required this.repository,
    required this.categoryRepo,
    required this.accountRepo,
  });

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  List<Expense> _subscriptions = [];
  bool _isLoading = true;
  final _dateFormat = DateFormat.yMMMd();

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final expenseDate = DateTime(date.year, date.month, date.day);

    if (expenseDate == today) {
      return 'Today';
    } else if (expenseDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return _dateFormat.format(date);
    }
  }

  Future<void> _loadSubscriptions() async {
    setState(() => _isLoading = true);
    try {
      // Get all expenses and filter for subscriptions
      final expenses = await widget.repository.getAllExpenses();
      final subscriptions = expenses
          .where((expense) => expense.type == ExpenseType.subscription)
          .toList();
      
      // Sort by next billing date if available, otherwise by date
      subscriptions.sort((a, b) {
        if (a.nextBillingDate != null && b.nextBillingDate != null) {
          return a.nextBillingDate!.compareTo(b.nextBillingDate!);
        } else if (a.nextBillingDate != null) {
          return -1;
        } else if (b.nextBillingDate != null) {
          return 1;
        } else {
          return a.date.compareTo(b.date);
        }
      });
      
      setState(() {
        _subscriptions = subscriptions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load subscriptions: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteSubscription(Expense expense) async {
    await widget.repository.deleteExpense(expense.id);
    _loadSubscriptions();
  }

  void _viewSubscriptionDetails(Expense expense) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailScreen(
          expense: expense,
          categoryRepo: widget.categoryRepo,
          accountRepo: widget.accountRepo,
          onExpenseUpdated: (updatedExpense) async {
            await widget.repository.updateExpense(updatedExpense);
            _loadSubscriptions();
          },
        ),
        maintainState: true,
      ),
    );

    if (result == true) {
      await _deleteSubscription(expense);
    }
  }

  Widget _buildSubscriptionItem(BuildContext context, Expense subscription) {
    final theme = Theme.of(context);
    
    return FutureBuilder<ExpenseCategory?>(
      future: widget.categoryRepo.findCategoryById(subscription.categoryId ?? CategoryRepository.uncategorizedId),
      builder: (context, snapshot) {
        final category = snapshot.data;
        
        return Dismissible(
          key: Key(subscription.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: theme.colorScheme.surfaceContainer,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: Icon(
              Icons.delete,
              color: theme.colorScheme.error,
            ),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Subscription'),
                content: const Text('Are you sure you want to delete this subscription?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('DELETE'),
                  ),
                ],
              ),
            ) ?? false;
          },
          onDismissed: (_) => _deleteSubscription(subscription),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                category?.icon ?? Icons.category_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            title: Text(
              subscription.title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: subscription.nextBillingDate != null
                          ? Text(
                              'Next billing: ${_formatDate(subscription.nextBillingDate!)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : Text(
                              'Added: ${_formatDate(subscription.date)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                    ),
                    Text(
                      subscription.billingCycle ?? 'Monthly',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Text(
              formatCurrency(subscription.amount),
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            onTap: () => _viewSubscriptionDetails(subscription),
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionSummary() {
    final theme = Theme.of(context);
    final totalMonthly = _subscriptions
        .where((s) => s.billingCycle == 'Monthly')
        .fold(0.0, (sum, s) => sum + s.amount);
    
    final totalYearly = _subscriptions
        .where((s) => s.billingCycle == 'Yearly')
        .fold(0.0, (sum, s) => sum + s.amount);
    
    // Calculate monthly equivalent of yearly subscriptions
    final yearlyAsMonthly = totalYearly / 12;
    final totalMonthlyEquivalent = totalMonthly + yearlyAsMonthly;

    return Card(
      margin: const EdgeInsets.fromLTRB(8, 16, 8, 16),
      color: theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Subscription Cost',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatCurrency(totalMonthlyEquivalent),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Billing',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatCurrency(totalMonthly),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yearly Billing (Monthly Equiv.)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatCurrency(yearlyAsMonthly),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: KiwiAppBar(
        title: 'Subscriptions',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSubscriptions,
        color: theme.colorScheme.primary,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _subscriptions.isEmpty
                ? Center(
                    child: Text(
                      'No active subscriptions',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSubscriptionSummary(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Text(
                            'Active Subscriptions',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: theme.colorScheme.surfaceContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _subscriptions.length,
                            itemBuilder: (context, index) {
                              return _buildSubscriptionItem(context, _subscriptions[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
} 