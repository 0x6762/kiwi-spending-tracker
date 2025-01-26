import 'package:flutter/material.dart';
import '../models/expense_category.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCategorySheet extends StatefulWidget {
  final VoidCallback onCategoryAdded;
  final ExpenseCategory? categoryToEdit;

  const AddCategorySheet({
    super.key,
    required this.onCategoryAdded,
    this.categoryToEdit,
  });

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  IconData _selectedIcon = Icons.category_outlined;

  @override
  void initState() {
    super.initState();
    if (widget.categoryToEdit != null) {
      _nameController.text = widget.categoryToEdit!.name;
      _selectedIcon = widget.categoryToEdit!.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final newCategory = ExpenseCategory(
        name: _nameController.text.trim(),
        icon: _selectedIcon,
      );

      if (widget.categoryToEdit != null) {
        await ExpenseCategories.updateCategory(
          widget.categoryToEdit!,
          newCategory,
          prefs,
        );
      } else {
        await ExpenseCategories.addCategory(newCategory, prefs);
      }

      widget.onCategoryAdded();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.categoryToEdit != null ? 'Edit Category' : 'New Category',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'Enter category name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Icon',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 240, // Fixed height for icon grid
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    // Shopping & Retail
                    Icons.shopping_bag_outlined,
                    Icons.shopping_cart_outlined,
                    Icons.store_outlined,
                    Icons.local_mall_outlined,
                    Icons.card_giftcard_outlined,

                    // Food & Dining
                    Icons.restaurant_outlined,
                    Icons.local_cafe_outlined,
                    Icons.local_bar_outlined,
                    Icons.fastfood_outlined,
                    Icons.local_pizza_outlined,

                    // Transportation
                    Icons.directions_car_outlined,
                    Icons.directions_bus_outlined,
                    Icons.train_outlined,
                    Icons.local_taxi_outlined,
                    Icons.electric_bike_outlined,

                    // Home & Utilities
                    Icons.home_outlined,
                    Icons.house_outlined,
                    Icons.water_drop_outlined,
                    Icons.power_outlined,
                    Icons.wifi_outlined,

                    // Health & Wellness
                    Icons.medical_services_outlined,
                    Icons.local_hospital_outlined,
                    Icons.medication_outlined,
                    Icons.fitness_center_outlined,
                    Icons.spa_outlined,

                    // Entertainment
                    Icons.movie_outlined,
                    Icons.sports_esports_outlined,
                    Icons.sports_outlined,
                    Icons.theater_comedy_outlined,
                    Icons.music_note_outlined,

                    // Travel & Transportation
                    Icons.flight_outlined,
                    Icons.hotel_outlined,
                    Icons.beach_access_outlined,
                    Icons.luggage_outlined,
                    Icons.map_outlined,

                    // Education
                    Icons.school_outlined,
                    Icons.book_outlined,
                    Icons.auto_stories_outlined,
                    Icons.library_books_outlined,
                    Icons.science_outlined,

                    // Personal Care
                    Icons.face_outlined,
                    Icons.spa_outlined,
                    Icons.dry_cleaning_outlined,
                    Icons.content_cut_outlined,
                    Icons.brush_outlined,

                    // Bills & Finance
                    Icons.account_balance_outlined,
                    Icons.credit_card_outlined,
                    Icons.receipt_long_outlined,
                    Icons.payments_outlined,
                    Icons.attach_money_outlined,

                    // Pets
                    Icons.pets_outlined,
                    Icons.cruelty_free_outlined,

                    // Other
                    Icons.category_outlined,
                    Icons.more_horiz_outlined,
                  ].map((icon) {
                    final isSelected = _selectedIcon == icon;
                    return InkWell(
                      onTap: () => setState(() => _selectedIcon = icon),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: Text(widget.categoryToEdit != null
                  ? 'Save Changes'
                  : 'Create Category'),
            ),
          ],
        ),
      ),
    );
  }
}
