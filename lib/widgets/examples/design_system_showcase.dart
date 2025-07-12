import 'package:flutter/material.dart';
import '../common/app_button.dart';
import '../common/app_card.dart';
import '../common/app_input.dart';
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
               'Inputs',
               [
                 _buildInputDemo(context),
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
    
    return AppCard.standard(
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
    
    return AppCard.standard(
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
    return AppCard.standard(
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
    final theme = Theme.of(context);
    
    return Column(
      children: [
        AppCard.standard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Card Variants (Production)',
                style: theme.textTheme.titleMedium,
              ),
              SizedBox(height: DesignTokens.spacingMd),
              AppCard.standard(
                child: Text('Standard Card - Used in subscription & upcoming expense cards'),
              ),
              SizedBox(height: DesignTokens.spacingSm),
              AppCard.surface(
                child: Text('Surface Card - Used in today spending card'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconContainerDemo(BuildContext context) {
    return AppCard.standard(
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

  Widget _buildInputDemo(BuildContext context) {
    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Input Variants',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: DesignTokens.spacingMd),
          AppInput.filled(
            labelText: 'Filled Input',
            hintText: 'Enter text here',
          ),
          SizedBox(height: DesignTokens.spacingMd),
          AppInput.outlined(
            labelText: 'Outlined Input',
            hintText: 'Enter text here',
          ),
          SizedBox(height: DesignTokens.spacingMd),
          AppInput.underlined(
            labelText: 'Underlined Input',
            hintText: 'Enter text here',
          ),
          SizedBox(height: DesignTokens.spacingMd),
          Text(
            'Specialized Inputs',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: DesignTokens.spacingMd),
          SearchInput(
            hintText: 'Search expenses...',
          ),
          SizedBox(height: DesignTokens.spacingMd),
          PasswordInput(
            labelText: 'Password',
            hintText: 'Enter your password',
          ),
        ],
      ),
    );
  }


} 