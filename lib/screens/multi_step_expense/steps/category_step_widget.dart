import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/expense_form_controller.dart';
import '../../../models/expense_category.dart';
import '../../../widgets/sheets/add_category_sheet.dart';
import '../../../utils/icons.dart';

class CategoryStepWidget extends StatefulWidget {
  final VoidCallback? onNext;

  const CategoryStepWidget({
    super.key,
    required this.onNext,
  });

  @override
  State<CategoryStepWidget> createState() => _CategoryStepWidgetState();
}

class _CategoryStepWidgetState extends State<CategoryStepWidget> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isSearching = false;
  Future<List<ExpenseCategory>>? _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    // Start animation at full opacity for initial load
    _animationController.value = 1.0;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
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
          setState(() {
            _categoriesFuture = null; // Reset cache to reload categories
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

        return Consumer<ExpenseFormController>(
      builder: (context, controller, child) {
        // Cache the future to prevent recreation on every rebuild
        _categoriesFuture ??= _loadAllCategories(controller);

        return Column(
          children: [
            // Fixed search bar
            Container(
              padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 16),
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
                              _isSearching = false;
                            });
                            _animationController.reset();
                            _animationController.forward();
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
                    _isSearching = value.isNotEmpty;
                  });
                  if (_isSearching) {
                    _animationController.reset();
                    _animationController.forward();
                  }
                },
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      future: _categoriesFuture,
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
                        
                        return _buildCategoriesWithAnimation(allCategories, controller, theme);
                      },
                    ),
                  ],
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
      return category.name.toLowerCase().startsWith(_searchQuery.toLowerCase());
    }).toList();
  }

  Widget _buildCategoriesWithAnimation(List<ExpenseCategory> allCategories, ExpenseFormController controller, ThemeData theme) {
    final categories = _filterCategories(allCategories);
    
    // Only animate when actively searching, not on initial load
    return _isSearching 
        ? FadeTransition(
            opacity: _fadeAnimation,
            child: _buildCategoriesList(categories, controller, theme),
          )
        : _buildCategoriesList(categories, controller, theme);
  }

  Widget _buildCategoriesList(List<ExpenseCategory> categories, ExpenseFormController controller, ThemeData theme) {
    return categories.isEmpty
        ? SizedBox(
            width: double.infinity,
            child: Card(
              margin: EdgeInsets.zero,
              color: theme.colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
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
          )
        : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              
              return TextButton(
                onPressed: () {
                  // Dismiss keyboard if it's open
                  FocusScope.of(context).unfocus();
                  controller.setCategory(category);
                  // Always call onNext directly, regardless of current availability
                  // This ensures the first tap works immediately
                  widget.onNext?.call();
                },
                style: TextButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainer,
                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        category.icon,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Category name
                    Expanded(
                      child: Text(
                        category.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }
} 