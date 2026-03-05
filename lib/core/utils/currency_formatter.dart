import '../constants/currency_constants.dart';

/// Utility class for formatting currency values
class CurrencyFormatter {
  // Private constructor to prevent instantiation
  CurrencyFormatter._();

  /// Formats a double value to Indonesian Rupiah string
  /// Example: 15000.0 -> "Rp 15.000,00"
  static String format(double amount) {
    // Format with decimal places
    final String withDecimal = amount.toStringAsFixed(
      CurrencyConstants.decimalDigits,
    );

    // Split into integer and decimal parts
    final parts = withDecimal.split('.');
    final String integerPart = parts[0];
    final String decimalPart = parts.length > 1 ? parts[1] : '';

    // Add thousand separators to integer part
    final String formattedInteger = _addThousandSeparator(integerPart);

    // Combine with symbol
    if (decimalPart.isNotEmpty) {
      return '${CurrencyConstants.currencySymbol} $formattedInteger${CurrencyConstants.decimalSeparator}$decimalPart';
    }
    return '${CurrencyConstants.currencySymbol} $formattedInteger';
  }

  /// Formats a double value to Indonesian Rupiah string without decimal places
  /// Example: 15000.0 -> "Rp 15.000"
  static String formatWithoutDecimals(double amount) {
    final String rounded = amount.round().toString();
    final String formattedInteger = _addThousandSeparator(rounded);
    return '${CurrencyConstants.currencySymbol} $formattedInteger';
  }

  /// Formats a double value to Indonesian Rupiah string for display in UI
  /// Uses the format with Rp prefix but backslash escape for display
  static String formatForDisplay(double amount) {
    return format(amount);
  }

  /// Adds thousand separators to a number string
  static String _addThousandSeparator(String value) {
    if (value.length <= 3) return value;

    final buffer = StringBuffer();
    int count = 0;

    for (int i = value.length - 1; i >= 0; i--) {
      buffer.write(value[i]);
      count++;

      if (count == 3 && i != 0) {
        buffer.write(CurrencyConstants.thousandSeparator);
        count = 0;
      }
    }

    return buffer.toString().split('').reversed.join('');
  }

  /// Parses a formatted currency string back to double
  /// Example: "Rp 15.000,00" -> 15000.0
  static double? parse(String formatted) {
    try {
      // Remove currency symbol and spaces
      String cleaned = formatted
          .replaceAll(CurrencyConstants.currencySymbol, '')
          .replaceAll(' ', '')
          .replaceAll(CurrencyConstants.thousandSeparator, '');

      // Replace decimal separator with dot for parsing
      cleaned = cleaned.replaceAll(CurrencyConstants.decimalSeparator, '.');

      return double.tryParse(cleaned);
    } catch (_) {
      return null;
    }
  }
}
