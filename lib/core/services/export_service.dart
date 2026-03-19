import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_pos/services/database/database_helper.dart';

/// ExportService for exporting data to CSV and Excel formats
class ExportService {
  final DatabaseHelper databaseHelper;

  ExportService({required this.databaseHelper});

  /// Export transactions to CSV
  Future<String> exportTransactionsToCsv({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await databaseHelper.database;

    String? where;
    List<dynamic> whereArgs = [];

    List<String> conditions = [];
    if (startDate != null) {
      conditions.add('created_at >= ?');
      whereArgs.add(startDate.millisecondsSinceEpoch ~/ 1000);
    }
    if (endDate != null) {
      conditions.add('created_at <= ?');
      whereArgs.add(endDate.millisecondsSinceEpoch ~/ 1000);
    }

    if (conditions.isNotEmpty) {
      where = conditions.join(' AND ');
    }

    final transactions = await db.query(
      'transactions',
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'created_at DESC',
    );

    final rows = <List<String>>[];
    rows.add([
      'ID',
      'Total',
      'Metode Pembayaran',
      'Waktu Dibuat',
    ]);

    for (var tx in transactions) {
      final createdAt = tx['created_at'] as int;
      rows.add([
        tx['id'].toString(),
        (tx['total_amount'] as num).toStringAsFixed(2),
        tx['payment_method'].toString(),
        DateTime.fromMillisecondsSinceEpoch(createdAt * 1000)
            .toLocal()
            .toString(),
      ]);
    }

    final csvString = const ListToCsvConverter().convert(rows);

    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/transactions_$timestamp.csv');
    await file.writeAsString(csvString);

    return file.path;
  }

  /// Export products to CSV
  Future<String> exportProductsToCsv() async {
    final db = await databaseHelper.database;
    final products = await db.query('products');

    final rows = <List<String>>[];
    rows.add([
      'ID',
      'Nama',
      'Harga',
      'Harga Modal',
      'Stok',
      'Barcode',
      'Kategori',
      'Pemasok',
    ]);

    for (var p in products) {
      rows.add([
        p['id'].toString(),
        p['name'].toString(),
        (p['price'] as num).toStringAsFixed(2),
        (p['cost_price'] as num?)?.toStringAsFixed(2) ?? '0',
        p['stock'].toString(),
        p['barcode']?.toString() ?? '',
        p['category_id']?.toString() ?? '',
        p['supplier_id']?.toString() ?? '',
      ]);
    }

    final csvString = const ListToCsvConverter().convert(rows);

    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/products_$timestamp.csv');
    await file.writeAsString(csvString);

    return file.path;
  }

  /// Export expenses to CSV
  Future<String> exportExpensesToCsv({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await databaseHelper.database;

    String? where;
    List<dynamic> whereArgs = [];

    List<String> conditions = [];
    if (startDate != null) {
      conditions.add('date >= ?');
      whereArgs.add(startDate.millisecondsSinceEpoch ~/ 1000);
    }
    if (endDate != null) {
      conditions.add('date <= ?');
      whereArgs.add(endDate.millisecondsSinceEpoch ~/ 1000);
    }

    if (conditions.isNotEmpty) {
      where = conditions.join(' AND ');
    }

    final expenses = await db.query(
      'expenses',
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'date DESC',
    );

    final rows = <List<String>>[];
    rows.add([
      'ID',
      'Kategori',
      'Jumlah',
      'Deskripsi',
      'Metode Pembayaran',
      'Tanggal',
    ]);

    for (var e in expenses) {
      final dateValue = e['date'] as int;
      rows.add([
        e['id'].toString(),
        e['category'].toString(),
        (e['amount'] as num).toStringAsFixed(2),
        e['description']?.toString() ?? '',
        e['payment_method'].toString(),
        DateTime.fromMillisecondsSinceEpoch(dateValue * 1000)
            .toLocal()
            .toString(),
      ]);
    }

    final csvString = const ListToCsvConverter().convert(rows);

    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/expenses_$timestamp.csv');
    await file.writeAsString(csvString);

    return file.path;
  }

  /// Export transactions to Excel
  Future<String> exportTransactionsToExcel({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await databaseHelper.database;

    String? where;
    List<dynamic> whereArgs = [];

    List<String> conditions = [];
    if (startDate != null) {
      conditions.add('created_at >= ?');
      whereArgs.add(startDate.millisecondsSinceEpoch ~/ 1000);
    }
    if (endDate != null) {
      conditions.add('created_at <= ?');
      whereArgs.add(endDate.millisecondsSinceEpoch ~/ 1000);
    }

    if (conditions.isNotEmpty) {
      where = conditions.join(' AND ');
    }

    final transactions = await db.query(
      'transactions',
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'created_at DESC',
    );

    final excel = Excel.createExcel();
    final sheet = excel['Transactions'];

    // Header
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Total'),
      TextCellValue('Metode Pembayaran'),
      TextCellValue('Waktu Dibuat'),
    ]);

    // Data
    for (var tx in transactions) {
      final createdAt = tx['created_at'] as int;
      sheet.appendRow([
        IntCellValue(tx['id'] as int),
        DoubleCellValue((tx['total_amount'] as num).toDouble()),
        TextCellValue(tx['payment_method'].toString()),
        TextCellValue(
          DateTime.fromMillisecondsSinceEpoch(createdAt * 1000)
              .toLocal()
              .toString(),
        ),
      ]);
    }

    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/transactions_$timestamp.xlsx');
    await file.writeAsBytes(excel.encode()!);

    return file.path;
  }

  /// Export products to Excel
  Future<String> exportProductsToExcel() async {
    final db = await databaseHelper.database;
    final products = await db.query('products');

    final excel = Excel.createExcel();
    final sheet = excel['Products'];

    // Header
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Nama'),
      TextCellValue('Harga'),
      TextCellValue('Harga Modal'),
      TextCellValue('Stok'),
      TextCellValue('Barcode'),
    ]);

    // Data
    for (var p in products) {
      sheet.appendRow([
        IntCellValue(p['id'] as int),
        TextCellValue(p['name'].toString()),
        DoubleCellValue((p['price'] as num).toDouble()),
        DoubleCellValue((p['cost_price'] as num?)?.toDouble() ?? 0),
        IntCellValue(p['stock'] as int),
        TextCellValue(p['barcode']?.toString() ?? ''),
      ]);
    }

    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/products_$timestamp.xlsx');
    await file.writeAsBytes(excel.encode()!);

    return file.path;
  }

  /// Share exported file
  Future<void> shareExport(String filePath) async {
    await Share.shareXFiles([XFile(filePath)]);
  }
}
