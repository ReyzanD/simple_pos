import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:simple_pos/core/presentation/widgets/barcode_scanner_screen.dart';

void main() {
  group('BarcodeFormatExtension', () {
    test('should return correct format name for EAN-13', () {
      final barcode = Barcode(
        rawValue: '1234567890128',
        format: BarcodeFormat.ean13,
      );
      expect(barcode.getFormatName(), 'EAN-13');
    });

    test('should return correct format name for EAN-8', () {
      final barcode = Barcode(
        rawValue: '12345678',
        format: BarcodeFormat.ean8,
      );
      expect(barcode.getFormatName(), 'EAN-8');
    });

    test('should return correct format name for UPC-A', () {
      final barcode = Barcode(
        rawValue: '123456789012',
        format: BarcodeFormat.upcA,
      );
      expect(barcode.getFormatName(), 'UPC-A');
    });

    test('should return correct format name for UPC-E', () {
      final barcode = Barcode(
        rawValue: '01234567',
        format: BarcodeFormat.upcE,
      );
      expect(barcode.getFormatName(), 'UPC-E');
    });

    test('should return correct format name for Code 128', () {
      final barcode = Barcode(
        rawValue: 'ABC123',
        format: BarcodeFormat.code128,
      );
      expect(barcode.getFormatName(), 'Code 128');
    });

    test('should return correct format name for Code 39', () {
      final barcode = Barcode(
        rawValue: 'ABC123',
        format: BarcodeFormat.code39,
      );
      expect(barcode.getFormatName(), 'Code 39');
    });

    test('should return correct format name for Code 93', () {
      final barcode = Barcode(
        rawValue: 'ABC123',
        format: BarcodeFormat.code93,
      );
      expect(barcode.getFormatName(), 'Code 93');
    });

    test('should return correct format name for DataMatrix', () {
      final barcode = Barcode(
        rawValue: 'DATA123',
        format: BarcodeFormat.dataMatrix,
      );
      expect(barcode.getFormatName(), 'DataMatrix');
    });

    test('should return correct format name for PDF417', () {
      final barcode = Barcode(
        rawValue: 'PDF123',
        format: BarcodeFormat.pdf417,
      );
      expect(barcode.getFormatName(), 'PDF417');
    });

    test('should return correct format name for Aztec', () {
      final barcode = Barcode(
        rawValue: 'AZTEC123',
        format: BarcodeFormat.aztec,
      );
      expect(barcode.getFormatName(), 'Aztec');
    });

    test('should return correct format name for Codabar', () {
      final barcode = Barcode(
        rawValue: 'CODABAR',
        format: BarcodeFormat.codabar,
      );
      expect(barcode.getFormatName(), 'Codabar');
    });

    test('should return correct format name for ITF-14', () {
      final barcode = Barcode(
        rawValue: 'ITF12345678901',
        format: BarcodeFormat.itf14,
      );
      expect(barcode.getFormatName(), 'ITF-14');
    });

    test('should return enum name for unknown formats', () {
      final barcode = Barcode(
        rawValue: 'UNKNOWN',
        format: BarcodeFormat.unknown,
      );
      expect(barcode.getFormatName(), 'unknown');
    });

    test('should handle qr code format', () {
      final barcode = Barcode(
        rawValue: 'QR123',
        format: BarcodeFormat.qrCode,
      );
      expect(barcode.getFormatName(), 'qrCode');
    });
  });

  group('ScannerMode', () {
    test('should have instant mode value', () {
      expect(ScannerMode.instant, isNotNull);
    });

    test('should have preview mode value', () {
      expect(ScannerMode.preview, isNotNull);
    });

    test('should have continuous mode value', () {
      expect(ScannerMode.continuous, isNotNull);
    });

    test('should have three distinct modes', () {
      final modes = ScannerMode.values;
      expect(modes.length, 3);
      expect(modes, contains(ScannerMode.instant));
      expect(modes, contains(ScannerMode.preview));
      expect(modes, contains(ScannerMode.continuous));
    });
  });
}
