import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
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
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedCurrency.symbol,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
                    title: const Text('Categories'),
                    subtitle: const Text('Manage expense categories'),
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
                'Data',
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
                    title: const Text('Backup & Restore'),
                    subtitle: const Text('Manage your expense data'),
                    onTap: () {
                      // TODO: Implement backup & restore
                    },
                  ),
                  ListTile(
                    leading: const Icon(AppIcons.clearData),
                    title: const Text('Clear Data'),
                    subtitle: const Text('Delete all expenses'),
                    textColor: theme.colorScheme.error,
                    iconColor: theme.colorScheme.error,
                    onTap: () {
                      // TODO: Implement clear data
                    },
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
