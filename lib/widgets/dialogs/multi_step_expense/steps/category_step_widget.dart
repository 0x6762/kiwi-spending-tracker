import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/expense_form_controller.dart';
import '../../../../models/expense_category.dart';
import '../../../forms/picker_button.dart';
import '../../../sheets/picker_sheet.dart';
import '../../../sheets/add_category_sheet.dart';
import '../../../../utils/icons.dart';

class CategoryStepWidget extends StatelessWidget {
  final VoidCallback? onNext;

  const CategoryStepWidget({
    super.key,
    required this.onNext,
  });

  void _showCategoryPicker(BuildContext context, ExpenseFormController controller) async {
    final repo = controller.categoryRepo;
    
    // Ensure default categories are loaded
    await repo.loadCategories();
    
    // Get all categories and sort by name
    final categories = await repo.getAllCategories();
    categories.sort((a, b) => a.name.compareTo(b.name));

    if (!context.mounted) return;

    PickerSheet.show(
      context: context,
      title: 'Select Category',
      children: [
        // Add Category button
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              AppIcons.add,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(
            'Create Category',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () async {
            Navigator.pop(context); // Close picker sheet
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => AddCategorySheet(
                categoryRepo: controller.categoryRepo,
                onCategoryAdded: () {
                  // Will refresh categories when picker is shown again
                },
              ),
            );
            // Show picker sheet again after category is added
            if (context.mounted) {
              _showCategoryPicker(context, controller);
            }
          },
        ),
        const Divider(),
        ...categories.map(
          (category) => ListTile(
            leading: Icon(category.icon),
            title: Text(category.name),
            selected: controller.selectedCategory?.id == category.id,
            onTap: () {
              controller.setCategory(category);
              Navigator.pop(context);
            },
          ),
        ),
      ],
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Select Category button
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 40),
                      child: PickerButton(
                        label: controller.selectedCategory?.name ?? 'Select Category',
                        icon: controller.selectedCategory?.icon ?? AppIcons.category,
                        onTap: () => _showCategoryPicker(context, controller),
                      ),
                    ),
                    
                    // Recently used categories
                    FutureBuilder<List<ExpenseCategory>>(
                      future: _loadRecentCategories(controller),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        }

                        final recentCategories = snapshot.data ?? [];
                        
                        if (recentCategories.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recently Used',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2.0,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: recentCategories.length,
                              itemBuilder: (context, index) {
                                final category = recentCategories[index];
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
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: isSelected
                                            ? Border.all(color: theme.colorScheme.primary.withOpacity(0.3), width: 1.5)
                                            : Border.all(color: theme.colorScheme.surfaceContainer, width: 1.5),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Icon at the top
                                          Container(
                                            padding: const EdgeInsets.all(0),
                                            
                                            child: Icon(
                                              category.icon,
                                              color: isSelected 
                                                  ? theme.colorScheme.primary
                                                  : theme.colorScheme.onSurfaceVariant,
                                              size: 24,
                                            ),
                                          ),
                                          // Category name below
                                          Text(
                                            category.name,
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: theme.colorScheme.onSurface,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
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
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Next',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
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

  Future<List<ExpenseCategory>> _loadRecentCategories(ExpenseFormController controller) async {
    try {
      // For now, we'll load all categories and return the first 6 as "recent"
      // In a real implementation, you'd track usage and sort by most recent
      await controller.categoryRepo.loadCategories();
      final categories = await controller.categoryRepo.getAllCategories();
      
      // Return up to 6 categories as recent ones
      return categories.take(6).toList();
    } catch (e) {
      return [];
    }
  }
} 