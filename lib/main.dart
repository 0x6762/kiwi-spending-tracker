import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'repositories/expense_repository.dart';
import 'screens/expense_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spending Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: ExpenseListScreen(repository: LocalStorageExpenseRepository(prefs)),
    );
  }
}
