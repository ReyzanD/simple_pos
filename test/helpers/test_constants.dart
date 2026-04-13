/// Test constants for unit and integration tests
class TestConstants {
  // Product test data
  static const int testProductId = 1;
  static const String testProductName = 'Test Product';
  static const double testProductPrice = 99.99;
  static const int testProductStock = 100;
  static const int testProductCategoryId = 1;
  static const int testProductSupplierId = 1;
  static const String testProductBarcode = '1234567890';
  static const double testProductCostPrice = 50.00;

  // Additional product test data
  static const String validProductName = 'Test Product';
  static const double validProductPrice = 99.99;
  static const double validProductCostPrice = 50.00;
  static const int validProductStock = 100;
  static const String validProductBarcode = '1234567890';
  static const int validCategoryId = 1;
  static const int validSupplierId = 1;

  // Category test data
  static const String validCategoryName = 'Electronics';
  static const String validCategoryDescription = 'Electronic items';
  static const int testCategoryId = 1;
  static const String testCategoryName = 'Electronics';

  // Supplier test data
  static const String validSupplierName = 'Test Supplier';
  static const String validSupplierContact = 'John Doe';
  static const String validSupplierPhone = '1234567890';
  static const String validSupplierEmail = 'test@example.com';
  static const String validSupplierAddress = '123 Test St';
  static const int testSupplierId = 1;
  static const String testSupplierName = 'Test Supplier';

  // Pagination test data
  static const int defaultPageSize = 20;
  static const int defaultPageNumber = 1;

  // Currency format test data
  static const String validCurrencySymbol = '\$';
  static const String validLocale = 'en_US';

  // Validation test data
  static const int minProductNameLength = 3;
  static const int maxProductNameLength = 100;
  static const double minProductPrice = 0.01;
  static const double maxProductPrice = 999999.99;
  static const int minProductStock = 0;
  static const int maxProductStock = 999999;
}
