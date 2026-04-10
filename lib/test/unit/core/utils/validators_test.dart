import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import 'package:simple_pos/core/utils/validators.dart';
import '../../helpers/test_constants.dart';

void main() {
  group('Validators.validateProductName', () {
    test('should return trimmed name when valid', () {
      // Arrange
      const validName = '  Test Product  ';

      // Act
      final result = Validators.validateProductName(validName);

      // Assert
      expect(result, 'Test Product');
    });

    test('should return name when exactly 3 characters', () {
      // Arrange
      const name = 'ABC';

      // Act
      final result = Validators.validateProductName(name);

      // Assert
      expect(result, 'ABC');
    });

    test('should return name when exactly 100 characters', () {
      // Arrange
      final name = 'A' * 100;

      // Act
      final result = Validators.validateProductName(name);

      // Assert
      expect(result, name);
      expect(result.length, 100);
    });

    test('should throw ValidationException when name is empty', () {
      // Arrange
      const emptyName = '';

      // Act & Assert
      expect(
        () => Validators.validateProductName(emptyName),
        throwsA(isA<ValidationException>()
            .having((e) => e.message, 'message', 'Nama produk tidak boleh kosong')
            .having((e) => e.field, 'field', 'Nama Produk')),
      );
    });

    test('should throw ValidationException when name is only whitespace', () {
      // Arrange
      const whitespaceName = '   ';

      // Act & Assert
      expect(
        () => Validators.validateProductName(whitespaceName),
        throwsA(isA<ValidationException>()
            .having((e) => e.message, 'message', 'Nama produk tidak boleh kosong')),
      );
    });

    test('should throw ValidationException when name is less than 3 characters', () {
      // Arrange
      const shortName = TestConstants.testProductNameShort;

      // Act & Assert
      expect(
        () => Validators.validateProductName(shortName),
        throwsA(isA<ValidationException>()
            .having((e) => e.message, 'message', 'Nama produk minimal 3 karakter')),
      );
    });

    test('should throw ValidationException when name is more than 100 characters', () {
      // Arrange
      final longName = TestConstants.testProductNameLong;

      // Act & Assert
      expect(
        () => Validators.validateProductName(longName),
        throwsA(isA<ValidationException>()
            .having((e) => e.message, 'message', 'Nama produk maksimal 100 karakter')),
      );
    });
  });

  group('Validators.validatePrice', () {
    test('should return price when valid double', () {
      // Arrange
      const validPrice = TestConstants.testProductPrice;

      // Act
      final result = Validators.validatePrice(validPrice);

      // Assert
      expect(result, validPrice);
    });

    test('should convert and return valid int to double', () {
      // Arrange
      const intPrice = 15000;

      // Act
      final result = Validators.validatePrice(intPrice);

      // Assert
      expect(result, 15000.0);
    });

    test('should parse and return valid string to double', () {
      // Arrange
      const stringPrice = '15000.50';

      // Act
      final result = Validators.validatePrice(stringPrice);

      // Assert
      expect(result, 15000.50);
    });

    test('should throw ValidationException for invalid string', () {
      // Arrange
      const invalidString = 'invalid';

      // Act & Assert
      expect(
        () => Validators.validatePrice(invalidString),
        throwsA(isA<ValidationException>()
            .having((e) => e.message, 'message', 'Format harga tidak valid')),
      );
    });

    test('should throw ValidationException for null-like value', () {
      // Arrange
      final nullValue = null;

      // Act & Assert
      expect(
        () => Validators.validatePrice(nullValue),
        throwsA(isA<ValidationException>()
            .having((e) => e.message, 'message', 'Tipe harga tidak valid')),
      );
    });

    test('should throw ValidationException when price is negative', () {
      // Arrange
      const negativePrice = TestConstants.testProductPriceNegative;

      // Act & Assert
      expect(
        () => Validators.validatePrice(negativePrice),
        throwsA(isA<ValidationException>()
            .having((e) => e.message, 'message', 'Harga tidak boleh negatif')),
      );
    });

    test('should throw ValidationException when price is zero', () {
      // Arrange
      const zeroPrice = TestConstants.testProductPriceZero;

      // Act & Assert
      expect(
        () => Validators.validatePrice(zeroPrice),
        throwsA(isA<ValidationException>()
            .having((e) => e.message, 'message', 'Harga harus lebih dari 0')),
      );
    });

    test('should accept small positive values', () {
      // Arrange
      const smallPrice = 0.01;

      // Act
      final result = Validators.validatePrice(smallPrice);

      // Assert
      expect(result, 0.01);
    });
  });

  group('Validators.validateStock', () {
    test('should return stock when valid int', () {
      // Arrange
      const validStock = TestConstants.testProductStock;

      // Act
      final result = Validators.validateStock(validStock);

      // Assert
      expect(result, validStock);
    });

    test('should convert and return valid double to int', () {
      // Arrange
      const doubleStock = 50.7;

      // Act
      final result = Validators.validateStock(doubleStock);

      // Assert
      expect(result, 50);
    });

    test('should parse and return valid string to int', () {
      // Arrange
      const stringStock = '50';

      // Act
      final result = Validators.validateStock(stringStock);

      // Assert
      expect(result, 50);
    });

    test('should throw ValidationException for invalid string', () {
      // Arrange
      const invalidString = 'invalid';

      // Act & Assert
      expect(
        () => Validators.validateStock(invalidString),
        throwsA(isA<ValidationException>()
            .having((e) => e.message, 'message', 'Format stok tidak valid')),
      );
    });

    test('should throw ValidationException for null-like value', () {
      // Arrange
      final nullValue = null;

      // Act & Assert
      expect(
        () => Validators.validateStock(nullValue),
        throwsA(isA<ValidationException>()
            .having((e) => e.message, 'message', 'Tipe stok tidak valid')),
      );
    });

    test('should throw ValidationException when stock is negative', () {
      // Arrange
      const negativeStock = TestConstants.testProductStockNegative;

      // Act & Assert
      expect(
        () => Validators.validateStock(negativeStock),
        throwsA(isA<ValidationException>()
            .having((e) => e.message, 'message', 'Stok tidak boleh negatif')),
      );
    });

    test('should accept zero stock', () {
      // Arrange
      const zeroStock = TestConstants.testProductStockZero;

      // Act
      final result = Validators.validateStock(zeroStock);

      // Assert
      expect(result, 0);
    });

    test('should accept positive stock values', () {
      // Arrange
      const positiveStock = 100;

      // Act
      final result = Validators.validateStock(positiveStock);

      // Assert
      expect(result, 100);
    });

    test('should round down double values', () {
      // Arrange
      const doubleStock = 50.9;

      // Act
      final result = Validators.validateStock(doubleStock);

      // Assert
      expect(result, 50);
    });
  });

  group('Validators.validateProductId', () {
    test('should return id when valid int', () {
      // Arrange
      const validId = TestConstants.testProductId;

      // Act
      final result = Validators.validateProductId(validId);

      // Assert
      expect(result, validId);
    });

    test('should parse and return valid string to int', () {
      // Arrange
      const stringId = '123';

      // Act
      final result = Validators.validateProductId(stringId);

      // Assert
      expect(result, 123);
    });

    test('should throw ValidationException when id is null', () {
      // Arrange
      final nullId = null;

      // Act & Assert
      expect(
        () => Validators.validateProductId(nullId),
        throwsA(isA<ValidationException>()
            .having((e) => e.message, 'message', 'ID produk tidak boleh kosong')),
      );
    });

    test('should throw ValidationException when id is zero', () {
      // Arrange
      const zeroId = 0;

      // Act & Assert
      expect(
        () => Validators.validateProductId(zeroId),
        throwsA(isA<ValidationException>()
            .having((e) => e.message, 'message', 'ID produk tidak valid')),
      );
    });

    test('should throw ValidationException when id is negative', () {
      // Arrange
      const negativeId = -1;

      // Act & Assert
      expect(
        () => Validators.validateProductId(negativeId),
        throwsA(isA<ValidationException>()
            .having((e) => e.message, 'message', 'ID produk tidak valid')),
      );
    });

    test('should throw ValidationException for invalid string', () {
      // Arrange
      const invalidString = 'abc';

      // Act & Assert
      expect(
        () => Validators.validateProductId(invalidString),
        throwsA(isA<ValidationException>()
            .having((e) => e.message, 'message', 'Format ID produk tidak valid')),
      );
    });
  });

  group('Validators.isOutOfStock', () {
    test('should return true when stock is 0', () {
      // Arrange
      const stock = 0;

      // Act
      final result = Validators.isOutOfStock(stock);

      // Assert
      expect(result, true);
    });

    test('should return true when stock is negative', () {
      // Arrange
      const stock = -5;

      // Act
      final result = Validators.isOutOfStock(stock);

      // Assert
      expect(result, true);
    });

    test('should return false when stock is positive', () {
      // Arrange
      const stock = 10;

      // Act
      final result = Validators.isOutOfStock(stock);

      // Assert
      expect(result, false);
    });
  });

  group('Validators.isLowStock', () {
    test('should return true when stock is low but not out of stock', () {
      // Arrange
      const stock = TestConstants.testProductStockLow;

      // Act
      final result = Validators.isLowStock(stock);

      // Assert
      expect(result, true);
    });

    test('should return false when stock is zero', () {
      // Arrange
      const stock = 0;

      // Act
      final result = Validators.isLowStock(stock);

      // Assert
      expect(result, false);
    });

    test('should return false when stock is high', () {
      // Arrange
      const stock = 100;

      // Act
      final result = Validators.isLowStock(stock);

      // Assert
      expect(result, false);
    });
  });

  group('Validators.validateStockAvailability', () {
    test('should not throw when requested quantity is available', () {
      // Arrange
      const requested = 5;
      const available = 10;

      // Act & Assert
      expect(() => Validators.validateStockAvailability(requested, available), returnsNormally);
    });

    test('should not throw when requested equals available', () {
      // Arrange
      const requested = 10;
      const available = 10;

      // Act & Assert
      expect(() => Validators.validateStockAvailability(requested, available), returnsNormally);
    });

    test('should throw InsufficientStockException when requested exceeds available', () {
      // Arrange
      const requested = 15;
      const available = 10;

      // Act & Assert
      expect(
        () => Validators.validateStockAvailability(requested, available),
        throwsA(isA<InsufficientStockException>()
            .having((e) => e.requested, 'requested', 15)
            .having((e) => e.available, 'available', 10)),
      );
    });

    test('should throw ValidationException for zero quantity request', () {
      // Arrange
      const requested = 0;
      const available = 10;

      // Act & Assert
      expect(
        () => Validators.validateStockAvailability(requested, available),
        throwsA(isA<ValidationException>()
            .having((e) => e.message, 'message', 'Jumlah permintaan harus lebih dari 0')),
      );
    });
  });
}
