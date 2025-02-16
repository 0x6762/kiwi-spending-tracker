import 'package:flutter/material.dart';
import 'database.dart';

class DatabaseProvider extends ChangeNotifier {
  final AppDatabase database;

  DatabaseProvider() : database = AppDatabase();

  @override
  void dispose() {
    database.close();
    super.dispose();
  }
} 