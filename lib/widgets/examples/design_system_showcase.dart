import 'package:flutter/material.dart';
import '../common/app_button.dart';
import '../common/app_card.dart';
import '../common/icon_container.dart';
import '../../theme/design_tokens.dart';
import '../../utils/icons.dart';

/// Showcase of the new design system components and design tokens
/// This file demonstrates proper usage of all standardized components
class DesignSystemShowcase extends StatelessWidget {
  const DesignSystemShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Showcase'),
      ),
      body: SingleChildScrollView(
        padding: DesignTokens.paddingScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Design Tokens',
              [
                _buildSpacingDemo(context),
                _buildBorderRadiusDemo(context),
              ],
            ),
            _buildSection(
              context,
              'Buttons',
              [
                _buildButtonDemo(context),
              ],
            ),
            _buildSection(
              context,
              'Cards',
              [
                _buildCardDemo(context),
              ],
            ),
            _buildSection(
              context,
              'Icon Containers',
              [
                _buildIconContainerDemo(context),
              ],
            ),
            _buildSection(
              context,
              'Specialized Components',
              [
                _buildSpecializedComponentDemo(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: DesignTokens.marginSection,
          child: Text(
            title,
            style: theme.textTheme.headlineSmall,
          ),
        ),
        ...children.map((child) => Padding(
          padding: DesignTokens.marginComponent,
          child: child,
        )),
        SizedBox(height: DesignTokens.spacingXl),
      ],
    );
  }

  Widget _buildSpacingDemo(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppCard.outlined(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spacing Scale',
            style: theme.textTheme.titleMedium,
          ),
          SizedBox(height: DesignTokens.spacingMd),
          ...{
            'XS (4px)': DesignTokens.spacingXs,
            'SM (8px)': DesignTokens.spacingSm,
            'MD (16px)': DesignTokens.spacingMd,
            'LG (24px)': DesignTokens.spacingLg,
            'XL (32px)': DesignTokens.spacingXl,
            'XXL (48px)': DesignTokens.spacingXxl,
          }.entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: DesignTokens.spacingSm),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      entry.key,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Container(
                    width: entry.value,
                    height: 16,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBorderRadiusDemo(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppCard.outlined(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Border Radius Scale',
            style: theme.textTheme.titleMedium,
          ),
          SizedBox(height: DesignTokens.spacingMd),
          Wrap(
            spacing: DesignTokens.spacingMd,
            runSpacing: DesignTokens.spacingSm,
            children: [
              _buildRadiusExample(context, 'XS', DesignTokens.radiusXs),
              _buildRadiusExample(context, 'SM', DesignTokens.radiusSm),
              _buildRadiusExample(context, 'MD', DesignTokens.radiusMd),
              _buildRadiusExample(context, 'LG', DesignTokens.radiusLg),
              _buildRadiusExample(context, 'XL', DesignTokens.radiusXl),
              _buildRadiusExample(context, 'XXL', DesignTokens.radiusXxl),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusExample(BuildContext context, String label, double radius) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        SizedBox(height: DesignTokens.spacingXs),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildButtonDemo(BuildContext context) {
    return AppCard.outlined(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Button Variants',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: DesignTokens.spacingMd),
          Wrap(
            spacing: DesignTokens.spacingMd,
            runSpacing: DesignTokens.spacingSm,
            children: [
              AppButton.primary(
                text: 'Primary',
                onPressed: () {},
              ),
              AppButton.secondary(
                text: 'Secondary',
                onPressed: () {},
              ),
              AppButton.outline(
                text: 'Outline',
                onPressed: () {},
              ),
              AppButton.text(
                text: 'Text',
                onPressed: () {},
              ),
              AppButton.destructive(
                text: 'Destructive',
                onPressed: () {},
              ),
            ],
          ),
          SizedBox(height: DesignTokens.spacingMd),
          Text(
            'Button Sizes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: DesignTokens.spacingMd),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppButton.primary(
                text: 'Small Button',
                size: AppButtonSize.small,
                onPressed: () {},
              ),
              SizedBox(height: DesignTokens.spacingSm),
              AppButton.primary(
                text: 'Medium Button',
                size: AppButtonSize.medium,
                onPressed: () {},
              ),
              SizedBox(height: DesignTokens.spacingSm),
              AppButton.primary(
                text: 'Large Button',
                size: AppButtonSize.large,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardDemo(BuildContext context) {
    return Column(
      children: [
        AppCard.outlined(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Card Variants',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: DesignTokens.spacingMd),
              AppCard.standard(
                child: Text('Standard Card'),
              ),
              SizedBox(height: DesignTokens.spacingSm),
              AppCard.elevated(
                child: Text('Elevated Card'),
              ),
              SizedBox(height: DesignTokens.spacingSm),
              AppCard.filled(
                child: Text('Filled Card'),
              ),
              SizedBox(height: DesignTokens.spacingSm),
              AppCard.outlined(
                child: Text('Outlined Card'),
              ),
            ],
          ),
        ),
        SizedBox(height: DesignTokens.spacingMd),
        InfoCard(
          title: 'Info Card Example',
          subtitle: 'This is an info card with leading and trailing elements',
          leading: IconContainer.icon(
            icon: Icons.info,
            iconColor: Theme.of(context).colorScheme.primary,
          ),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        SizedBox(height: DesignTokens.spacingMd),
        MetricCard(
          title: 'Total Spent',
          value: '\$1,234.56',
          icon: IconContainer.icon(
            icon: Icons.account_balance_wallet,
            iconColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildIconContainerDemo(BuildContext context) {
    return AppCard.outlined(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Icon Container Sizes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: DesignTokens.spacingMd),
          Row(
            children: [
              IconContainer.icon(
                icon: Icons.star,
                size: IconContainerSize.small,
              ),
              SizedBox(width: DesignTokens.spacingMd),
              IconContainer.icon(
                icon: Icons.star,
                size: IconContainerSize.medium,
              ),
              SizedBox(width: DesignTokens.spacingMd),
              IconContainer.icon(
                icon: Icons.star,
                size: IconContainerSize.large,
              ),
              SizedBox(width: DesignTokens.spacingMd),
              IconContainer.icon(
                icon: Icons.star,
                size: IconContainerSize.extraLarge,
              ),
            ],
          ),
          SizedBox(height: DesignTokens.spacingMd),
          Text(
            'Specialized Icon Containers',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: DesignTokens.spacingMd),
          Row(
            children: [
              ExpenseTypeIconContainer(
                expenseType: 'variable',
              ),
              SizedBox(width: DesignTokens.spacingMd),
              ExpenseTypeIconContainer(
                expenseType: 'fixed',
              ),
              SizedBox(width: DesignTokens.spacingMd),
              ExpenseTypeIconContainer(
                expenseType: 'subscription',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializedComponentDemo(BuildContext context) {
    return Column(
      children: [
        ActionCard(
          title: 'Add New Category',
          subtitle: 'Create a new spending category',
          icon: IconContainer.icon(
            icon: Icons.add,
            iconColor: Theme.of(context).colorScheme.primary,
          ),
          actionText: 'Add',
          onTap: () {},
        ),
        SizedBox(height: DesignTokens.spacingMd),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'This Month',
                value: '\$2,540.30',
                accentColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(width: DesignTokens.spacingMd),
            Expanded(
              child: MetricCard(
                title: 'Last Month',
                value: '\$1,890.45',
                accentColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
} 