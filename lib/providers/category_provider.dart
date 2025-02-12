import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/category_repository.dart';

/// A simple provider class to manage the category repository instance
class CategoryProvider {
  static CategoryRepository? _instance;

  /// Get the singleton instance of the category repository
  static Future<CategoryRepository> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = SharedPrefsCategoryRepository(prefs);
      await _instance!.loadCategories();
    }
    return _instance!;
  }

  /// Reset the instance (useful for testing)
  static void reset() {
    _instance = null;
  }
} 