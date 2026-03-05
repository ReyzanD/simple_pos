import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../entities/receipt.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/logger.dart';

/// Use case for generating receipts as PDF
class GenerateReceiptUseCase {
  static const double receiptWidth = 80; // 80mm thermal printer
  static const double receiptMargin = 4;

  /// Executes the use case to generate a PDF receipt
  Future<File> execute(Receipt receipt) async {
    AppLogger.useCase('GenerateReceipt', details: 'Transaction: ${receipt.transaction.id}');

    try {
      final pdf = pw.Document();
      final font = await PdfGoogleFonts.nunitoRegular();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            receiptWidth * PdfPageFormat.mm,
            receipt.transaction.items.length * 20 + 300, // Dynamic height
            marginAll: receiptMargin,
          ),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Header
                _buildHeader(receipt, font),
                pw.SizedBox(height: 10),

                // Divider
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 10),

                // Transaction Info
                _buildTransactionInfo(receipt, font),
                pw.SizedBox(height: 10),

                // Divider
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 10),

                // Items
                ..._buildItems(receipt, font),
                pw.SizedBox(height: 10),

                // Divider
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 10),

                // Totals
                ..._buildTotals(receipt, font),
                pw.SizedBox(height: 10),

                // Divider
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 10),

                // Payment Info
                _buildPaymentInfo(receipt, font),
                pw.SizedBox(height: 10),

                // Footer
                _buildFooter(receipt, font),
              ],
            );
          },
        ),
      );

      // Save PDF to file
      final dir = Directory.systemTemp;
      final file = File('${dir.path}/receipt_${receipt.transaction.id}.pdf');
      await file.writeAsBytes(await pdf.save());

      AppLogger.info('Receipt generated: ${file.path}');

      return file;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to generate receipt',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  pw.Widget _buildHeader(Receipt receipt, pw.Font font) {
    return pw.Column(
      children: [
        pw.Text(
          receipt.storeInfo.name,
          style: pw.TextStyle(
            font: font,
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          receipt.storeInfo.address,
          style: pw.TextStyle(font: font, fontSize: 8),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          'Tel: ${receipt.storeInfo.phone}',
          style: pw.TextStyle(font: font, fontSize: 8),
          textAlign: pw.TextAlign.center,
        ),
        if (receipt.storeInfo.taxId != null)
          pw.Text(
            receipt.storeInfo.taxId!,
            style: pw.TextStyle(font: font, fontSize: 8),
            textAlign: pw.TextAlign.center,
          ),
      ],
    );
  }

  pw.Widget _buildTransactionInfo(Receipt receipt, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('No. Transaksi', style: pw.TextStyle(font: font, fontSize: 8)),
            pw.Text('#${receipt.transaction.id}', style: pw.TextStyle(font: font, fontSize: 8)),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Tanggal', style: pw.TextStyle(font: font, fontSize: 8)),
            pw.Text(
              _formatDate(receipt.transaction.transactionDate),
              style: pw.TextStyle(font: font, fontSize: 8),
            ),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Kasir', style: pw.TextStyle(font: font, fontSize: 8)),
            pw.Text('POS Admin', style: pw.TextStyle(font: font, fontSize: 8)),
          ],
        ),
      ],
    );
  }

  List<pw.Widget> _buildItems(Receipt receipt, pw.Font font) {
    return [
      for (final item in receipt.transaction.items)
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    item.productName,
                    style: pw.TextStyle(font: font, fontSize: 8),
                    maxLines: 2,
                  ),
                ),
                pw.SizedBox(width: 4),
                pw.Text(
                  '${item.quantity}x',
                  style: pw.TextStyle(font: font, fontSize: 8),
                ),
                pw.SizedBox(width: 4),
                pw.Text(
                  CurrencyFormatter.format(item.subtotal),
                  style: pw.TextStyle(font: font, fontSize: 8),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
          ],
        ),
    ];
  }

  List<pw.Widget> _buildTotals(Receipt receipt, pw.Font font) {
    return [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Subtotal', style: pw.TextStyle(font: font, fontSize: 8)),
          pw.Text(CurrencyFormatter.format(receipt.transaction.subtotal), style: pw.TextStyle(font: font, fontSize: 8)),
        ],
      ),
      if (receipt.transaction.tax > 0)
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Pajak', style: pw.TextStyle(font: font, fontSize: 8)),
            pw.Text(CurrencyFormatter.format(receipt.transaction.tax), style: pw.TextStyle(font: font, fontSize: 8)),
          ],
        ),
      if (receipt.transaction.discount > 0)
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Diskon', style: pw.TextStyle(font: font, fontSize: 8)),
            pw.Text('-${CurrencyFormatter.format(receipt.transaction.discount)}', style: pw.TextStyle(font: font, fontSize: 8)),
          ],
        ),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'TOTAL',
            style: pw.TextStyle(font: font, fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            CurrencyFormatter.format(receipt.transaction.totalAmount),
            style: pw.TextStyle(font: font, fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    ];
  }

  pw.Widget _buildPaymentInfo(Receipt receipt, pw.Font font) {
    final payment = receipt.transaction.payment;
    final change = payment?.change;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Metode', style: pw.TextStyle(font: font, fontSize: 8)),
            pw.Text(
              receipt.transaction.paymentMethod.displayNameId,
              style: pw.TextStyle(font: font, fontSize: 8),
            ),
          ],
        ),
        if (payment?.cashReceived != null)
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Diterima', style: pw.TextStyle(font: font, fontSize: 8)),
              pw.Text(
                CurrencyFormatter.format(payment!.cashReceived!),
                style: pw.TextStyle(font: font, fontSize: 8),
              ),
            ],
          ),
        if (change != null && change > 0)
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Kembalian', style: pw.TextStyle(font: font, fontSize: 8)),
              pw.Text(
                CurrencyFormatter.format(change),
                style: pw.TextStyle(font: font, fontSize: 8),
              ),
            ],
          ),
      ],
    );
  }

  pw.Widget _buildFooter(Receipt receipt, pw.Font font) {
    return pw.Column(
      children: [
        pw.Text(
          'Terima kasih atas kunjungan Anda!',
          style: pw.TextStyle(font: font, fontSize: 8),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Barang yang sudah dibeli tidak dapat ditukar/dikembalikan',
          style: pw.TextStyle(font: font, fontSize: 6),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          _formatDate(receipt.printedAt),
          style: pw.TextStyle(font: font, fontSize: 6),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
