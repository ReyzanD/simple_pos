import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/domain/repositories/product_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/csv_import_helper.dart';
import '../../../../core/services/audit_logger.dart';

/// Use case for importing products from CSV file
/// Handles validation, duplicate checking, and batch insertion
class ImportProductsFromCsvUseCase {
  final ProductRepository productRepository;

  ImportProductsFromCsvUseCase({
    required this.productRepository,
  });

  /// Execute CSV import
  /// Returns number of successfully imported products
  Future<int> execute({
    required List<CsvProductData> products,
    required String username,
    String? userId,
  }) async {
    AppLogger.info('Starting CSV import: ${products.length} products', tag: 'CsvImport');

    if (products.isEmpty) {
      throw ValidationException('Tidak ada produk untuk diimport', field: 'Products');
    }

    int successCount = 0;
    int failureCount = 0;
    final errors = <String>[];

    for (final csvProduct in products) {
      try {
        // Check for duplicates by name and barcode
        final existingProducts = await productRepository.getProducts();
        final duplicateByName = existingProducts.any(
          (p) => p.name.toLowerCase() == csvProduct.name.toLowerCase(),
        );
        final duplicateByBarcode = csvProduct.barcode != null &&
            csvProduct.barcode!.isNotEmpty &&
            existingProducts.any((p) => p.barcode == csvProduct.barcode);

        if (duplicateByName) {
          errors.add('Baris ${csvProduct.rowNumber}: Produk "${csvProduct.name}" sudah ada');
          failureCount++;
          continue;
        }

        if (duplicateByBarcode) {
          errors.add('Baris ${csvProduct.rowNumber}: Barcode "${csvProduct.barcode}" sudah digunakan');
          failureCount++;
          continue;
        }

        // Create product entity
        final product = Product(
          name: csvProduct.name,
          price: csvProduct.price,
          stock: csvProduct.stock,
          barcode: csvProduct.barcode,
          costPrice: csvProduct.costPrice,
        );

        // Add to repository
        await productRepository.addProduct(product);
        successCount++;

        // Log the creation
        await AuditLogger.instance.logProductCreated(
          username: username,
          userId: userId,
          productName: product.name,
          productId: product.id!,
        );

        AppLogger.debug('Product imported: ${product.name} (ID: ${product.id})', tag: 'CsvImport');
      } catch (e) {
        errors.add('Baris ${csvProduct.rowNumber}: ${e.toString()}');
        failureCount++;
        AppLogger.error('Failed to import product',
            error: e,
            tag: 'CsvImport');
      }
    }

    AppLogger.info('CSV import completed: $successCount success, $failureCount failed', tag: 'CsvImport');

    if (failureCount > 0) {
      final errorMsg = 'Import selesai dengan $successCount berhasil dan $failureCount gagal. '
          'Error:\n${errors.take(10).join('\n')}${errors.length > 10 ? '\n...dan ${errors.length - 10} error lainnya' : ''}';
      throw ValidationException(errorMsg, field: 'Import Result');
    }

    return successCount;
  }

  /// Validate CSV data before import
  /// Returns list of validation errors
  Future<List<String>> validateData(List<CsvProductData> products) async {
    final errors = <String>[];
    final existingProducts = await productRepository.getProducts();

    for (final csvProduct in products) {
      // Validate using the helper
      final validationErrors = CsvImportHelper.validateProductData(csvProduct);
      for (final error in validationErrors) {
        errors.add('Baris ${csvProduct.rowNumber}: $error');
      }

      // Check for duplicates
      final duplicateByName = existingProducts.any(
        (p) => p.name.toLowerCase() == csvProduct.name.toLowerCase(),
      );
      if (duplicateByName) {
        errors.add('Baris ${csvProduct.rowNumber}: Produk "${csvProduct.name}" sudah ada');
      }

      final duplicateByBarcode = csvProduct.barcode != null &&
          csvProduct.barcode!.isNotEmpty &&
          existingProducts.any((p) => p.barcode == csvProduct.barcode);
      if (duplicateByBarcode) {
        errors.add('Baris ${csvProduct.rowNumber}: Barcode "${csvProduct.barcode}" sudah digunakan');
      }
    }

    return errors;
  }
}
