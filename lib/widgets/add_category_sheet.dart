import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_category.dart';
import '../repositories/category_repository.dart';
import '../utils/icons.dart';
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
  IconData _selectedIcon = AppIcons.category;
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
                  AppIcons.shopping,
                  AppIcons.shoppingCart,
                  AppIcons.store,
                  AppIcons.mall,
                  AppIcons.gift,
                  AppIcons.discount,
                  AppIcons.tag,

                  // Food & Dining
                  AppIcons.foodDining,
                  AppIcons.restaurant,
                  AppIcons.cafe,
                  AppIcons.bar,
                  AppIcons.beer,
                  AppIcons.fastFood,
                  AppIcons.pizza,
                  AppIcons.iceCream,
                  AppIcons.bakery,

                  // Transportation
                  AppIcons.transportation,
                  AppIcons.bus,
                  AppIcons.train,
                  AppIcons.taxi,
                  AppIcons.bike,
                  AppIcons.scooter,
                  AppIcons.motorcycle,
                  AppIcons.parking,
                  AppIcons.gas,

                  // Home & Utilities
                  AppIcons.home,
                  AppIcons.house,
                  AppIcons.water,
                  AppIcons.power,
                  AppIcons.wifi,
                  AppIcons.ac,
                  AppIcons.cleaning,
                  AppIcons.furniture,
                  AppIcons.tools,

                  // Health & Wellness
                  AppIcons.health,
                  AppIcons.hospital,
                  AppIcons.doctor,
                  AppIcons.dentist,
                  AppIcons.pharmacy,
                  AppIcons.medication,
                  AppIcons.fitness,
                  AppIcons.yoga,
                  AppIcons.spa,

                  // Entertainment
                  AppIcons.entertainment,
                  AppIcons.games,
                  AppIcons.sports,
                  AppIcons.theater,
                  AppIcons.movie,
                  AppIcons.tv,
                  AppIcons.music,
                  AppIcons.concert,
                  AppIcons.karaoke,

                  // Travel & Transportation
                  AppIcons.travel,
                  AppIcons.hotel,
                  AppIcons.beach,
                  AppIcons.luggage,
                  AppIcons.map,
                  AppIcons.camping,
                  AppIcons.hiking,
                  AppIcons.passport,
                  AppIcons.rental,

                  // Education
                  AppIcons.education,
                  AppIcons.book,
                  AppIcons.stories,
                  AppIcons.library,
                  AppIcons.science,
                  AppIcons.art,
                  AppIcons.language_learning,
                  AppIcons.online_course,
                  AppIcons.certificate,

                  // Personal Care
                  AppIcons.face,
                  AppIcons.haircut,
                  AppIcons.cosmetics,
                  AppIcons.nails,
                  AppIcons.perfume,
                  AppIcons.skincare,
                  AppIcons.spa,
                  AppIcons.dryCleaning,

                  // Bills & Finance
                  AppIcons.bank,
                  AppIcons.creditCard,
                  AppIcons.receiptLong,
                  AppIcons.payments,
                  AppIcons.money,
                  AppIcons.savings,
                  AppIcons.insurance,
                  AppIcons.investment,
                  AppIcons.tax,

                  // Pets
                  AppIcons.pets,
                  AppIcons.veterinary,
                  AppIcons.petFood,
                  AppIcons.grooming,
                  AppIcons.crueltyFree,

                  // Other
                  AppIcons.category,
                  AppIcons.more,
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
