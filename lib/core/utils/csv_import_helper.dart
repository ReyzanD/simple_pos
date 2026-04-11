import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart' as csv;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  int get totalCount => successCount + failureCount;
}

/// Product data from CSV row
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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'cost_price': costPrice,
      'stock': stock,
      'barcode': barcode,
      'sku': sku,
      'category_name': categoryName,
      'supplier_name': supplierName,
      'description': description,
    };
  }
}

/// Utility for parsing CSV files and validating product data
class CsvImportHelper {
  /// Expected CSV column headers
  static const List<String> expectedHeaders = [
    'name',
    'price',
    'cost_price',
    'stock',
    'barcode',
    'sku',
    'category',
    'supplier',
    'description',
  ];

  /// Required columns
  static const List<String> requiredColumns = [
    'name',
    'price',
    'cost_price',
    'stock',
  ];

  /// Parse CSV file and return list of product data
  static Future<List<CsvProductData>> parseCsvFile(String filePath) async {
    AppLogger.info('Parsing CSV file', tag: 'CsvImport');

    try {
      final input = await File(filePath).readAsString();
      final fields = const csv.CsvToListConverter().convert(input);

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

  /// Validate CSV headers
  static void _validateHeaders(List<String> headers) {
    final missingColumns = <String>[];
    for (final required in requiredColumns) {
      if (!headers.any((h) => h == required)) {
        missingColumns.add(required);
      }
    }

    if (missingColumns.isNotEmpty) {
      throw ValidationException(
        'Kolom wajib tidak ditemukan: ${missingColumns.join(', ')}',
        field: 'Headers',
      );
    }
  }

  /// Parse a single CSV row into product data
  static CsvProductData? _parseRow(
    List<dynamic> row,
    int rowNumber,
    List<String> headers,
  ) {
    if (row.isEmpty || row.every((cell) => cell.toString().trim().isEmpty)) {
      // Skip empty rows
      return null;
    }

    final Map<String, String> rowMap = {};
    for (int i = 0; i < headers.length && i < row.length; i++) {
      rowMap[headers[i]] = row[i].toString().trim();
    }

    // Validate required fields
    final name = rowMap['name']?.trim();
    if (name == null || name.isEmpty) {
      throw ValidationException('Nama produk wajib diisi', field: 'name');
    }

    if (name.length < 3) {
      throw ValidationException('Nama produk minimal 3 karakter', field: 'name');
    }

    if (name.length > 100) {
      throw ValidationException('Nama produk maksimal 100 karakter', field: 'name');
    }

    // Parse price
    final priceStr = rowMap['price']?.trim();
    if (priceStr == null || priceStr.isEmpty) {
      throw ValidationException('Harga wajib diisi', field: 'price');
    }
    final price = double.tryParse(priceStr);
    if (price == null || price <= 0) {
      throw ValidationException('Harga harus lebih dari 0', field: 'price');
    }

    // Parse cost price
    final costPriceStr = rowMap['cost_price']?.trim();
    if (costPriceStr == null || costPriceStr.isEmpty) {
      throw ValidationException('Harga modal wajib diisi', field: 'cost_price');
    }
    final costPrice = double.tryParse(costPriceStr) ?? 0;
    if (costPrice < 0) {
      throw ValidationException('Harga modal tidak boleh negatif', field: 'cost_price');
    }

    // Parse stock
    final stockStr = rowMap['stock']?.trim();
    if (stockStr == null || stockStr.isEmpty) {
      throw ValidationException('Stok wajib diisi', field: 'stock');
    }
    final stock = int.tryParse(stockStr);
    if (stock == null || stock < 0) {
      throw ValidationException('Stok harus bilangan bulat non-negatif', field: 'stock');
    }

    // Parse optional fields
    final barcode = rowMap['barcode']?.trim();
    final sku = rowMap['sku']?.trim();
    final categoryName = rowMap['category']?.trim();
    final supplierName = rowMap['supplier']?.trim();
    final description = rowMap['description']?.trim();

    return CsvProductData(
      name: name,
      price: price,
      costPrice: costPrice,
      stock: stock,
      barcode: barcode?.isEmpty ?? true ? null : barcode,
      sku: sku?.isEmpty ?? true ? null : sku,
      categoryName: categoryName?.isEmpty ?? true ? null : categoryName,
      supplierName: supplierName?.isEmpty ?? true ? null : supplierName,
      description: description?.isEmpty ?? true ? null : description,
      rowNumber: rowNumber,
    );
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
      AppLogger.error('Failed to pick CSV file', error: e, tag: 'CsvImport');
      throw ValidationException(
        'Gagal memilih file: ${e.toString()}',
        field: 'File',
      );
    }
  }

  /// Generate CSV template for users to download
  static String generateCsvTemplate() {
    final rows = [
      expectedHeaders,
      // Sample row
      [
        'Sample Product',
        '15000',
        '10000',
        '50',
        '8991234567890',
        'SKU-001',
        'Electronics',
        'ABC Supplier',
        'Sample product description',
      ],
    ];

    return ListToCsvConverter().convert(rows);
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

  /// Validate product data before import
  static List<String> validateProductData(CsvProductData product) {
    final errors = <String>[];

    // Name validation
    if (product.name.trim().isEmpty) {
      errors.add('Nama produk tidak boleh kosong');
    }
    if (product.name.trim().length < 3) {
      errors.add('Nama produk minimal 3 karakter');
    }
    if (product.name.trim().length > 100) {
      errors.add('Nama produk maksimal 100 karakter');
    }

    // Price validation
    if (product.price <= 0) {
      errors.add('Harga harus lebih dari 0');
    }

    // Cost price validation
    if (product.costPrice < 0) {
      errors.add('Harga modal tidak boleh negatif');
    }

    // Stock validation
    if (product.stock < 0) {
      errors.add('Stok tidak boleh negatif');
    }

    // Barcode validation (if provided)
    if (product.barcode != null && product.barcode!.isNotEmpty) {
      if (product.barcode!.length > 50) {
        errors.add('Barcode maksimal 50 karakter');
      }
    }

    return errors;
  }
}
