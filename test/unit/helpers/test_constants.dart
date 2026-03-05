/// Test constants for unit tests
class TestConstants {
  // Product test data
  static const int testProductId = 1;
  static const String testProductName = 'Test Product';
  static const String testProductNameShort = 'AB'; // Invalid (< 3 chars)
  static final String testProductNameLong = 'A' * 101; // Invalid (> 100 chars)
  static const double testProductPrice = 15000.0;
  static const double testProductPriceZero = 0.0;
  static const double testProductPriceNegative = -100.0;
  static const int testProductStock = 50;
  static const int testProductStockZero = 0;
  static const int testProductStockLow = 5;
  static const int testProductStockNegative = -10;

  // Currency test data
  static const double testAmountSmall = 100.0;
  static const double testAmountMedium = 15000.0;
  static const double testAmountLarge = 15000000.0;
  static const double testAmountWithDecimals = 15000.50;
  static const double testAmountZero = 0.0;
  static const double testAmountNegative = -100.0;

  // Cart test data
  static const int testDefaultQuantity = 1;
  static const int testQuantityMultiple = 5;
  static const int testQuantityExceedsStock = 100;
}

/// Test utility class for common test operations
class TestHelpers {
  /// Creates a test product map
  static Map<String, dynamic> createTestProductMap({
    int? id,
    String name = TestConstants.testProductName,
    double price = TestConstants.testProductPrice,
    int stock = TestConstants.testProductStock,
  }) {
    return {
      'id': ?id,
      'name': name,
      'price': price,
      'stock': stock,
    };
  }

  /// Creates a list of test product maps
  static List<Map<String, dynamic>> createTestProductList({int count = 3}) {
    return List.generate(
      count,
      (index) => createTestProductMap(
        id: index + 1,
        name: '${TestConstants.testProductName} ${index + 1}',
        price: TestConstants.testProductPrice * (index + 1),
        stock: TestConstants.testProductStock * (index + 1),
      ),
    );
  }
}
