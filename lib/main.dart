import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'repositories/repository_provider.dart';
import 'services/expense_analytics_service.dart';
import 'services/subscription_service.dart';
import 'theme/theme.dart';
import 'theme/theme_provider.dart';
import 'utils/formatters.dart';
import 'database/database.dart';
import 'database/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  
  // Process any pending recurring subscriptions
  try {
    final processedCount = await subscriptionService.processRecurringSubscriptions();
    debugPrint('Processed $processedCount recurring subscriptions');
  } catch (e) {
    debugPrint('Error processing recurring subscriptions: $e');
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
  ));
}

class MyApp extends StatelessWidget {
  final RepositoryProvider repositoryProvider;
  final ExpenseAnalyticsService analyticsService;
  final SubscriptionService subscriptionService;

  const MyApp({
    super.key,
    required this.repositoryProvider,
    required this.analyticsService,
    required this.subscriptionService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: repositoryProvider),
        Provider.value(value: subscriptionService),
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
