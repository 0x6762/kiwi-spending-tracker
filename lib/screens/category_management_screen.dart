import 'package:flutter/material.dart';
import '../models/expense_category.dart';
import '../widgets/add_category_sheet.dart';
import '../repositories/category_repository.dart';
import '../widgets/app_bar.dart';

class CategoryManagementScreen extends StatefulWidget {
  final CategoryRepository categoryRepo;

  const CategoryManagementScreen({
    super.key,
    required this.categoryRepo,
  });

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  List<ExpenseCategory> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await widget.categoryRepo.getAllCategories();
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
        categoryRepo: widget.categoryRepo,
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
      appBar: KiwiAppBar(
        title: 'Categories',
        leading: const Icon(Icons.arrow_back),
      ),
      body: ListView.builder(
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
                    categoryRepo: widget.categoryRepo,
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
      ),
    );
  }
}
