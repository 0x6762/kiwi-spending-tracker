import 'package:flutter/material.dart';
import '../models/account.dart';
import '../widgets/add_account_sheet.dart';
import '../repositories/account_repository.dart';
import '../widgets/app_bar.dart';
import '../utils/icons.dart';

class AccountManagementScreen extends StatefulWidget {
  final AccountRepository accountRepo;

  const AccountManagementScreen({
    super.key,
    required this.accountRepo,
  });

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accounts = await widget.accountRepo.getAllAccounts();
    setState(() {
      _accounts = accounts..sort((a, b) {
        // First sort by default status (default accounts first)
        if (a.isDefault != b.isDefault) {
          return a.isDefault ? -1 : 1;
        }
        // Then sort by name
        return a.name.compareTo(b.name);
      });
    });
  }

  void _showAddAccountSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddAccountSheet(
        accountRepo: widget.accountRepo,
        onAccountAdded: () {
          _loadAccounts();
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildAccountCard(Account account) {
    final theme = Theme.of(context);
    final isModified = account.isDefault && account.isModified;

    return Card(
      color: theme.colorScheme.surfaceContainer,
      child: ListTile(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddAccountSheet(
              accountRepo: widget.accountRepo,
              accountToEdit: account,
              onAccountAdded: () {
                _loadAccounts();
              },
            ),
          );
        },
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
        title: Text(
          account.name,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: account.isDefault && account.isModified ? Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Modified',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ) : null,
        trailing: account.isDefault ? Icon(
          AppIcons.edit,
          color: theme.colorScheme.onSurfaceVariant,
        ) : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                AppIcons.edit,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddAccountSheet(
                    accountRepo: widget.accountRepo,
                    accountToEdit: account,
                    onAccountAdded: () {
                      _loadAccounts();
                    },
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(
                AppIcons.delete,
                color: theme.colorScheme.error,
              ),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Account'),
                    content: Text('Are you sure you want to delete ${account.name}?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && mounted) {
                  try {
                    await widget.accountRepo.deleteAccount(account.id);
                    _loadAccounts();
                  } catch (e) {
                    if (mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Cannot Delete Account'),
                          content: Text(e.toString().replaceAll('Exception: ', '')),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultAccounts = _accounts.where((a) => a.isDefault).toList();
    final customAccounts = _accounts.where((a) => !a.isDefault).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: KiwiAppBar(
        title: 'Accounts',
        leading: const Icon(AppIcons.back),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Card(
              color: theme.colorScheme.surfaceContainer,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    AppIcons.add,
                    color: theme.colorScheme.primary,
                  ),
                ),
                title: Text(
                  'Create Account',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                onTap: _showAddAccountSheet,
              ),
            ),
          ),
          if (defaultAccounts.isNotEmpty) ...[
            _buildSectionHeader('Default Accounts'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: defaultAccounts.map(_buildAccountCard).toList(),
              ),
            ),
          ],
          if (customAccounts.isNotEmpty) ...[
            _buildSectionHeader('Custom Accounts'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: customAccounts.map(_buildAccountCard).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
} 