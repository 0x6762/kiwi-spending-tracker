import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExpenseTypeSheet extends StatelessWidget {
  const ExpenseTypeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 24, top: 4),
          //   child: Text(
          //     'Expense Type',
          //     style: theme.textTheme.titleMedium,
          //   ),
          // ),
          _ExpenseTypeButton(
            title: 'Fixed Expense',
            subtitle: 'Recurring expenses like rent, bills, subscriptions',
            iconAsset: 'assets/icons/fixed_expense.svg',
            iconColor: const Color(0xFFCF5825),
            onTap: () => Navigator.pop(context, true),
          ),
          const SizedBox(height: 24),
          _ExpenseTypeButton(
            title: 'Variable Expense',
            subtitle: 'One-time expenses like groceries, shopping',
            iconAsset: 'assets/icons/variable_expense.svg',
            iconColor: const Color(0xFF8056E4),
            onTap: () => Navigator.pop(context, false),
          ),
          const SizedBox(height: 16),
        ],
      ),
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
      color: theme.colorScheme.surfaceContainer, //Button background color
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
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
