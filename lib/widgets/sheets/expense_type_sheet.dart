import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'bottom_sheet.dart';
import '../../models/expense.dart';
import '../../repositories/expense_repository.dart';
import '../../repositories/category_repository.dart';
import '../../utils/icons.dart';
import '../forms/voice_input_button.dart';

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
          iconColor: theme.colorScheme.primary,
          onTap: () => onTypeSelected(ExpenseType.variable),
        ),
        const SizedBox(height: 8),
        _ExpenseTypeButton(
          title: 'Voice Input',
          subtitle: 'Add an expense using your voice',
          icon: AppIcons.mic,
          iconColor: theme.colorScheme.onSurfaceVariant,
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
  final dynamic icon;
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
                child: icon is IconData
                    ? Icon(
                        icon as IconData,
                        color: iconColor,
                        size: 24,
                      )
                    : SvgPicture.asset(
                        icon as String,
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          iconColor,
                          BlendMode.srcIn,
                        ),
                      ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (title == 'Voice Input')
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Beta',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
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
