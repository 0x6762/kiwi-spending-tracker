import 'package:intl/intl.dart';

final _currencyFormatter = NumberFormat.currency(
  symbol: '\$',
  decimalDigits: 2,
);

String formatCurrency(double amount) {
  return _currencyFormatter.format(amount);
}
