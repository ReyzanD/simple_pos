import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/utils/csv_import_helper.dart';
import '../../../../core/exceptions/app_exceptions.dart';

/// Dialog for importing products from CSV file
/// Shows progress, validation results, and allows user to confirm import
class CsvImportDialog extends StatefulWidget {
  final Function(List<CsvProductData>) onImportConfirmed;

  const CsvImportDialog({
    super.key,
    required this.onImportConfirmed,
  });

  @override
  State<CsvImportDialog> createState() => _CsvImportDialogState();
}

class _CsvImportDialogState extends State<CsvImportDialog> {
  bool _isLoading = false;
  bool _isImporting = false;
  List<CsvProductData>? _parsedProducts;
  String? _errorMessage;
  List<String> _validationErrors = [];

  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _parsedProducts = null;
      _validationErrors = [];
    });

    try {
      final filePath = await CsvImportHelper.pickCsvFile();
      if (filePath != null) {
        await _parseAndValidateFile(filePath);
      }
    } catch (e) {
      setState(() {
        if (e is AppException) {
          _errorMessage = e.userMessage;
        } else {
          _errorMessage = 'Gagal memilih file: $e';
        }
        _isLoading = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _parseAndValidateFile(String filePath) async {
    try {
      final products = await CsvImportHelper.parseCsvFile(filePath);

      // Validate all products
      final allErrors = <String>[];
      for (final product in products) {
        final errors = CsvImportHelper.validateProductData(product);
        if (errors.isNotEmpty) {
          allErrors.addAll(errors.map((e) => 'Baris ${product.rowNumber}: $e'));
        }
      }

      setState(() {
        _parsedProducts = products;
        _validationErrors = allErrors;
      });
    } catch (e) {
      setState(() {
        if (e is AppException) {
          _errorMessage = e.userMessage;
        } else {
          _errorMessage = 'Gagal memproses file: $e';
        }
      });
    }
  }

  Future<void> _confirmImport() async {
    if (_parsedProducts == null || _parsedProducts!.isEmpty) return;

    setState(() {
      _isImporting = true;
    });

    try {
      await widget.onImportConfirmed(_parsedProducts!);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mengimpor produk: $e';
        _isImporting = false;
      });
    }
  }

  void _downloadTemplate() async {
    // Show template format info
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.description,
                color: AppTheme.infoColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Format CSV')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'File CSV harus memiliki kolom berikut:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Kolom wajib (harus ada):'),
              const Text('• name - Nama produk'),
              const Text('• price - Harga jual'),
              const Text('• cost_price - Harga modal'),
              const Text('• stock - Jumlah stok'),
              const SizedBox(height: 8),
              const Text('Kolom opsional (boleh kosong):'),
              const Text('• barcode - Kode barcode'),
              const Text('• sku - Kode SKU'),
              const Text('• category - Nama kategori'),
              const Text('• supplier - Nama supplier'),
              const Text('• description - Deskripsi'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.warningColor, size: 16),
                        const SizedBox(width: 8),
                        const Text('Contoh format:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('name,price,cost_price,stock,barcode,sku,category,supplier,description'),
                    const Text('Sample Product,15000,10000,50,8991234567890,SKU-001,Electronics,ABC Supplier,Sample product description'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.upload_file,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Import Produk dari CSV'),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Memproses file...'),
                    ],
                  ),
                ),
              )
            else if (_isImporting)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Mengimpor produk...'),
                    ],
                  ),
                ),
              )
            else if (_parsedProducts != null)
              _buildResultsView()
            else
              _buildInitialView(),
          ],
        ),
      ),
      actions: [
        if (_parsedProducts == null) ...[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: _downloadTemplate,
            child: const Text('Panduan Format'),
          ),
        ] else if (_parsedProducts!.isEmpty || _validationErrors.isNotEmpty)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          )
        else ...[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: _validationErrors.isEmpty ? _confirmImport : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: const Text('Import'),
          ),
        ],
      ],
    );
  }

  Widget _buildInitialView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_errorMessage != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: AppTheme.errorColor, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(_errorMessage!, style: TextStyle(color: AppTheme.errorColor))),
              ],
            ),
          ),
        const Text('Pilih file CSV untuk diimport:'),
        const SizedBox(height: 16),
        ModernButton(
          text: 'Pilih File CSV',
          icon: Icons.file_upload,
          onPressed: _pickFile,
          backgroundColor: AppTheme.primaryColor,
        ),
        const SizedBox(height: 12),
        ModernSecondaryButton(
          text: 'Lihat Panduan Format',
          icon: Icons.help_outline,
          onPressed: _downloadTemplate,
        ),
      ],
    );
  }

  Widget _buildResultsView() {
    if (_parsedProducts == null || _parsedProducts!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
            SizedBox(height: 16),
            Text('Tidak ada produk valid ditemukan dalam file'),
          ],
        ),
      );
    }

    final validProducts = _parsedProducts!.length - _validationErrors.length;
    final hasErrors = _validationErrors.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hasErrors
                ? AppTheme.warningColor.withValues(alpha: 0.1)
                : AppTheme.successColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasErrors
                  ? AppTheme.warningColor.withValues(alpha: 0.3)
                  : AppTheme.successColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                hasErrors ? Icons.warning_amber : Icons.check_circle,
                color: hasErrors ? AppTheme.warningColor : AppTheme.successColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasErrors ? 'Ditemukan dengan error' : 'Siap diimport',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$validProducts dari ${_parsedProducts!.length} produk valid',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (hasErrors) ...[
          const SizedBox(height: 16),
          const Text('Error validasi:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _validationErrors.length > 10 ? 10 : _validationErrors.length,
              itemBuilder: (context, index) {
                final error = _validationErrors[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: AppTheme.errorColor)),
                      Expanded(child: Text(error, style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_validationErrors.length > 10)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '...dan ${_validationErrors.length - 10} error lainnya',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],

        if (!hasErrors) ...[
          const SizedBox(height: 16),
          const Text('Preview produk:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _parsedProducts!.length > 5 ? 5 : _parsedProducts!.length,
              itemBuilder: (context, index) {
                final product = _parsedProducts![index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${index + 1}. ', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                            Text(
                              'Harga: ${product.price.toStringAsFixed(0)} | Stok: ${product.stock}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_parsedProducts!.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '...dan ${_parsedProducts!.length - 5} produk lainnya',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ],
    );
  }
}
