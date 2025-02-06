import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency_settings.dart';

late NumberFormat _currencyFormatter;

Future<void> initializeFormatter() async {
  final prefs = await SharedPreferences.getInstance();
  final currencyCode = prefs.getString(CurrencySettings.prefsKey) ?? 'USD';
  final currency = CurrencySettings.availableCurrencies[currencyCode]!;
  
  _currencyFormatter = NumberFormat.currency(
    locale: currency.locale,
    symbol: currency.symbol,
    decimalDigits: 2,
    customPattern: '¤#,##0.00',
  );
}

String formatCurrency(double amount) {
  return _currencyFormatter.format(amount);
}

// Initialize formatter with default USD on app start
void initializeDefaultFormatter() {
  final defaultCurrency = CurrencySettings.availableCurrencies['USD']!;
  _currencyFormatter = NumberFormat.currency(
    locale: defaultCurrency.locale,
    symbol: defaultCurrency.symbol,
    decimalDigits: 2,
    customPattern: '¤#,##0.00',
  );
}
