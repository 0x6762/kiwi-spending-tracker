import 'package:flutter/material.dart';
import 'database.dart';

class DatabaseProvider {
  final AppDatabase database = AppDatabase();

  void dispose() {
    database.close();
  }
} 