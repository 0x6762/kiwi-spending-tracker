import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/account_repository.dart';
import '../services/subscription_service.dart';
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
  late SubscriptionService _subscriptionService;
  List<SubscriptionData> _subscriptions = [];
  SubscriptionSummary? _summary;
  bool _isLoading = true;
  final _dateFormat = DateFormat.yMMMd();

  @override
  void initState() {
    super.initState();
    _subscriptionService = SubscriptionService(widget.repository, widget.categoryRepo);
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
      // Get subscriptions and summary from the service
      final subscriptions = await _subscriptionService.getSubscriptions();
      final summary = await _subscriptionService.getSubscriptionSummary();
      
      setState(() {
        _subscriptions = subscriptions;
        _summary = summary;
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

  Widget _buildSubscriptionItem(BuildContext context, SubscriptionData subscription) {
    final theme = Theme.of(context);
    
    // Define status colors
    final Color statusColor;
    switch (subscription.status) {
      case SubscriptionStatus.overdue:
        statusColor = theme.colorScheme.error;
        break;
      case SubscriptionStatus.dueSoon:
        statusColor = Colors.orange;
        break;
      case SubscriptionStatus.active:
        statusColor = theme.colorScheme.primary;
        break;
    }
    
    return FutureBuilder<ExpenseCategory?>(
      future: widget.categoryRepo.findCategoryById(subscription.expense.categoryId ?? CategoryRepository.uncategorizedId),
      builder: (context, snapshot) {
        final category = snapshot.data;
        
        return Dismissible(
          key: Key(subscription.expense.id),
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
          onDismissed: (_) => _deleteSubscription(subscription.expense),
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
            title: Row(
              children: [
                // Status indicator
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    subscription.expense.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
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
                              'Added: ${_formatDate(subscription.expense.date)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                    ),
                    Text(
                      subscription.expense.billingCycle ?? 'Monthly',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Text(
              formatCurrency(subscription.expense.amount),
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            onTap: () => _viewSubscriptionDetails(subscription.expense),
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionSummary() {
    final theme = Theme.of(context);
    
    // Use the summary from the service if available
    final totalMonthlyAmount = _summary?.totalMonthlyAmount ?? 0.0;
    final monthlyBillingAmount = _summary?.monthlyBillingAmount ?? 0.0;
    final yearlyAsMonthly = _summary?.yearlyBillingMonthlyEquivalent ?? 0.0;
    
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
              formatCurrency(totalMonthlyAmount),
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
                        formatCurrency(monthlyBillingAmount),
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
            if (_summary != null && (_summary!.overdueSubscriptions > 0 || _summary!.dueSoonSubscriptions > 0)) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Subscription Status',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              if (_summary!.overdueSubscriptions > 0)
                _buildStatusIndicator(
                  'Overdue', 
                  _summary!.overdueSubscriptions, 
                  theme.colorScheme.error
                ),
              if (_summary!.dueSoonSubscriptions > 0)
                _buildStatusIndicator(
                  'Due Soon', 
                  _summary!.dueSoonSubscriptions, 
                  Colors.orange
                ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusIndicator(String label, int count, Color color) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            '$label: $count',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
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