import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../../core/theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../inventory/domain/entities/category.dart' as entities;
import '../../../inventory/domain/entities/supplier.dart';
import '../controllers/category_controller.dart';
import '../controllers/supplier_controller.dart';

/// Dialog for adding a new product
class AddProductDialog extends StatefulWidget {
  final Future<bool> Function({
    required String name,
    required double price,
    required double costPrice,
    required int stock,
    int? categoryId,
    int? supplierId,
    String? barcode,
    String? imagePath,
    bool hasVariants,
  }) onAdd;

  final List<entities.Category> categories;
  final List<Supplier> suppliers;
  final String? initialBarcode;

  const AddProductDialog({
    super.key,
    required this.onAdd,
    required this.categories,
    required this.suppliers,
    this.initialBarcode,
  });

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _barcodeController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isSubmitting = false;
  String? _errorMessage;
  int? _selectedCategoryId;
  int? _selectedSupplierId;
  File? _imageFile;
  bool _hasVariants = false;

  // Local copy of categories that can be updated when a new category is added
  late List<entities.Category> _categories;
  // Local copy of suppliers that can be updated when a new supplier is added
  late List<Supplier> _suppliers;

  @override
  void initState() {
    super.initState();
    // Initialize local categories and suppliers lists
    _categories = widget.categories;
    _suppliers = widget.suppliers;
    // Pre-fill barcode if provided
    if (widget.initialBarcode != null) {
      _barcodeController.text = widget.initialBarcode!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memilih gambar: $e';
        });
      }
    }
  }

  Future<void> _showAddCategoryDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
              child: Icon(
                Icons.category,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Kategori Baru'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Kategori',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama kategori wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi (Opsional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final categoryController = context.read<CategoryController>();
                final name = nameController.text.trim();
                final description = descController.text.trim().isEmpty
                    ? null
                    : descController.text.trim();

                // Create new category
                final newCategory = entities.Category(
                  id: 0, // ID will be assigned by database
                  name: name,
                  description: description,
                  createdAt: DateTime.now(),
                );

                final success = await categoryController.addCategory(newCategory);

                if (success && dialogContext.mounted) {
                  Navigator.pop(dialogContext, true);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      // Refresh categories from controller and select the newly added one
      final categoryController = context.read<CategoryController>();
      setState(() {
        _categories = categoryController.categories;
        // Select the newly added category (last one in the list)
        if (_categories.isNotEmpty) {
          _selectedCategoryId = _categories.last.id;
        }
      });
    }
  }

  Future<void> _showAddSupplierDialog() async {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.local_shipping,
                color: AppTheme.secondaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Pemasok Baru'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Pemasok',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama pemasok wajib diisi';
                  }
                  if (value.trim().length < 2) {
                    return 'Nama pemasok minimal 2 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: contactController,
                decoration: InputDecoration(
                  labelText: 'Kontak (Opsional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Telepon (Opsional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final supplierController = context.read<SupplierController>();
                final name = nameController.text.trim();
                final contactPerson = contactController.text.trim().isEmpty
                    ? null
                    : contactController.text.trim();
                final phone = phoneController.text.trim().isEmpty
                    ? null
                    : phoneController.text.trim();

                // Create new supplier
                final newSupplier = Supplier(
                  id: 0, // ID will be assigned by database
                  name: name,
                  contactPerson: contactPerson,
                  phone: phone,
                  createdAt: DateTime.now(),
                );

                final success = await supplierController.addSupplier(newSupplier);

                if (success && dialogContext.mounted) {
                  Navigator.pop(dialogContext, true);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      // Refresh suppliers from controller and select the newly added one
      final supplierController = context.read<SupplierController>();
      setState(() {
        _suppliers = supplierController.suppliers;
        // Select the newly added supplier (last one in the list)
        if (_suppliers.isNotEmpty) {
          _selectedSupplierId = _suppliers.last.id;
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    // Clear previous error
    setState(() => _errorMessage = null);

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final name = _nameController.text.trim();
      final price = double.tryParse(_priceController.text) ?? 0.0;
      final costPrice = double.tryParse(_costPriceController.text) ?? 0.0;
      final stock = int.tryParse(_stockController.text) ?? 0;
      final barcode = _barcodeController.text.trim().isEmpty
          ? null
          : _barcodeController.text.trim();
      final imagePath = _imageFile?.path;

      final success = await widget.onAdd(
        name: name,
        price: price,
        costPrice: costPrice,
        stock: stock,
        categoryId: _selectedCategoryId,
        supplierId: _selectedSupplierId,
        barcode: barcode,
        imagePath: imagePath,
        hasVariants: _hasVariants,
      );

      if (!success && mounted) {
        setState(() => _errorMessage = 'Gagal menambahkan produk');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e is AppException
              ? e.userMessage
              : 'Terjadi kesalahan yang tidak diketahui';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Product'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppTheme.errorColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: AppTheme.errorColor, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.borderColor,
                      width: 2,
                    ),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _imageFile!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 48,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to add product image',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  try {
                    Validators.validateProductName(value ?? '');
                    return null;
                  } on ValidationException catch (e) {
                    return e.message;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (Rp)',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  try {
                    Validators.validatePrice(value ?? '');
                    return null;
                  } on ValidationException catch (e) {
                    return e.message;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Initial Stock Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  try {
                    Validators.validateStock(value ?? '');
                    return null;
                  } on ValidationException catch (e) {
                    return e.message;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costPriceController,
                decoration: const InputDecoration(
                  labelText: 'Harga Modal (Rp)',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga modal wajib diisi';
                  }
                  final costPrice = double.tryParse(value);
                  if (costPrice == null || costPrice < 0) {
                    return 'Harga modal tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                // ignore: deprecated_member_use
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: AppTheme.primaryColor,
                    ),
                    onPressed: _showAddCategoryDialog,
                    tooltip: 'Tambah Kategori Baru',
                  ),
                ),
                items: [
                  DropdownMenuItem<int>(
                    value: null,
                    child: Text(
                      'Tanpa Kategori',
                      style: TextStyle(color: AppTheme.textTertiary),
                    ),
                  ),
                  ..._categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                // ignore: deprecated_member_use
                value: _selectedSupplierId,
                decoration: InputDecoration(
                  labelText: 'Pemasok',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: AppTheme.secondaryColor,
                    ),
                    onPressed: _showAddSupplierDialog,
                    tooltip: 'Tambah Pemasok Baru',
                  ),
                ),
                items: [
                  DropdownMenuItem<int>(
                    value: null,
                    child: Text(
                      'Tanpa Pemasok',
                      style: TextStyle(color: AppTheme.textTertiary),
                    ),
                  ),
                  ..._suppliers.map((supplier) {
                    return DropdownMenuItem<int>(
                      value: supplier.id,
                      child: Text(supplier.name),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSupplierId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _barcodeController,
                decoration: const InputDecoration(
                  labelText: 'Barcode (Opsional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('Produk ini memiliki varian'),
                subtitle: const Text(
                  'Aktifkan untuk mengatur varian seperti ukuran, warna, dll setelah produk dibuat',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                value: _hasVariants,
                onChanged: (value) {
                  setState(() {
                    _hasVariants = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
