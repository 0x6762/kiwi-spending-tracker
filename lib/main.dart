import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'repositories/expense_repository.dart';
import 'repositories/category_repository.dart';
import 'services/expense_analytics_service.dart';
import 'theme/theme.dart';
import 'theme/theme_provider.dart';
import 'utils/formatters.dart';
import 'utils/category_migration.dart';
import 'database/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Initialize currency formatter
  await initializeFormatter();

  // Initialize repositories
  final categoryRepo = SharedPrefsCategoryRepository(prefs);
  await categoryRepo.loadCategories();

  // Initialize repositories and services
  final expenseRepo = LocalStorageExpenseRepository(prefs);
  final analyticsService = ExpenseAnalyticsService(expenseRepo, categoryRepo);

  // Run category migration
  await CategoryMigration.migrateToIds(prefs, categoryRepo);

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
    prefs: prefs,
    categoryRepo: categoryRepo,
    expenseRepo: expenseRepo,
    analyticsService: analyticsService,
  ));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final CategoryRepository categoryRepo;
  final ExpenseRepository expenseRepo;
  final ExpenseAnalyticsService analyticsService;

  const MyApp({
    super.key, 
    required this.prefs,
    required this.categoryRepo,
    required this.expenseRepo,
    required this.analyticsService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DatabaseProvider()),
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
              repository: expenseRepo,
              categoryRepo: categoryRepo,
              analyticsService: analyticsService,
            ),
          ),
        ),
      ),
    );
  }
}
