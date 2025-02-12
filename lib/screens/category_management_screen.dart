import 'package:flutter/material.dart';
import '../models/expense_category.dart';
import '../widgets/add_category_sheet.dart';
import '../providers/category_provider.dart';
import '../repositories/category_repository.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  late Future<CategoryRepository> _categoryRepoFuture;
  List<ExpenseCategory> _categories = [];

  @override
  void initState() {
    super.initState();
    _categoryRepoFuture = CategoryProvider.getInstance();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final repo = await _categoryRepoFuture;
    final categories = await repo.getAllCategories();
    setState(() {
      _categories = categories..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  void _showAddCategorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCategorySheet(
        onCategoryAdded: () {
          _loadCategories();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'Manage Categories',
          style: theme.textTheme.titleMedium,
        ),
      ),
      body: FutureBuilder<CategoryRepository>(
        future: _categoryRepoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: _categories.length + 1, // +1 for create item
            itemBuilder: (context, index) {
              if (index == 0) {
                // Create category item
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    color: theme.colorScheme.surfaceContainer,
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.add,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        'Create Category',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      onTap: _showAddCategorySheet,
                    ),
                  ),
                );
              }

              final category = _categories[index - 1];
              return Card(
                color: theme.colorScheme.surfaceContainer,
                child: ListTile(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => AddCategorySheet(
                        categoryToEdit: category,
                        onCategoryAdded: () {
                          _loadCategories();
                        },
                      ),
                    );
                  },
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      category.icon,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  trailing: Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: Icon(
                      Icons.edit,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
