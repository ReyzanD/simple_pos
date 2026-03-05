import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import '../../features/sales/domain/entities/receipt.dart';
import '../../features/sales/domain/usecases/generate_receipt_usecase.dart';
import '../utils/logger.dart';

/// Service for managing receipts (print, share, save)
class ReceiptService {
  final GenerateReceiptUseCase _generateReceiptUseCase = GenerateReceiptUseCase();

  /// Prints the receipt
  Future<void> printReceipt(Receipt receipt) async {
    try {
      AppLogger.service('PrintReceipt', details: 'Transaction: ${receipt.transaction.id}');

      // Generate PDF
      final file = await _generateReceiptUseCase.execute(receipt);

      // Print the PDF
      await Printing.layoutPdf(
        onLayout: (format) => file.readAsBytes(),
        name: 'receipt_${receipt.transaction.id}.pdf',
      );

      AppLogger.info('Receipt printed successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to print receipt',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Shares the receipt
  Future<void> shareReceipt(Receipt receipt) async {
    try {
      AppLogger.service('ShareReceipt', details: 'Transaction: ${receipt.transaction.id}');

      // Generate PDF
      final file = await _generateReceiptUseCase.execute(receipt);

      // Share the PDF
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Receipt #${receipt.transaction.id}',
        text: 'Transaction receipt from ${receipt.storeInfo.name}',
      );

      AppLogger.info('Receipt shared successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to share receipt',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Saves the receipt to device storage
  Future<File> saveReceipt(Receipt receipt) async {
    try {
      AppLogger.service('SaveReceipt', details: 'Transaction: ${receipt.transaction.id}');

      // Generate PDF
      final tempFile = await _generateReceiptUseCase.execute(receipt);

      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory('${directory.path}/receipts');

      // Create receipts directory if it doesn't exist
      if (!await receiptsDir.exists()) {
        await receiptsDir.create(recursive: true);
      }

      // Save receipt with timestamp
      final timestamp = receipt.transaction.transactionDate
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final file = File('${receiptsDir.path}/receipt_${receipt.transaction.id}_$timestamp.pdf');

      await file.writeAsBytes(await tempFile.readAsBytes());

      AppLogger.info('Receipt saved: ${file.path}');

      return file;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to save receipt',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Gets all saved receipts
  Future<List<File>> getSavedReceipts() async {
    try {
      AppLogger.service('GetSavedReceipts');

      final directory = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory('${directory.path}/receipts');

      if (!await receiptsDir.exists()) {
        return [];
      }

      final files = await receiptsDir.list().where((entity) => entity is File).cast<File>().toList();

      // Sort by modification date (newest first)
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      AppLogger.info('Found ${files.length} saved receipts');

      return files;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get saved receipts',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Deletes a saved receipt
  Future<void> deleteReceipt(File file) async {
    try {
      AppLogger.service('DeleteReceipt', details: file.path);

      if (await file.exists()) {
        await file.delete();
        AppLogger.info('Receipt deleted: ${file.path}');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete receipt',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
