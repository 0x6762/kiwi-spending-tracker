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

  // Initialize currency formatter
  await initializeFormatter();

  // Initialize database
  final database = AppDatabase();

  // Initialize repository provider
  final repositoryProvider = RepositoryProvider(
    database: database,
  );

  // Note: Repository initialization is deferred to avoid blocking startup
  // It will be called after the first frame is rendered

  // Initialize services
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

  // Initialize navigation service
  final navigationService = NavigationService();

  // Set system UI overlay style at app startup
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Enable edge-to-edge
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

  // Initialize repositories, database indexes, and process recurring expenses
  // after the app is initialized. This prevents blocking the UI thread during app startup
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeRepositoriesInBackground(repositoryProvider);
    _initializeDatabaseInBackground(database);
    _processRecurringExpensesInBackground(recurringExpenseService);
  });
}

/// Initialize repositories in the background after app initialization
/// This runs asynchronously and doesn't block the UI
void _initializeRepositoriesInBackground(RepositoryProvider repositoryProvider) async {
  try {
    await repositoryProvider.initialize();
  } catch (e, stackTrace) {
    debugPrint('Error initializing repositories: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}

/// Initialize database indexes in the background after app initialization
/// This runs asynchronously and doesn't block the UI
void _initializeDatabaseInBackground(AppDatabase database) async {
  try {
    await database.ensureIndexes();
  } catch (e, stackTrace) {
    debugPrint('Error initializing database indexes: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}

/// Process recurring expenses in the background after app initialization
/// This runs asynchronously and doesn't block the UI
void _processRecurringExpensesInBackground(
    RecurringExpenseService recurringExpenseService) async {
  try {
    final processedCount =
        await recurringExpenseService.processRecurringExpenses();
    if (processedCount > 0) {
      debugPrint('Processed $processedCount recurring expenses');
    }
  } catch (e, stackTrace) {
    // Log error with stack trace for debugging
    debugPrint('Error processing recurring expenses: $e');
    debugPrint('Stack trace: $stackTrace');
    // In production, you might want to send this to a crash reporting service
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
