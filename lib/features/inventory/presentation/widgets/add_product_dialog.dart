import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/product_image_picker.dart';
import '../../../inventory/domain/entities/category.dart' as entities;
import '../../../inventory/domain/entities/supplier.dart';

import '../../../shared/presentation/providers.dart';
import '../widgets/brutal_form_inputs.dart';
import '../widgets/brutal_auxiliary_dialogs.dart';
import '../widgets/add_product_components.dart';
import '../widgets/unit_of_measurement_dropdown.dart';
import '../widgets/stock_adjustment_section.dart';
import '../../domain/entities/stock_adjustment.dart';

class AddProductDialog extends ConsumerStatefulWidget {
  final Future<bool> Function({
    required String name,
    required double price,
    required double costPrice,
    required int stock,
    int? categoryId,
    int? supplierId,
    String? barcode,
    String? imagePath,
    String? unitOfMeasurement,
    bool hasVariants,
  })
  onAdd;
  final String? initialBarcode;

  const AddProductDialog({super.key, required this.onAdd, this.initialBarcode});

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _barcodeController = TextEditingController();
  int? _selectedCategoryId;
  int? _selectedSupplierId;
  String? _imagePath;
  UnitOfMeasurement _selectedUnit = UnitOfMeasurement.pcs;
  final bool _hasVariants = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    // Watch categories and suppliers from providers
    final categories = ref.watch(categoryControllerProvider).categories;
    final suppliers = ref.watch(supplierControllerProvider).suppliers;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
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
                child: _buildForm(categories, suppliers),
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

  Widget _buildForm(
    List<entities.Category> categories,
    List<Supplier> suppliers,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // IMAGE PICKER
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
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama produk wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // PRICE - FULL WIDTH
          BrutalTextFormField(
            controller: _priceController,
            label: 'HARGA JUAL',
            icon: Icons.sell,
            themeColor: AppTheme.successColor,
            prefixText: 'Rp ',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Harga jual wajib diisi';
              }
              if (double.tryParse(value) == null) {
                return 'Masukkan angka yang valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // COST PRICE - FULL WIDTH
          BrutalTextFormField(
            controller: _costPriceController,
            label: 'HARGA MODAL',
            icon: Icons.money,
            themeColor: NeoBrutalTheme.secondary,
            prefixText: 'Rp ',
            keyboardType: TextInputType.number,
            hintText: 'Opsional',
          ),
          const SizedBox(height: 16),

          // STOCK
          BrutalTextFormField(
            controller: _stockController,
            label: 'STOK',
            icon: Icons.inventory,
            themeColor: AppTheme.infoColor,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Stok wajib diisi';
              }
              if (int.tryParse(value) == null) {
                return 'Masukkan angka yang valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // UNIT OF MEASUREMENT
          UnitOfMeasurementDropdown(
            selectedUnit: _selectedUnit,
            onUnitChanged: (value) {
              setState(() => _selectedUnit = value);
            },
          ),

          const SizedBox(height: 16),

          // BARCODE WITH SCAN BUTTON
          BrutalTextFormField(
            controller: _barcodeController,
            label: 'BARCODE',
            icon: Icons.qr_code_scanner_rounded,
            themeColor: AppTheme.warningColor,
            hintText: 'Opsional - ketik atau scan',
            suffixIcon: IconButton(
              icon: const Icon(Icons.camera_alt_rounded),
              tooltip: 'Scan Barcode',
              onPressed: _scanBarcode,
            ),
          ),
          const SizedBox(height: 16),

          // CATEGORY
          BrutalDropdownField<int>(
            label: 'KATEGORI',
            value: _selectedCategoryId,
            prefixIcon: Icons.category,
            color: NeoBrutalTheme.primary,
            onAddPressed: () => _showSubDialog('category'),
            items: categories
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCategoryId = v),
          ),
          const SizedBox(height: 16),

          // SUPPLIER
          BrutalDropdownField<int>(
            label: 'SUPPLIER',
            value: _selectedSupplierId,
            prefixIcon: Icons.local_shipping,
            color: AppTheme.warningColor,
            onAddPressed: () => _showSubDialog('supplier'),
            items: suppliers
                .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                .toList(),
            onChanged: (v) => setState(() => _selectedSupplierId = v),
          ),
        ],
      ),
    );
  }

  Future<void> _scanBarcode() async {
    // TODO: Implement barcode scanning using mobile_scanner or similar
    // Example:
    // final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => BarcodeScannerPage()));
    // if (result != null && mounted) {
    //   setState(() => _barcodeController.text = result);
    // }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final success = await widget.onAdd(
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0,
      costPrice: double.tryParse(_costPriceController.text) ?? 0,
      stock: int.tryParse(_stockController.text) ?? 0,
      barcode: _barcodeController.text.trim().isEmpty
          ? null
          : _barcodeController.text.trim(),
      categoryId: _selectedCategoryId,
      supplierId: _selectedSupplierId,
      imagePath: _imagePath,
      unitOfMeasurement: _selectedUnit.name,
      hasVariants: _hasVariants,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) Navigator.pop(context, true);
    }
  }

  Future<void> _showSubDialog(String type) async {
    final result = await showDialog<bool>(
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

    // Reload categories/suppliers if successfully added
    if (result == true && mounted) {
      if (type == 'category') {
        await ref.read(categoryControllerProvider).loadCategories();
      } else {
        await ref.read(supplierControllerProvider).loadSuppliers();
      }
    }
  }
}
