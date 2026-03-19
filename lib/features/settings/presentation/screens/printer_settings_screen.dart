import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/printer_service.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/widgets/modern_card.dart';
import '../controllers/settings_controller.dart';

/// Screen for managing Bluetooth printer settings
class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  int _selectedPaperWidth = 58; // 58mm or 80mm
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initializeAndDiscoverPrinters();
  }

  Future<void> _loadSettings() async {
    // Load paper width setting if saved
    // For now, use default
    setState(() {
      _selectedPaperWidth = 58;
    });
  }

  Future<void> _initializeAndDiscoverPrinters() async {
    setState(() {
      _isScanning = true;
    });

    final printerService = context.read<PrinterService>();

    // Initialize first
    await printerService.initialize();

    // Then discover printers
    await printerService.discoverPrinters();

    setState(() {
      _isScanning = false;
    });
  }

  Future<void> _connectPrinter(PrinterInfo printer) async {
    final printerService = context.read<PrinterService>();

    final success = await printerService.connect(printer.address);

    if (mounted) {
      if (success) {
        _showSuccessSnackBar('Terhubung ke ${printer.name}');
      } else {
        _showErrorSnackBar('Gagal terhubung ke printer');
      }
    }
  }

  Future<void> _disconnectPrinter() async {
    final printerService = context.read<PrinterService>();
    await printerService.disconnect();

    if (mounted) {
      _showSuccessSnackBar('Printer terputus');
      await _initializeAndDiscoverPrinters();
    }
  }

  Future<void> _testPrint() async {
    final printerService = context.read<PrinterService>();
    final settingsController = context.read<SettingsController>();

    if (!printerService.isConnected) {
      _showErrorSnackBar('Tidak ada printer terhubung');
      return;
    }

    final result = await printerService.printTestReceipt(
      settings: settingsController.settings,
      paperWidth: _selectedPaperWidth,
    );

    if (mounted) {
      if (result.success) {
        _showSuccessSnackBar('Test print berhasil');
      } else {
        _showErrorSnackBar(result.errorMessage ?? 'Test print gagal');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Pengaturan Printer'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<PrinterService>(
        builder: (context, printerService, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Connection status card
              ModernCard(
                padding: const EdgeInsets.all(16),
                backgroundColor: printerService.isConnected
                    ? AppTheme.successColor.withValues(alpha: 0.1)
                    : AppTheme.warningColor.withValues(alpha: 0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: printerService.isConnected
                                ? AppTheme.successColor
                                : AppTheme.warningColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            printerService.isConnected
                                ? Icons.bluetooth_connected
                                : Icons.bluetooth_disabled,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                printerService.isConnected
                                    ? 'Printer Terhubung'
                                    : 'Tidak Ada Printer Terhubung',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: printerService.isConnected
                                      ? AppTheme.successColor
                                      : AppTheme.warningColor,
                                ),
                              ),
                              if (printerService.connectedPrinter != null)
                                Text(
                                  printerService.connectedPrinter!.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (printerService.isConnected)
                          IconButton(
                            icon: const Icon(Icons.close),
                            color: AppTheme.errorColor,
                            onPressed: _disconnectPrinter,
                            tooltip: 'Putuskan',
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Paper width setting
              ModernCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Ukuran Kertas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _PaperWidthOption(
                            value: 58,
                            label: '58mm',
                            isSelected: _selectedPaperWidth == 58,
                            onTap: () {
                              setState(() {
                                _selectedPaperWidth = 58;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PaperWidthOption(
                            value: 80,
                            label: '80mm',
                            isSelected: _selectedPaperWidth == 80,
                            onTap: () {
                              setState(() {
                                _selectedPaperWidth = 80;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Available printers section
              Row(
                children: [
                  const Text(
                    'Printer Tersedia',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (_isScanning)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _initializeAndDiscoverPrinters,
                      tooltip: 'Scan Ulang',
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Printer list
              printerService.discoveredPrinters.isEmpty
                  ? ModernCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.bluetooth_searching,
                            size: 48,
                            color: AppTheme.textTertiary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tidak Ada Printer Ditemukan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pastikan Bluetooth aktif dan printer sudah dipasangkan',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textTertiary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ModernButton(
                            text: 'Scan Ulang',
                            icon: Icons.refresh,
                            onPressed: _initializeAndDiscoverPrinters,
                            backgroundColor: AppTheme.primaryColor,
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: printerService.discoveredPrinters.map((printer) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PrinterListItem(
                            printer: printer,
                            isConnected: printerService.isConnected &&
                                printerService.connectedPrinter?.address ==
                                    printer.address,
                            onConnect: () => _connectPrinter(printer),
                            onDisconnect: _disconnectPrinter,
                          ),
                        );
                      }).toList(),
                    ),

              const SizedBox(height: 16),

              // Test print button
              ModernButton(
                text: 'Test Print',
                icon: Icons.print,
                onPressed: printerService.isConnected ? _testPrint : null,
                backgroundColor: AppTheme.primaryColor,
              ),

              const SizedBox(height: 16),

              // Help card
              ModernCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.infoColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Cara Menggunakan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildHelpItem('1. Pastikan Bluetooth aktif di perangkat'),
                    _buildHelpItem('2. Pair printer thermal di pengaturan Bluetooth'),
                    _buildHelpItem('3. Pilih printer dari daftar di atas'),
                    _buildHelpItem('4. Tap "Test Print" untuk mencoba'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paper width selection option
class _PaperWidthOption extends StatelessWidget {
  final int value;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaperWidthOption({
    required this.value,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Printer list item
class _PrinterListItem extends StatelessWidget {
  final PrinterInfo printer;
  final bool isConnected;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const _PrinterListItem({
    required this.printer,
    required this.isConnected,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isConnected
                  ? AppTheme.successColor.withValues(alpha: 0.1)
                  : AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.print,
              color: isConnected ? AppTheme.successColor : AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  printer.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  printer.address,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isConnected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 14,
                    color: AppTheme.successColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Terhubung',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.successColor,
                    ),
                  ),
                ],
              ),
            )
          else
            ModernButton(
              text: 'Hubungkan',
              icon: Icons.bluetooth,
              onPressed: onConnect,
              isFullWidth: false,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
        ],
      ),
    );
  }
}
