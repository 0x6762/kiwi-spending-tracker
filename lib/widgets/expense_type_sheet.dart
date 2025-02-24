import 'package:flutter/material.dart';
import 'bottom_sheet.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';
import '../utils/icons.dart';
import 'voice_input_button.dart';

class ExpenseTypeSheet extends StatelessWidget {
  final void Function(ExpenseType type) onTypeSelected;
  final ExpenseRepository repository;
  final CategoryRepository categoryRepo;
  final VoidCallback onExpenseAdded;

  const ExpenseTypeSheet({
    super.key,
    required this.onTypeSelected,
    required this.repository,
    required this.categoryRepo,
    required this.onExpenseAdded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBottomSheet(
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      children: [
        _ExpenseTypeButton(
          title: 'Add Expense',
          subtitle: 'Regular expenses like groceries, bills, shopping',
          icon: AppIcons.add,
          iconColor: const Color(0xFF8056E4),
          onTap: () => onTypeSelected(ExpenseType.variable),
        ),
        const SizedBox(height: 8),
        _ExpenseTypeButton(
          title: 'Subscription',
          subtitle: 'Fixed recurring payments like Netflix, Spotify',
          icon: AppIcons.calendar,
          iconColor: const Color(0xFF2196F3),
          onTap: () => onTypeSelected(ExpenseType.subscription),
        ),
        const SizedBox(height: 8),
        _ExpenseTypeButton(
          title: 'Voice Input',
          subtitle: 'Add an expense using your voice',
          icon: AppIcons.mic,
          iconColor: theme.colorScheme.primary,
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => Dialog(
                backgroundColor: theme.colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: VoiceInputButton(
                  repository: repository,
                  categoryRepo: categoryRepo,
                  onExpenseAdded: onExpenseAdded,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ExpenseTypeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ExpenseTypeButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                AppIcons.chevronRight,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
