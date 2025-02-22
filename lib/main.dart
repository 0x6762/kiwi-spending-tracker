import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'repositories/repository_provider.dart';
import 'services/expense_analytics_service.dart';
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

  // Initialize analytics service
  final analyticsService = ExpenseAnalyticsService(
    repositoryProvider.expenseRepository,
    repositoryProvider.categoryRepository,
  );

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
  ));
}

class MyApp extends StatelessWidget {
  final RepositoryProvider repositoryProvider;
  final ExpenseAnalyticsService analyticsService;

  const MyApp({
    super.key,
    required this.repositoryProvider,
    required this.analyticsService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: repositoryProvider),
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
