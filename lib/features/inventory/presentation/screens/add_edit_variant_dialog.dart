import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/entities/variant_attribute.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/modern_button.dart';

/// Dialog for adding or editing a product variant
class AddEditVariantDialog extends StatefulWidget {
  final int productId;
  final ProductVariant? existingVariant;
  final List<VariantAttribute> existingAttributes;

  const AddEditVariantDialog({
    super.key,
    required this.productId,
    this.existingVariant,
    this.existingAttributes = const [],
  });

  @override
  State<AddEditVariantDialog> createState() => _AddEditVariantDialogState();
}

class _AddEditVariantDialogState extends State<AddEditVariantDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();

  Map<String, String>? _selectedAttributes;
  final bool _isSaving = false;

  bool get _isEditing => widget.existingVariant != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      final variant = widget.existingVariant!;
      _nameController.text = variant.name;
      _priceController.text = variant.price.toString();
      _costPriceController.text = variant.costPrice.toString();
      _stockController.text = variant.stock.toString();
      _skuController.text = variant.sku ?? '';
      _barcodeController.text = variant.barcode ?? '';
      _selectedAttributes = variant.attributes != null
          ? Map<String, String>.from(variant.attributes!)
          : null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.pop(context, {
      'name': _nameController.text.trim(),
      'price': double.parse(_priceController.text),
      'costPrice': double.tryParse(_costPriceController.text) ?? 0,
      'stock': int.parse(_stockController.text),
      'sku': _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
      'barcode': _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
      'attributes': _selectedAttributes,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
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
              _isEditing ? Icons.edit : Icons.add_circle_outline,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(_isEditing ? 'Edit Varian' : 'Tambah Varian'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Varian',
                    hintText: 'Contoh: Merah, XL, Original',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama varian wajib diisi';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                // Price
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Harga Jual',
                    hintText: '0',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.sell),
                    prefixText: 'Rp ',
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Harga jual wajib diisi';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price < 0) {
                      return 'Masukkan angka yang valid';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                // Cost Price
                TextFormField(
                  controller: _costPriceController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Harga Modal',
                    hintText: '0',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.money_off),
                    prefixText: 'Rp ',
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                // Stock
                TextFormField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stok',
                    hintText: '0',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Stok wajib diisi';
                    }
                    final stock = int.tryParse(value);
                    if (stock == null || stock < 0) {
                      return 'Masukkan angka yang valid';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                // SKU
                TextFormField(
                  controller: _skuController,
                  decoration: const InputDecoration(
                    labelText: 'SKU',
                    hintText: 'Opsional',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.qr_code),
                  ),
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                // Barcode
                TextFormField(
                  controller: _barcodeController,
                  decoration: const InputDecoration(
                    labelText: 'Barcode',
                    hintText: 'Opsional',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.barcode_reader),
                  ),
                  textInputAction: TextInputAction.done,
                ),

                // Attribute selection if attributes exist
                if (widget.existingAttributes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Atribut Varian',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.existingAttributes.map((attr) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(attr.name),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          children: attr.values.map((value) {
                            final isSelected = _selectedAttributes != null &&
                                _selectedAttributes![attr.name] == value;

                            return FilterChip(
                              label: Text(value),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedAttributes ??= {};
                                  if (selected) {
                                    _selectedAttributes![attr.name] = value;
                                  } else {
                                    _selectedAttributes!.remove(attr.name);
                                  }
                                });
                              },
                              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                              checkmarkColor: AppTheme.primaryColor,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ModernButton(
          text: _isEditing ? 'Simpan' : 'Tambah',
          icon: Icons.check,
          onPressed: _isSaving ? null : _handleSave,
          isFullWidth: false,
        ),
      ],
    );
  }
}
