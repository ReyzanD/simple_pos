import 'package:flutter/material.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/product_image_picker.dart';
import '../../../inventory/domain/entities/category.dart' as entities;
import '../../../inventory/domain/entities/supplier.dart';

// THE MODULAR PIECES
import '../widgets/brutal_form_inputs.dart';
import '../widgets/brutal_auxiliary_dialogs.dart';
import '../widgets/add_product_components.dart';

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
  })
  onAdd;
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

  int? _selectedCategoryId;
  int? _selectedSupplierId;
  String? _imagePath;
  final bool _hasVariants = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Auto-fill barcode if provided
    if (widget.initialBarcode != null) {
      _barcodeController.text = widget.initialBarcode!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 750),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusLarge),
          border: Border.all(color: Colors.black, width: 5),
          boxShadow: NeoBrutalTheme.chunkyShadow,
        ),
        child: Column(
          children: [
            const AddProductHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildForm(),
              ),
            ),
            AddProductActions(
              isSubmitting: _isSubmitting,
              onCancel: () => Navigator.pop(context),
              onSave: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          ProductImagePicker(
            currentImagePath: _imagePath,
            onImageChanged: (p) => setState(() => _imagePath = p),
            size: 120,
          ),
          const SizedBox(height: 24),

          // NAME
          BrutalTextFormField(
            controller: _nameController,
            label: 'NAMA PRODUK',
            icon: Icons.label,
            themeColor: NeoBrutalTheme.primary,
          ),
          const SizedBox(height: 16),

          // PRICE & COST ROW
          Row(
            children: [
              Expanded(
                child: BrutalTextFormField(
                  controller: _priceController,
                  label: 'HARGA',
                  icon: Icons.sell,
                  themeColor: AppTheme.successColor,
                  prefixText: 'Rp ',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BrutalTextFormField(
                  controller: _costPriceController,
                  label: 'MODAL',
                  icon: Icons.money,
                  themeColor: NeoBrutalTheme.secondary,
                  prefixText: 'Rp ',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // STOCK
          BrutalTextFormField(
            controller: _stockController,
            label: 'STOK',
            icon: Icons.inventory,
            themeColor: AppTheme.infoColor,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // ✅ ADD THIS: BARCODE FIELD
          BrutalTextFormField(
            controller: _barcodeController,
            label: 'BARCODE',
            icon: Icons.qr_code_scanner_rounded,
            themeColor: AppTheme.warningColor,
            hintText: 'Opsional',
          ),
          const SizedBox(height: 16),

          // CATEGORY
          BrutalDropdownField<int>(
            label: 'KATEGORI',
            value: _selectedCategoryId,
            prefixIcon: Icons.category,
            color: NeoBrutalTheme.primary,
            onAddPressed: () => _showSubDialog('category'),
            items: widget.categories
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCategoryId = v),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final success = await widget.onAdd(
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0,
      costPrice: double.tryParse(_costPriceController.text) ?? 0,
      stock: int.tryParse(_stockController.text) ?? 0,
      // ✅ ADD THIS LINE:
      barcode: _barcodeController.text.trim().isEmpty
          ? null
          : _barcodeController.text.trim(),
      categoryId: _selectedCategoryId,
      supplierId: _selectedSupplierId,
      imagePath: _imagePath,
      hasVariants: _hasVariants,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) Navigator.pop(context, true);
    }
  }

  void _showSubDialog(String type) {
    showDialog(
      context: context,
      builder: (_) => type == 'category'
          ? BrutalAddCategoryDialog(
              nameController: TextEditingController(),
              descController: TextEditingController(),
              formKey: GlobalKey<FormState>(),
            )
          : BrutalAddSupplierDialog(
              nameController: TextEditingController(),
              contactController: TextEditingController(),
              phoneController: TextEditingController(),
              formKey: GlobalKey<FormState>(),
            ),
    );
  }
}
