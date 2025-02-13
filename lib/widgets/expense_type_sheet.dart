import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'bottom_sheet.dart';
import '../models/expense.dart';

class ExpenseTypeSheet extends StatelessWidget {
  final void Function(ExpenseType type) onTypeSelected;

  const ExpenseTypeSheet({
    super.key,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      children: [
        _ExpenseTypeButton(
          title: 'Subscription',
          subtitle: 'Fixed recurring payments like Netflix, Spotify',
          iconAsset: 'assets/icons/subscription.svg',
          iconColor: const Color(0xFF2196F3),
          onTap: () => onTypeSelected(ExpenseType.subscription),
        ),
        const SizedBox(height: 8),
        _ExpenseTypeButton(
          title: 'Fixed Expense',
          subtitle: 'Variable recurring expenses like electricity, water',
          iconAsset: 'assets/icons/fixed_expense.svg',
          iconColor: const Color(0xFFCF5825),
          onTap: () => onTypeSelected(ExpenseType.fixed),
        ),
        const SizedBox(height: 8),
        _ExpenseTypeButton(
          title: 'Variable Expense',
          subtitle: 'One-time expenses like groceries, shopping',
          iconAsset: 'assets/icons/variable_expense.svg',
          iconColor: const Color(0xFF8056E4),
          onTap: () => onTypeSelected(ExpenseType.variable),
        ),
      ],
    );
  }
}

class _ExpenseTypeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconAsset;
  final Color iconColor;
  final VoidCallback onTap;

  const _ExpenseTypeButton({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
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
                child: SvgPicture.asset(
                  iconAsset,
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
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
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
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
