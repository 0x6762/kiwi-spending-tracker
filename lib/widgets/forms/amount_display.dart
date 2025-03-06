import 'package:flutter/material.dart';
import 'dart:math' as math;

class AmountDisplay extends StatelessWidget {
  final String amount;
  final DateTime date;
  
  const AmountDisplay({
    super.key,
    required this.amount,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDate(date),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  '\$',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                _formatAmount(amount),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
  
  String _formatAmount(String amount) {
    if (amount == '0') return '0';
    if (amount.contains('.')) {
      final parts = amount.split('.');
      if (parts[1].isEmpty) return amount; // Just show the decimal point
      return parts[0] + '.' + parts[1].substring(0, math.min(parts[1].length, 2)); // Limit to 2 decimal places
    }
    return amount;
  }
} 