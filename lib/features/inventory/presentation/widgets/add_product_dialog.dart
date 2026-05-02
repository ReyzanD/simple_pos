import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/product_image_picker.dart';
import '../../../inventory/domain/entities/category.dart' as entities;
import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/domain/entities/supplier.dart';
import '../../../shared/presentation/providers.dart';
import '../widgets/brutal_form_inputs.dart';
import '../widgets/brutal_auxiliary_dialogs.dart';
import '../widgets/unit_of_measurement_dropdown.dart';

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

  final Product? productToEdit; // null = add mode, product object = edit mode
  final String? initialBarcode;

  const AddProductDialog({
    super.key,
    required this.onAdd,
    this.productToEdit,
    this.initialBarcode,
  });

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

  bool get _isEditMode => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _initializeEditMode();
    } else if (widget.initialBarcode != null) {
      _barcodeController.text = widget.initialBarcode!;
    }
  }

  void _initializeEditMode() {
    final product = widget.productToEdit!;
    _nameController.text = product.name;
    _priceController.text = product.price.toString();
    _costPriceController.text = product.costPrice.toString();
    _stockController.text = product.stock.toString();
    _barcodeController.text = product.barcode ?? '';
    _selectedCategoryId = product.categoryId;
    _selectedSupplierId = product.supplierId;
    _imagePath = product.imagePath;
    _selectedUnit = UnitOfMeasurement.values.firstWhere(
      (u) => u.name == product.unitOfMeasurement,
      orElse: () => UnitOfMeasurement.pcs,
    );
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
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildForm(categories, suppliers),
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NeoBrutalTheme.blockBlue,
        border: const Border(bottom: BorderSide(color: Colors.black, width: 3)),
      ),
      child: Row(
        children: [
          Icon(
            _isEditMode ? Icons.edit : Icons.add_circle,
            size: 24,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Text(
            _isEditMode ? 'EDIT PRODUK' : 'TAMBAH PRODUK',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
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
          ProductImagePicker(
            currentImagePath: _imagePath,
            onImageChanged: (p) => setState(() => _imagePath = p),
            size: 120,
          ),
          const SizedBox(height: 24),
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
          UnitOfMeasurementDropdown(
            selectedUnit: _selectedUnit,
            onUnitChanged: (value) {
              if (value != null) {
                setState(() => _selectedUnit = value);
              }
            },
          ),
          const SizedBox(height: 16),
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

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black, width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _isSubmitting ? null : () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(
                    NeoBrutalTheme.radiusSmall,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'BATAL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _isSubmitting ? null : _handleSubmit,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isEditMode
                      ? AppTheme.infoColor
                      : NeoBrutalTheme.blockBlue,
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(
                    NeoBrutalTheme.radiusSmall,
                  ),
                ),
                child: Center(
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _isEditMode ? 'SIMPAN' : 'TAMBAH',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanBarcode() async {
    // TODO: Implement barcode scanning
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

    if (result == true && mounted) {
      if (type == 'category') {
        await ref.read(categoryControllerProvider).loadCategories();
      } else {
        await ref.read(supplierControllerProvider).loadSuppliers();
      }
    }
  }
}
