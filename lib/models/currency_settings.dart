class CurrencySettings {
  static const String prefsKey = 'selected_currency';

  static const Map<String, CurrencyFormat> availableCurrencies = {
    'USD': CurrencyFormat(
      code: 'USD',
      symbol: '\$',
      name: 'US Dollar',
      locale: 'en_US',
    ),
    'BRL': CurrencyFormat(
      code: 'BRL',
      symbol: 'R\$',
      name: 'Brazilian Real',
      locale: 'pt_BR',
    ),
  };
}

class CurrencyFormat {
  final String code;
  final String symbol;
  final String name;
  final String locale;

  const CurrencyFormat({
    required this.code,
    required this.symbol,
    required this.name,
    required this.locale,
  });
} 