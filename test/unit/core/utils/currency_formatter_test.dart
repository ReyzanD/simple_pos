import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/core/utils/currency_formatter.dart';
import '../../helpers/test_constants.dart';

void main() {
  group('CurrencyFormatter.format', () {
    test('should format small amount correctly', () {
      // Arrange
      const amount = TestConstants.testAmountSmall;

      // Act
      final result = CurrencyFormatter.format(amount);

      // Assert
      expect(result, 'Rp 100,00');
    });

    test('should format medium amount with thousand separator', () {
      // Arrange
      const amount = TestConstants.testAmountMedium;

      // Act
      final result = CurrencyFormatter.format(amount);

      // Assert
      expect(result, 'Rp 15.000,00');
    });

    test('should format large amount with multiple thousand separators', () {
      // Arrange
      const amount = TestConstants.testAmountLarge;

      // Act
      final result = CurrencyFormatter.format(amount);

      // Assert
      expect(result, 'Rp 15.000.000,00');
    });

    test('should format amount with decimals correctly', () {
      // Arrange
      const amount = TestConstants.testAmountWithDecimals;

      // Act
      final result = CurrencyFormatter.format(amount);

      // Assert
      expect(result, 'Rp 15.000,50');
    });

    test('should format zero amount correctly', () {
      // Arrange
      const amount = TestConstants.testAmountZero;

      // Act
      final result = CurrencyFormatter.format(amount);

      // Assert
      expect(result, 'Rp 0,00');
    });

    test('should format negative amount with minus sign', () {
      // Arrange
      const amount = TestConstants.testAmountNegative;

      // Act
      final result = CurrencyFormatter.format(amount);

      // Assert
      expect(result, 'Rp -100,00');
    });

    test('should format amount with varying decimal places', () {
      // Arrange
      const amount = 15000.123;

      // Act
      final result = CurrencyFormatter.format(amount);

      // Assert
      expect(result, 'Rp 15.000,12'); // Should round to 2 decimal places
    });

    test('should format amount exactly at thousand boundary', () {
      // Arrange
      const amount = 1000.0;

      // Act
      final result = CurrencyFormatter.format(amount);

      // Assert
      expect(result, 'Rp 1.000,00');
    });

    test('should format amount just above thousand boundary', () {
      // Arrange
      const amount = 1100.0;

      // Act
      final result = CurrencyFormatter.format(amount);

      // Assert
      expect(result, 'Rp 1.100,00');
    });

    test('should format amount at million boundary', () {
      // Arrange
      const amount = 1000000.0;

      // Act
      final result = CurrencyFormatter.format(amount);

      // Assert
      expect(result, 'Rp 1.000.000,00');
    });
  });

  group('CurrencyFormatter.formatWithoutDecimals', () {
    test('should format small amount without decimals', () {
      // Arrange
      const amount = TestConstants.testAmountSmall;

      // Act
      final result = CurrencyFormatter.formatWithoutDecimals(amount);

      // Assert
      expect(result, 'Rp 100');
    });

    test('should format medium amount without decimals', () {
      // Arrange
      const amount = TestConstants.testAmountMedium;

      // Act
      final result = CurrencyFormatter.formatWithoutDecimals(amount);

      // Assert
      expect(result, 'Rp 15.000');
    });

    test('should format large amount without decimals', () {
      // Arrange
      const amount = TestConstants.testAmountLarge;

      // Act
      final result = CurrencyFormatter.formatWithoutDecimals(amount);

      // Assert
      expect(result, 'Rp 15.000.000');
    });

    test('should format amount with decimals by rounding', () {
      // Arrange
      const amount = TestConstants.testAmountWithDecimals;

      // Act
      final result = CurrencyFormatter.formatWithoutDecimals(amount);

      // Assert
      expect(result, 'Rp 15.001'); // Should round up
    });

    test('should format zero amount without decimals', () {
      // Arrange
      const amount = TestConstants.testAmountZero;

      // Act
      final result = CurrencyFormatter.formatWithoutDecimals(amount);

      // Assert
      expect(result, 'Rp 0');
    });

    test('should format negative amount without decimals', () {
      // Arrange
      const amount = TestConstants.testAmountNegative;

      // Act
      final result = CurrencyFormatter.formatWithoutDecimals(amount);

      // Assert
      expect(result, 'Rp -100');
    });
  });

  group('CurrencyFormatter.formatForDisplay', () {
    test('should format amount same as format method', () {
      // Arrange
      const amount = TestConstants.testAmountMedium;

      // Act
      final result = CurrencyFormatter.formatForDisplay(amount);
      final expected = CurrencyFormatter.format(amount);

      // Assert
      expect(result, expected);
    });
  });

  group('CurrencyFormatter.parse', () {
    test('should parse formatted small amount correctly', () {
      // Arrange
      const formatted = 'Rp 100,00';

      // Act
      final result = CurrencyFormatter.parse(formatted);

      // Assert
      expect(result, 100.0);
    });

    test('should parse formatted medium amount with thousand separator', () {
      // Arrange
      const formatted = 'Rp 15.000,00';

      // Act
      final result = CurrencyFormatter.parse(formatted);

      // Assert
      expect(result, 15000.0);
    });

    test('should parse formatted large amount with multiple separators', () {
      // Arrange
      const formatted = 'Rp 15.000.000,00';

      // Act
      final result = CurrencyFormatter.parse(formatted);

      // Assert
      expect(result, 15000000.0);
    });

    test('should parse amount with decimals', () {
      // Arrange
      const formatted = 'Rp 15.000,50';

      // Act
      final result = CurrencyFormatter.parse(formatted);

      // Assert
      expect(result, 15000.50);
    });

    test('should parse amount without decimals', () {
      // Arrange
      const formatted = 'Rp 15.000';

      // Act
      final result = CurrencyFormatter.parse(formatted);

      // Assert
      expect(result, 15000.0);
    });

    test('should parse amount with extra spaces', () {
      // Arrange
      const formatted = 'Rp  15.000,00';

      // Act
      final result = CurrencyFormatter.parse(formatted);

      // Assert
      expect(result, 15000.0);
    });

    test('should return null for invalid format', () {
      // Arrange
      const formatted = 'invalid';

      // Act
      final result = CurrencyFormatter.parse(formatted);

      // Assert
      expect(result, null);
    });

    test('should return null for empty string', () {
      // Arrange
      const formatted = '';

      // Act
      final result = CurrencyFormatter.parse(formatted);

      // Assert
      expect(result, null);
    });

    test('should return null for malformed currency', () {
      // Arrange
      const formatted = 'Rp 15.000,50.00';

      // Act
      final result = CurrencyFormatter.parse(formatted);

      // Assert
      expect(result, null);
    });

    test('should parse negative amount', () {
      // Arrange
      const formatted = 'Rp -100,00';

      // Act
      final result = CurrencyFormatter.parse(formatted);

      // Assert
      expect(result, -100.0);
    });
  });

  group('CurrencyFormatter - Integration tests', () {
    test('should round-trip format and parse correctly', () {
      // Arrange
      const originalAmount = TestConstants.testAmountMedium;

      // Act
      final formatted = CurrencyFormatter.format(originalAmount);
      final parsed = CurrencyFormatter.parse(formatted);

      // Assert
      expect(parsed, originalAmount);
    });

    test('should round-trip large amount format and parse correctly', () {
      // Arrange
      const originalAmount = TestConstants.testAmountLarge;

      // Act
      final formatted = CurrencyFormatter.format(originalAmount);
      final parsed = CurrencyFormatter.parse(formatted);

      // Assert
      expect(parsed, originalAmount);
    });

    test('should round-trip amount with decimals format and parse correctly', () {
      // Arrange
      const originalAmount = TestConstants.testAmountWithDecimals;

      // Act
      final formatted = CurrencyFormatter.format(originalAmount);
      final parsed = CurrencyFormatter.parse(formatted);

      // Assert
      expect(parsed, originalAmount);
    });
  });
}
