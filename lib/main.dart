import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/main_screen.dart';
import 'repositories/repository_provider.dart';
import 'services/expense_analytics_service.dart';
import 'services/subscription_service.dart';
import 'services/recurring_expense_service.dart';
import 'services/navigation_service.dart';
import 'services/scroll_service.dart';
import 'theme/theme.dart';
import 'theme/theme_provider.dart';
import 'utils/formatters.dart';
import 'database/database.dart';
import 'database/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize currency formatter
  await initializeFormatter();

  // Initialize database
  final database = AppDatabase();
  final databaseProvider = DatabaseProvider();

  // Initialize repository provider
  final repositoryProvider = RepositoryProvider(
    database: database,
  );

  // Wait for repositories to initialize
  await repositoryProvider.initialize();

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
  
  // Initialize scroll service
  final scrollService = ScrollService();
  
  // Process any pending recurring expenses (includes subscriptions, fixed, and variable)
  try {
    final processedCount = await recurringExpenseService.processRecurringExpenses();
    debugPrint('Processed $processedCount recurring expenses');
  } catch (e) {
    debugPrint('Error processing recurring expenses: $e');
  }

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
    scrollService: scrollService,
  ));
}

class MyApp extends StatelessWidget {
  final RepositoryProvider repositoryProvider;
  final ExpenseAnalyticsService analyticsService;
  final SubscriptionService subscriptionService;
  final RecurringExpenseService recurringExpenseService;
  final NavigationService navigationService;
  final ScrollService scrollService;

  const MyApp({
    super.key,
    required this.repositoryProvider,
    required this.analyticsService,
    required this.subscriptionService,
    required this.recurringExpenseService,
    required this.navigationService,
    required this.scrollService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: repositoryProvider),
        ChangeNotifierProvider.value(value: navigationService),
        ChangeNotifierProvider.value(value: scrollService),
        Provider.value(value: subscriptionService),
        Provider.value(value: recurringExpenseService),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => AnnotatedRegion<SystemUiOverlayStyle>(
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
