import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_category.dart';
import '../repositories/category_repository.dart';
import 'bottom_sheet.dart';

class AddCategorySheet extends StatefulWidget {
  final VoidCallback onCategoryAdded;
  final ExpenseCategory? categoryToEdit;
  final CategoryRepository categoryRepo;

  const AddCategorySheet({
    super.key,
    required this.onCategoryAdded,
    required this.categoryRepo,
    this.categoryToEdit,
  });

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  IconData _selectedIcon = Icons.category_outlined;
  static final _uuid = const Uuid();

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

  String _generateCategoryId() {
    if (widget.categoryToEdit != null) {
      return widget.categoryToEdit!.id;
    }
    // Generate a unique ID for new categories
    return 'cat_${_uuid.v4()}';
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final newCategory = ExpenseCategory(
        id: _generateCategoryId(),
        name: _nameController.text.trim(),
        icon: _selectedIcon,
      );

      try {
        if (widget.categoryToEdit != null) {
          await widget.categoryRepo.updateCategory(widget.categoryToEdit!, newCategory);
        } else {
          await widget.categoryRepo.addCategory(newCategory);
        }

        widget.onCategoryAdded();
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: AppBottomSheet(
        title: widget.categoryToEdit != null ? 'Edit Category' : 'New Category',
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
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
                if (value.trim().length < 2) {
                  return 'Category name must be at least 2 characters';
                }
                if (value.trim().length > 30) {
                  return 'Category name must be less than 30 characters';
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
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight * (bottomPadding > 0 ? 0.2 : 0.4),
            ),
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
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
