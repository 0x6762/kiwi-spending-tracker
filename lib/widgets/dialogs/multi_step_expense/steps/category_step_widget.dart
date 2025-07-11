import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/expense_form_controller.dart';
import '../../../../models/expense_category.dart';
import '../../../sheets/add_category_sheet.dart';
import '../../../../utils/icons.dart';

class CategoryStepWidget extends StatefulWidget {
  final VoidCallback? onNext;

  const CategoryStepWidget({
    super.key,
    required this.onNext,
  });

  @override
  State<CategoryStepWidget> createState() => _CategoryStepWidgetState();
}

class _CategoryStepWidgetState extends State<CategoryStepWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddCategorySheet(BuildContext context, ExpenseFormController controller) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCategorySheet(
        categoryRepo: controller.categoryRepo,
        onCategoryAdded: () {
          // Refresh the categories when a new one is added
          controller.notifyListeners();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ExpenseFormController>(
      builder: (context, controller, child) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Search field
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search categories...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainer,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),

                    // Categories title row
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Text(
                            'Categories',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => _showAddCategorySheet(context, controller),
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                            ),
                            child: Text(
                              'Add new',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // All Categories
                    FutureBuilder<List<ExpenseCategory>>(
                      future: _loadAllCategories(controller),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final allCategories = snapshot.data ?? [];
                        final categories = _filterCategories(allCategories);
                        
                        if (categories.isEmpty) {
                          return SizedBox(
                            width: double.infinity,
                            child: Card(
                              margin: EdgeInsets.zero,
                              color: theme.colorScheme.surfaceContainer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_searchQuery.isEmpty) ...[
                                      Icon(
                                        AppIcons.category,
                                        size: 48,
                                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                    Text(
                                      _searchQuery.isNotEmpty 
                                          ? 'No categories found'
                                          : 'No categories yet',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categories.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final isSelected = controller.selectedCategory?.id == category.id;
                            
                            return Material(
                              color: isSelected 
                                  ? theme.colorScheme.primary.withOpacity(0.1)
                                  : theme.colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                onTap: () => controller.setCategory(category),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: isSelected
                                        ? Border.all(color: theme.colorScheme.primary, width: 2)
                                        : Border.all(color: Colors.transparent, width: 2),
                                  ),
                                  child: Row(
                                    children: [
                                      // Icon
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isSelected 
                                              ? theme.colorScheme.primary.withOpacity(0.2)
                                              : theme.colorScheme.onSurfaceVariant.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          category.icon,
                                          color: isSelected 
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.onSurfaceVariant,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Category name
                                      Expanded(
                                        child: Text(
                                          category.name,
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            color: isSelected 
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.onSurface,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Selection indicator
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle,
                                          color: theme.colorScheme.primary,
                                          size: 24,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Next button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: controller.selectedCategory != null ? widget.onNext : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  disabledBackgroundColor: theme.colorScheme.onSurfaceVariant.withOpacity(0.1),
                  disabledForegroundColor: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Next',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: controller.selectedCategory != null 
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<ExpenseCategory>> _loadAllCategories(ExpenseFormController controller) async {
    try {
      // Ensure default categories are loaded
      await controller.categoryRepo.loadCategories();
      final categories = await controller.categoryRepo.getAllCategories();
      
      // Sort categories by name
      categories.sort((a, b) => a.name.compareTo(b.name));
      
      return categories;
    } catch (e) {
      return [];
    }
  }

  List<ExpenseCategory> _filterCategories(List<ExpenseCategory> categories) {
    if (_searchQuery.isEmpty) {
      return categories;
    }
    
    return categories.where((category) {
      return category.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }
} 