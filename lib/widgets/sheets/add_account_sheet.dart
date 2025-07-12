import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/account.dart';
import '../../repositories/account_repository.dart';
import '../../utils/icons.dart';
import '../common/app_input.dart';
import '../common/app_button.dart';
import 'bottom_sheet.dart';
import 'color_picker_sheet.dart';

class AddAccountSheet extends StatefulWidget {
  final VoidCallback onAccountAdded;
  final Account? accountToEdit;
  final AccountRepository accountRepo;

  const AddAccountSheet({
    super.key,
    required this.onAccountAdded,
    required this.accountRepo,
    this.accountToEdit,
  });

  @override
  State<AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends State<AddAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  IconData _selectedIcon = Icons.account_balance;
  Color _selectedColor = Colors.blue;
  static final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.accountToEdit != null) {
      _nameController.text = widget.accountToEdit!.name;
      _selectedIcon = widget.accountToEdit!.icon;
      _selectedColor = widget.accountToEdit!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _generateAccountId() {
    if (widget.accountToEdit != null) {
      return widget.accountToEdit!.id;
    }
    // Generate a unique ID for new accounts
    return 'acc_${_uuid.v4()}';
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final newAccount = Account(
        id: _generateAccountId(),
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
      );

      try {
        if (widget.accountToEdit != null) {
          await widget.accountRepo.updateAccount(widget.accountToEdit!, newAccount);
        } else {
          await widget.accountRepo.addAccount(newAccount);
        }

        widget.onAccountAdded();
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

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ColorPickerSheet(
        selectedColor: _selectedColor,
        onColorSelected: (color) {
          setState(() => _selectedColor = color);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: AppBottomSheet(
        title: widget.accountToEdit != null ? 'Edit Account' : 'New Account',
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          Form(
            key: _formKey,
            child: AppInput(
              controller: _nameController,
              labelText: 'Account Name',
              hintText: 'Enter account name',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an account name';
                }
                if (value.trim().length < 2) {
                  return 'Account name must be at least 2 characters';
                }
                if (value.trim().length > 30) {
                  return 'Account name must be less than 30 characters';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Icon',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: screenHeight * (bottomPadding > 0 ? 0.2 : 0.3),
                      ),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            Icons.account_balance,
                            Icons.account_balance_wallet,
                            Icons.credit_card,
                            Icons.savings,
                            Icons.attach_money,
                            Icons.currency_exchange,
                            Icons.account_box,
                            Icons.payments,
                            Icons.price_check,
                            Icons.receipt_long,
                            Icons.wallet,
                          ].map((icon) {
                            return InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                setState(() => _selectedIcon = icon);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _selectedIcon == icon
                                      ? theme.colorScheme.primary.withOpacity(0.1)
                                      : null,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  icon,
                                  color: _selectedIcon == icon
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Color',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _showColorPicker,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppButton.primary(
            text: widget.accountToEdit != null ? 'Save Changes' : 'Create Account',
            onPressed: _submit,
            isExpanded: true,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
} 