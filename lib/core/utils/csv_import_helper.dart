import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../exceptions/app_exceptions.dart';
import 'logger.dart';

/// Result of CSV import operation
class CsvImportResult {
  final int successCount;
  final int failureCount;
  final List<String> errors;
  final List<String> warnings;

  const CsvImportResult({
    required this.successCount,
    required this.failureCount,
    this.errors = const [],
    this.warnings = const [],
  });

  @override
  String toString() =>
      'CsvImportResult(success: $successCount, failure: $failureCount, errors: ${errors.length})';
}

/// Represents a product from CSV file
class CsvProductData {
  final String name;
  final double price;
  final double costPrice;
  final int stock;
  final String? barcode;
  final String? sku;
  final String? categoryName;
  final String? supplierName;
  final String? description;
  final int rowNumber;

  const CsvProductData({
    required this.name,
    required this.price,
    required this.costPrice,
    required this.stock,
    this.barcode,
    this.sku,
    this.categoryName,
    this.supplierName,
    this.description,
    required this.rowNumber,
  });

  /// Convert product to JSON
  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'costPrice': costPrice,
        'stock': stock,
        'barcode': barcode,
        'sku': sku,
        'categoryName': categoryName,
        'supplierName': supplierName,
        'description': description,
        'rowNumber': rowNumber,
      };
}

/// Helper for CSV import operations
class CsvImportHelper {
  /// Parse CSV file and return list of product data
  static Future<List<CsvProductData>> parseCsvFile(String filePath) async {
    AppLogger.info('Parsing CSV file', tag: 'CsvImport');

    try {
      final input = await File(filePath).readAsString();
      // Parse CSV manually since csv package API changed
      final fields = _parseCsvString(input);

      if (fields.isEmpty) {
        throw ValidationException('File CSV kosong', field: 'File');
      }

      // Validate headers
      final headers = fields.first.map((h) => h.toString().trim().toLowerCase()).toList();
      _validateHeaders(headers);

      // Parse product rows
      final products = <CsvProductData>[];
      final errors = <String>[];

      for (int i = 1; i < fields.length; i++) {
        final row = fields[i];
        final rowNumber = i + 1;

        try {
          final product = _parseRow(row, rowNumber, headers);
          if (product != null) {
            products.add(product);
          }
        } catch (e) {
          errors.add('Baris $rowNumber: ${e.toString()}');
        }
      }

      if (products.isEmpty) {
        throw ValidationException(
          'Tidak ada produk valid ditemukan dalam file CSV',
          field: 'Products',
        );
      }

      if (errors.isNotEmpty) {
        AppLogger.warning('CSV parsing completed with ${errors.length} errors', tag: 'CsvImport');
        for (final error in errors) {
          AppLogger.warning(error, tag: 'CsvImport');
        }
      }

      AppLogger.info('CSV parsing completed: ${products.length} products found', tag: 'CsvImport');
      return products;
    } catch (e) {
      AppLogger.error('Failed to parse CSV file', error: e);
      if (e is AppException) {
        rethrow;
      }
      throw ValidationException(
        'Gagal membaca file CSV: ${e.toString()}',
        field: 'File',
      );
    }
  }

  /// Manually parse CSV string
  static List<List<dynamic>> _parseCsvString(String input) {
    final lines = input.split('\n');
    final result = <List<dynamic>>[];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      // Handle quoted fields
      final fields = <dynamic>[];
      final regex = RegExp(r',|\n(?=(?:[^"]*"[^"]*")*[^"]*$)');
      final matches = regex.allMatches(line).toList();

      if (matches.isEmpty) {
        fields.add(line);
      } else {
        for (final match in matches) {
          String field = match.group(0)!;
          // Remove quotes and trim
          field = field.replaceAll(RegExp(r'^"|"$'), '').trim();
          fields.add(field);
        }
      }

      result.add(fields);
    }

    return result;
  }

  /// Validate CSV headers
  static void _validateHeaders(List<String> headers) {
    final requiredHeaders = [
      'name',
      'price',
      'stock',
    ];

    for (final header in requiredHeaders) {
      if (!headers.contains(header)) {
        throw ValidationException(
          'Kolom wajib "$header" tidak ditemukan dalam file CSV',
          field: 'Headers',
        );
      }
    }
  }

  /// Parse a single row from CSV
  static CsvProductData? _parseRow(
    List<dynamic> row,
    int rowNumber,
    List<String> headers,
  ) {
    try {
      // Create a map of header to value
      final data = <String, dynamic>{};
      for (int i = 0; i < headers.length && i < row.length; i++) {
        data[headers[i]] = row[i]?.toString().trim() ?? '';
      }

      // Extract required fields
      final name = data['name']?.toString().trim() ?? '';
      final priceStr = data['price']?.toString().trim() ?? '0';
      final costPriceStr = data['cost_price']?.toString().trim() ?? '0';
      final stockStr = data['stock']?.toString().trim() ?? '0';

      // Validate required fields
      if (name.isEmpty) {
        return null;
      }

      final price = double.tryParse(priceStr);
      if (price == null || price < 0) {
        throw ValidationException(
          'Harga tidak valid: "$priceStr"',
          field: 'price',
        );
      }

      final costPrice = double.tryParse(costPriceStr) ?? 0.0;
      final stock = int.tryParse(stockStr) ?? 0;

      if (stock < 0) {
        throw ValidationException(
          'Stok tidak valid: "$stockStr"',
          field: 'stock',
        );
      }

      return CsvProductData(
        name: name,
        price: price,
        costPrice: costPrice,
        stock: stock,
        barcode: data['barcode']?.toString().trim(),
        sku: data['sku']?.toString().trim(),
        categoryName: data['category_name']?.toString().trim(),
        supplierName: data['supplier_name']?.toString().trim(),
        description: data['description']?.toString().trim(),
        rowNumber: rowNumber,
      );
    } catch (e) {
      throw ValidationException(
        'Gagal mem parsing baris: ${e.toString()}',
        field: 'Row',
      );
    }
  }

  /// Validate CSV data before import
  static Future<List<String>> validateData(List<CsvProductData> products) async {
    final errors = <String>[];

    for (final csvProduct in products) {
      // Validate using the helper
      final validationErrors = validateProductData(csvProduct);
      for (final error in validationErrors) {
        errors.add('Baris ${csvProduct.rowNumber}: $error');
      }
    }

    return errors;
  }

  /// Validate a single product data
  static List<String> validateProductData(CsvProductData product) {
    final errors = <String>[];

    if (product.name.trim().isEmpty) {
      errors.add('Nama produk tidak boleh kosong');
    }

    if (product.price < 0) {
      errors.add('Harga tidak boleh negatif');
    }

    if (product.stock < 0) {
      errors.add('Stok tidak boleh negatif');
    }

    if (product.costPrice < 0) {
      errors.add('Harga pokok tidak boleh negatif');
    }

    return errors;
  }

  /// Pick CSV file using file picker
  static Future<String?> pickCsvFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
        withData: true,
      );

      if (result != null && result.files.single.path != null) {
        return result.files.single.path!;
      }

      return null;
    } catch (e) {
      AppLogger.error('Failed to pick CSV file', error: e);
      return null;
    }
  }

  /// Generate CSV template with headers
  static String generateCsvTemplate() {
    final rows = [
      [
        'name',
        'price',
        'cost_price',
        'stock',
        'barcode',
        'sku',
        'category_name',
        'supplier_name',
        'description',
      ],
      [
        'Sample Product',
        '50000',
        '40000',
        '100',
        '8991234567890',
        'SKU-001',
        'Electronics',
        'ABC Supplier',
        'Sample product description',
      ],
    ];

    // Convert to CSV manually
    final buffer = StringBuffer();
    for (final row in rows) {
      final values = row.map((v) {
        String value = v.toString();
        // Quote values that contain commas, quotes, or newlines
        if (value.contains(',') || value.contains('"') || value.contains('\n')) {
          value = '"${value.replaceAll('"', '""')}"';
        }
        return value;
      }).join(',');
      buffer.writeln(values);
    }

    return buffer.toString().trimRight();
  }

  /// Download CSV template
  static Future<void> downloadTemplate(String outputPath) async {
    try {
      final csvContent = generateCsvTemplate();
      final file = File(outputPath);
      await file.writeAsString(csvContent);
      AppLogger.info('CSV template downloaded', tag: 'CsvImport');
    } catch (e) {
      AppLogger.error('Failed to download CSV template', error: e, tag: 'CsvImport');
      throw ValidationException(
        'Gagal mengunduh template: ${e.toString()}',
        field: 'Template',
      );
    }
  }
}
