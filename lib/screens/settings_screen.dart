import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'category_management_screen.dart';
import 'account_management_screen.dart';
import '../models/currency_settings.dart';
import '../utils/formatters.dart';
import '../utils/icons.dart';
import '../repositories/category_repository.dart';
import '../repositories/repository_provider.dart';
import '../widgets/common/app_bar.dart';
import '../theme/theme_provider.dart';
import '../widgets/sheets/picker_sheet.dart';
import '../services/backup_service.dart';
import '../database/database.dart';

class SettingsScreen extends StatefulWidget {
  final CategoryRepository categoryRepo;

  const SettingsScreen({
    super.key,
    required this.categoryRepo,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedCurrency = 'USD';
  String _version = '';
  bool _isVersionLoading = true;
  bool _isBackingUp = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentCurrency();
    _loadAppVersion();
  }

  Future<void> _loadCurrentCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCurrency = prefs.getString(CurrencySettings.prefsKey) ?? 'USD';
    });
  }

  Future<void> _loadAppVersion() async {
    try {
      setState(() => _isVersionLoading = true);
      final packageInfo = await PackageInfo.fromPlatform();
      print('Loaded version: ${packageInfo.version}+${packageInfo.buildNumber}'); // Debug print
      setState(() {
        _version = packageInfo.version; // Only using the semantic version
        _isVersionLoading = false;
      });
    } catch (e) {
      print('Error loading version: $e'); // Debug print
      setState(() {
        _version = 'Error loading version';
        _isVersionLoading = false;
      });
    }
  }

  Future<void> _changeCurrency(String currencyCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(CurrencySettings.prefsKey, currencyCode);
    await initializeFormatter();
    setState(() {
      _selectedCurrency = currencyCode;
    });
  }

  void _showThemePicker() {
    final theme = Theme.of(context);
    final themeProvider = context.read<ThemeProvider>();

    PickerSheet.show(
      context: context,
      title: 'Select Theme',
      children: ThemeMode.values.map((mode) => ListTile(
        title: Text(themeProvider.getThemeModeName(mode)),
        selected: themeProvider.themeMode == mode,
        onTap: () {
          themeProvider.setThemeMode(mode);
          Navigator.pop(context);
        },
      )).toList(),
    );
  }

  void _showCurrencyPicker() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Select Currency',
                    style: theme.textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(AppIcons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...CurrencySettings.availableCurrencies.entries.map(
              (entry) => ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    entry.value.symbol,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                title: Text(entry.value.name),
                subtitle: Text(entry.value.code),
                selected: _selectedCurrency == entry.key,
                onTap: () async {
                  await _changeCurrency(entry.key);
                  if (mounted) Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBackup() async {
    try {
      setState(() => _isBackingUp = true);
      
      final backupService = BackupService(AppDatabase());
      final backupPath = await backupService.createBackup();
      
      if (mounted) {
        // Show options dialog
        final action = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Backup Created'),
            content: const Text(
              'Backup created successfully. Would you like to share it to save it to your device?'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'close'),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'share'),
                child: Text(
                  'Share',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        );

        if (action == 'share') {
          await backupService.shareBackup(backupPath);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating backup: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBackingUp = false);
      }
    }
  }

  Future<void> _restoreFromBackup() async {
    try {
      setState(() => _isRestoring = true);
      
      final backupService = BackupService(AppDatabase());
      final backupPath = await backupService.pickBackupFile();
      
      if (backupPath != null) {
        // Show confirmation dialog
        final shouldRestore = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Restore Backup'),
            content: const Text(
              'This will replace all current data with the backup data. '
              'This action cannot be undone. Are you sure you want to continue?'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Restore',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        );

        if (shouldRestore == true) {
          await backupService.restoreFromBackup(backupPath);
          
          if (mounted) {
            // Show dialog informing user to restart the app
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Backup Restored'),
                content: const Text(
                  'Your backup has been restored successfully. '
                  'Please restart the app for the changes to take effect.'
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            
            // Exit the app
            SystemNavigator.pop();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error restoring backup: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }

  Future<void> _manageBackups() async {
    final backupService = BackupService(AppDatabase());
    final backupInfo = await backupService.getBackupInfo();
    
    if (!mounted) return;
    
    // Format the size in a readable way
    String formatSize(int bytes) {
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Management'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stored backups: ${backupInfo['count']}'),
            Text('Total size: ${formatSize(backupInfo['totalSize'])}'),
            const SizedBox(height: 16),
            const Text(
              'The app automatically keeps the 5 most recent backups. '
              'Older backups are deleted when new ones are created.'
            ),
            const SizedBox(height: 16),
            const Text(
              'Note: These are only the backups stored within the app. '
              'Backups you\'ve saved to other locations are not affected.'
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: backupInfo['count'] > 0 
              ? () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete All Backups'),
                      content: const Text(
                        'Are you sure you want to delete all backups stored within the app? '
                        'This action cannot be undone.\n\n'
                        'Note: Backups you\'ve saved to other locations will not be affected.'
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirmed == true) {
                    await backupService.deleteAllBackups();
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('All stored backups deleted'),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }
                  }
                }
              : null,
            child: Text(
              'Delete All',
              style: TextStyle(
                color: backupInfo['count'] > 0 
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).disabledColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCurrency = CurrencySettings.availableCurrencies[_selectedCurrency]!;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: KiwiAppBar(
        title: 'Settings',
        leading: const Icon(AppIcons.back),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                'Appearance',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.zero,
              color: theme.colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(AppIcons.theme),
                    title: const Text('Theme'),
                    subtitle: Text(themeProvider.getThemeModeName(themeProvider.themeMode)),
                    onTap: _showThemePicker,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Text(
                'Preferences',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.zero,
              color: theme.colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(AppIcons.money),
                    title: const Text('Currency'),
                    subtitle: Text(selectedCurrency.name),
                    onTap: _showCurrencyPicker,
                  ),
                  ListTile(
                    leading: const Icon(AppIcons.accounts),
                    title: const Text('Manage Accounts'),
                    subtitle: const Text('Add or edit your accounts'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountManagementScreen(
                            accountRepo: context.read<RepositoryProvider>().accountRepository,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(AppIcons.categories),
                    title: const Text('Manage Categories'),
                    subtitle: const Text('Add or edit your categories'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryManagementScreen(
                            categoryRepo: widget.categoryRepo,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Text(
                'Backup & Restore',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.zero,
              color: theme.colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(AppIcons.backup),
                    title: const Text('Create Backup'),
                    subtitle: const Text('Save your data to a file'),
                    onTap: _isBackingUp ? null : _createBackup,
                    trailing: _isBackingUp
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                  ListTile(
                    leading: const Icon(AppIcons.restore),
                    title: const Text('Restore from Backup'),
                    subtitle: const Text('Load data from a backup file'),
                    onTap: _isRestoring ? null : _restoreFromBackup,
                    trailing: _isRestoring
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                  ListTile(
                    leading: const Icon(AppIcons.clearData),
                    title: const Text('Manage Backups'),
                    subtitle: const Text('View and delete stored backups'),
                    onTap: _manageBackups,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Center(
              child: _isVersionLoading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Version $_version',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
