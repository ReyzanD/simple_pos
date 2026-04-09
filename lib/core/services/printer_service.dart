import 'package:flutter/foundation.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../../features/sales/domain/entities/transaction.dart';
import '../../features/sales/domain/entities/payment_method.dart';
import '../../features/settings/domain/entities/settings.dart';
import '../../features/shifts/domain/entities/shift.dart';

/// Result of a print operation
class PrintResult {
  final bool success;
  final String? errorMessage;

  const PrintResult({
    required this.success,
    this.errorMessage,
  });

  factory PrintResult.success() => const PrintResult(success: true);

  factory PrintResult.failure(String message) =>
      PrintResult(success: false, errorMessage: message);
}

/// Information about a discovered printer
class PrinterInfo {
  final BluetoothInfo device;
  final bool isConnected;

  const PrinterInfo({
    required this.device,
    required this.isConnected,
  });

  String get name => device.name;
  String get address => device.macAdress;

  @override
  String toString() => 'PrinterInfo(name: $name, address: $address)';
}

/// Service for managing Bluetooth thermal printers and printing receipts
class PrinterService extends ChangeNotifier {
  bool _isConnected = false;
  List<BluetoothInfo> _discoveredPrinters = [];
  String? _lastError;
  String? _connectedPrinterAddress;

  // Getters
  bool get isConnected => _isConnected;
  PrinterInfo? get connectedPrinter {
    if (_connectedPrinterAddress == null) return null;
    final device = _discoveredPrinters
        .where((p) => p.macAdress == _connectedPrinterAddress)
        .firstOrNull;
    if (device == null) return null;
    return PrinterInfo(device: device, isConnected: true);
  }

  bool get isScanning => false; // Simplified - scanning is fast with this package
  List<PrinterInfo> get discoveredPrinters =>
      _discoveredPrinters.map((p) => PrinterInfo(
        device: p,
        isConnected: p.macAdress == _connectedPrinterAddress,
      )).toList();
  String? get lastError => _lastError;

  /// Initialize the printer service
  Future<bool> initialize() async {
    try {
      // Check if bluetooth is enabled
      final enabled = await PrintBluetoothThermal.bluetoothEnabled;
      if (!enabled) {
        _setError('Bluetooth not enabled');
        return false;
      }

      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to initialize printer service: $e');
      return false;
    }
  }

  /// Discover available Bluetooth printers
  Future<List<PrinterInfo>> discoverPrinters() async {
    try {
      _clearError();
      notifyListeners();

      // Get paired/bonded bluetooth printers
      final printers = await PrintBluetoothThermal.pairedBluetooths;

      _discoveredPrinters = printers;
      notifyListeners();

      return discoveredPrinters;
    } catch (e) {
      _setError('Failed to discover printers: $e');
      notifyListeners();
      return [];
    }
  }

  /// Connect to a Bluetooth printer
  Future<bool> connect(String macAddress) async {
    try {
      _clearError();

      // Disconnect existing connection if any
      if (_isConnected) {
        await disconnect();
      }

      // Create connection - note the parameter name is macPrinterAddress
      final connected = await PrintBluetoothThermal.connect(
        macPrinterAddress: macAddress,
      );

      if (connected) {
        _isConnected = true;
        _connectedPrinterAddress = macAddress;
        notifyListeners();
        return true;
      } else {
        _setError('Failed to connect to printer');
        return false;
      }
    } catch (e) {
      _setError('Failed to connect to printer: $e');
      notifyListeners();
      return false;
    }
  }

  /// Disconnect from the current printer
  Future<void> disconnect() async {
    try {
      // disconnect is a property, not a method
      await PrintBluetoothThermal.disconnect;
      _isConnected = false;
      _connectedPrinterAddress = null;
      notifyListeners();
    } catch (e) {
      _setError('Error disconnecting: $e');
      _isConnected = false;
      _connectedPrinterAddress = null;
      notifyListeners();
    }
  }

  /// Print a receipt
  Future<PrintResult> printReceipt({
    required Transaction transaction,
    required Settings settings,
    Shift? shift,
    double? cashReceived,
    double? change,
    int paperWidth = 58, // 58mm or 80mm
  }) async {
    if (!_isConnected || _connectedPrinterAddress == null) {
      return PrintResult.failure('No printer connected');
    }

    try {
      // Generate receipt bytes
      final bytes = await _generateReceipt(
        transaction: transaction,
        settings: settings,
        shift: shift,
        cashReceived: cashReceived,
        change: change,
        paperWidth: paperWidth,
      );

      // Send to printer
      final success = await PrintBluetoothThermal.writeBytes(bytes);

      if (success) {
        return PrintResult.success();
      } else {
        return PrintResult.failure('Failed to send data to printer');
      }
    } catch (e) {
      return PrintResult.failure('Print failed: $e');
    }
  }

  /// Print a test receipt
  Future<PrintResult> printTestReceipt({
    required Settings settings,
    int paperWidth = 58,
  }) async {
    if (!_isConnected || _connectedPrinterAddress == null) {
      return PrintResult.failure('No printer connected');
    }

    try {
      final bytes = await _generateTestReceipt(
        settings: settings,
        paperWidth: paperWidth,
      );

      final success = await PrintBluetoothThermal.writeBytes(bytes);

      if (success) {
        return PrintResult.success();
      } else {
        return PrintResult.failure('Test print failed');
      }
    } catch (e) {
      return PrintResult.failure('Test print failed: $e');
    }
  }

  /// Generate receipt bytes for thermal printer
  Future<Uint8List> _generateReceipt({
    required Transaction transaction,
    required Settings settings,
    Shift? shift,
    double? cashReceived,
    double? change,
    required int paperWidth,
  }) async {
    final buffer = StringBuffer();

    // Center alignment for header
    buffer.write(_alignCenter(settings.businessInfo.name, paperWidth));
    buffer.write('\n');

    if (settings.businessInfo.address.isNotEmpty) {
      buffer.write(_alignCenter(settings.businessInfo.address, paperWidth));
      buffer.write('\n');
    }

    if (settings.businessInfo.phone.isNotEmpty) {
      buffer.write(_alignCenter('Tel: ${settings.businessInfo.phone}', paperWidth));
      buffer.write('\n');
    }

    buffer.write(_divider(paperWidth));
    buffer.write('\n');

    // Transaction info
    buffer.write('Tanggal: ${_formatDate(transaction.transactionDate)}\n');
    buffer.write('Jam: ${_formatTime(transaction.transactionDate)}\n');

    if (transaction.id != null) {
      buffer.write('No. Transaksi: #${transaction.id}\n');
    }

    if (shift != null && shift.id != null) {
      buffer.write('Shift: #${shift.id}\n');
    }

    buffer.write(_divider(paperWidth));
    buffer.write('\n');

    // Calculate column widths
    final nameWidth = (paperWidth * 0.5).floor();
    final qtyWidth = 6;
    final priceWidth = paperWidth - nameWidth - qtyWidth - 4; // 4 for spaces

    // Items header
    buffer.write(
      '${_padRight('ITEM', nameWidth)} ${_padLeft('QTY', qtyWidth)} ${_padLeft('TOTAL', priceWidth)}\n',
    );

    for (final item in transaction.items) {
      final itemName = _truncateText(item.productName, nameWidth);
      final price = _formatCurrency(item.subtotal);

      buffer.write(
        '${_padRight(itemName, nameWidth)} ${_padLeft('${item.quantity}', qtyWidth)} ${_padLeft(price, priceWidth)}\n',
      );
    }

    buffer.write(_divider(paperWidth));
    buffer.write('\n');

    // Totals
    buffer.write(
      '${_padRight('Subtotal', paperWidth - 15)}${_padLeft(_formatCurrency(transaction.subtotal), 15)}\n',
    );

    if (transaction.tax > 0) {
      buffer.write(
        '${_padRight('Pajak (${(settings.taxRate * 100).toStringAsFixed(0)}%)', paperWidth - 15)}${_padLeft(_formatCurrency(transaction.tax), 15)}\n',
      );
    }

    if (transaction.discount > 0) {
      buffer.write(
        '${_padRight('Diskon', paperWidth - 15)}${_padLeft('-${_formatCurrency(transaction.discount)}', 15)}\n',
      );
    }

    buffer.write(_divider(paperWidth, ch: '='));
    buffer.write('\n');

    // Total (bold emulation by printing twice)
    buffer.write(
      '${_padRight('TOTAL', paperWidth - 15)}${_padLeft(_formatCurrency(transaction.totalAmount), 15)}\n',
    );

    buffer.write(_divider(paperWidth, ch: '='));
    buffer.write('\n');

    // Payment info
    buffer.write(
      '${_padRight('Metode', paperWidth - 15)}${_padLeft(_getPaymentMethodName(transaction.paymentMethod), 15)}\n',
    );

    if (cashReceived != null && cashReceived > 0) {
      buffer.write(
        '${_padRight('Tunai', paperWidth - 15)}${_padLeft(_formatCurrency(cashReceived), 15)}\n',
      );
    }

    if (change != null && change >= 0) {
      buffer.write(
        '${_padRight('Kembalian', paperWidth - 15)}${_padLeft(_formatCurrency(change), 15)}\n',
      );
    }

    buffer.write('\n');
    buffer.write(_divider(paperWidth, ch: '.'));
    buffer.write('\n');

    // Footer
    buffer.write(_alignCenter(settings.receiptFooter, paperWidth));
    buffer.write('\n\n\n');

    return Uint8List.fromList(buffer.toString().codeUnits);
  }

  /// Generate a test receipt for printer verification
  Future<Uint8List> _generateTestReceipt({
    required Settings settings,
    required int paperWidth,
  }) async {
    final buffer = StringBuffer();

    buffer.write(_alignCenter('TEST PRINT', paperWidth));
    buffer.write('\n\n');

    if (settings.businessInfo.name.isNotEmpty) {
      buffer.write(_alignCenter(settings.businessInfo.name, paperWidth));
      buffer.write('\n');
    }

    buffer.write(_divider(paperWidth));
    buffer.write('\n');

    buffer.write('Date: ${_formatDate(DateTime.now())}\n');
    buffer.write('Time: ${_formatTime(DateTime.now())}\n');

    buffer.write(_divider(paperWidth));
    buffer.write('\n');

    // Test items
    final nameWidth = (paperWidth * 0.5).floor();
    final qtyWidth = 6;
    final priceWidth = paperWidth - nameWidth - qtyWidth - 4;

    buffer.write(
      '${_padRight('TEST ITEM 1', nameWidth)} ${_padLeft('2', qtyWidth)} ${_padLeft('20,000', priceWidth)}\n',
    );
    buffer.write(
      '${_padRight('TEST ITEM 2', nameWidth)} ${_padLeft('1', qtyWidth)} ${_padLeft('15,000', priceWidth)}\n',
    );

    buffer.write(_divider(paperWidth));
    buffer.write('\n');

    buffer.write(
      '${_padRight('TOTAL', paperWidth - 15)}${_padLeft('35,000', 15)}\n',
    );

    buffer.write('\n');
    buffer.write(_alignCenter('Test berhasil!', paperWidth));
    buffer.write('\n\n\n');

    return Uint8List.fromList(buffer.toString().codeUnits);
  }

  /// Format date for receipt
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  /// Format time for receipt
  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Format currency for receipt (simplified format)
  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return formatted;
  }

  /// Get payment method display name
  String _getPaymentMethodName(PaymentMethod method) {
    return method.displayName;
  }

  /// Truncate text to fit in column
  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - 1);
  }

  /// Pad string to the right
  String _padRight(String text, int width) {
    if (text.length >= width) return text.substring(0, width);
    return text.padRight(width);
  }

  /// Pad string to the left
  String _padLeft(String text, int width) {
    if (text.length >= width) return text.substring(0, width);
    return text.padLeft(width);
  }

  /// Center align text
  String _alignCenter(String text, int width) {
    if (text.length >= width) return text.substring(0, width);
    final padding = (width - text.length) / 2;
    final leftPadding = padding.floor();
    final rightPadding = padding.ceil();
    return ' ' * leftPadding + text + ' ' * rightPadding;
  }

  /// Create a divider line
  String _divider(int width, {String ch = '-'}) {
    return ch * width;
  }

  /// Set error message
  void _setError(String error) {
    _lastError = error;
  }

  /// Clear error message
  void _clearError() {
    _lastError = null;
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
