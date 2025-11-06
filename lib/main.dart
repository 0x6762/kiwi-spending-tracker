import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'repositories/repository_provider.dart';
import 'services/expense_analytics_service.dart';
import 'services/subscription_service.dart';
import 'services/recurring_expense_service.dart';
import 'services/navigation_service.dart';

import 'theme/theme.dart';
import 'theme/theme_provider.dart';
import 'utils/formatters.dart';
import 'database/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeFormatter();
  final database = AppDatabase();
  final repositoryProvider = RepositoryProvider(
    database: database,
  );

  final analyticsService = ExpenseAnalyticsService(
    repositoryProvider.expenseRepository,
    repositoryProvider.categoryRepository,
  );

  final subscriptionService = SubscriptionService(
    repositoryProvider.expenseRepository,
    repositoryProvider.categoryRepository,
  );

  final recurringExpenseService = RecurringExpenseService(
    repositoryProvider.expenseRepository,
  );

  final navigationService = NavigationService();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  runApp(MyApp(
    repositoryProvider: repositoryProvider,
    analyticsService: analyticsService,
    subscriptionService: subscriptionService,
    recurringExpenseService: recurringExpenseService,
    navigationService: navigationService,
  ));

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeRepositoriesInBackground(repositoryProvider);
    _initializeDatabaseInBackground(database);
    _processRecurringExpensesInBackground(recurringExpenseService);
  });
}

void _initializeRepositoriesInBackground(RepositoryProvider repositoryProvider) async {
  try {
    await repositoryProvider.initialize();
  } catch (e, stackTrace) {
    debugPrint('Error initializing repositories: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}

void _initializeDatabaseInBackground(AppDatabase database) async {
  try {
    await database.ensureIndexes();
  } catch (e, stackTrace) {
    debugPrint('Error initializing database indexes: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}

void _processRecurringExpensesInBackground(
    RecurringExpenseService recurringExpenseService) async {
  try {
    final processedCount =
        await recurringExpenseService.processRecurringExpenses();
    if (processedCount > 0) {
      debugPrint('Processed $processedCount recurring expenses');
    }
  } catch (e, stackTrace) {
    debugPrint('Error processing recurring expenses: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}

class MyApp extends StatelessWidget {
  final RepositoryProvider repositoryProvider;
  final ExpenseAnalyticsService analyticsService;
  final SubscriptionService subscriptionService;
  final RecurringExpenseService recurringExpenseService;
  final NavigationService navigationService;

  const MyApp({
    super.key,
    required this.repositoryProvider,
    required this.analyticsService,
    required this.subscriptionService,
    required this.recurringExpenseService,
    required this.navigationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: repositoryProvider),
        ChangeNotifierProvider.value(value: navigationService),
        Provider.value(value: subscriptionService),
        Provider.value(value: recurringExpenseService),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) =>
            AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: MaterialApp(
            title: 'Kiwi',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.themeMode,
            home: MainScreen(
              repository: repositoryProvider.expenseRepository,
              categoryRepo: repositoryProvider.categoryRepository,
              accountRepo: repositoryProvider.accountRepository,
              analyticsService: analyticsService,
            ),
          ),
        ),
      ),
    );
  }
}
