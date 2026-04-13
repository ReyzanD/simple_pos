import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/product_image_picker.dart';
import '../../../inventory/domain/entities/category.dart' as entities;
import '../../../inventory/domain/entities/supplier.dart';
import '../controllers/category_controller.dart';
import '../controllers/supplier_controller.dart';

/// Brutalist Add Product Dialog - Industrial, Bold, Unforgettable
///
/// Design Philosophy:
/// - Heavy visual weight with dramatic shadows (6px offset, no blur)
/// - Bold 4-5px black borders throughout
/// - Asymmetric layout with dramatic header
/// - Industrial color palette (blockYellow, primary, secondary)
/// - Icon containers with brutal styling
/// - Typography: w700-w900 weights with letter spacing
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

class _AddProductDialogState extends State<AddProductDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _barcodeController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;
  int? _selectedCategoryId;
  int? _selectedSupplierId;
  String? _imagePath;
  bool _hasVariants = false;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // Local copy of categories and suppliers
  late List<entities.Category> _categories;
  late List<Supplier> _suppliers;

  @override
  void initState() {
    super.initState();
    _categories = widget.categories;
    _suppliers = widget.suppliers;

    if (widget.initialBarcode != null) {
      _barcodeController.text = widget.initialBarcode!;
    }

    // Slide-in animation
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _slideController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    _barcodeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _showAddCategoryDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _BrutalAddCategoryDialog(
        nameController: nameController,
        descController: descController,
        formKey: formKey,
      ),
    );

    if (result == true && mounted) {
      final categoryController = context.read<CategoryController>();
      setState(() {
        _categories = categoryController.categories;
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
      builder: (dialogContext) => _BrutalAddSupplierDialog(
        nameController: nameController,
        contactController: contactController,
        phoneController: phoneController,
        formKey: formKey,
      ),
    );

    if (result == true && mounted) {
      final supplierController = context.read<SupplierController>();
      setState(() {
        _suppliers = supplierController.suppliers;
        if (_suppliers.isNotEmpty) {
          _selectedSupplierId = _suppliers.last.id;
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    setState(() => _errorMessage = null);

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

      // Debug logging
      AppLogger.ui('Adding product: $name, price: $price, stock: $stock');

      final success = await widget.onAdd(
        name: name,
        price: price,
        costPrice: costPrice,
        stock: stock,
        categoryId: _selectedCategoryId,
        supplierId: _selectedSupplierId,
        barcode: barcode,
        imagePath: _imagePath,
        hasVariants: _hasVariants,
      );

      AppLogger.info('Add product result: $success (${success ? "success" : "failed"})');

      if (!success && mounted) {
        setState(() {
          _errorMessage = 'Gagal menambahkan produk. Silakan coba lagi.';
        });
      }
    } on AppException catch (e) {
      AppLogger.error('AppException in add product: ${e.userMessage}');
      if (mounted) {
        setState(() {
          _errorMessage = e.userMessage ?? 'Gagal menambahkan produk';
        });
      }
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in add product: ${e.runtimeType}',
        error: e,
        stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _errorMessage = 'Terjadi kesalahan: ${e.toString()}\n\nTipe: ${e.runtimeType}';
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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusLarge),
            border: Border.all(
              color: Colors.black,
              width: 5, // ✅ Extra bold border
            ),
            boxShadow: NeoBrutalTheme.chunkyShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dramatic Header
              _buildBrutalHeader(context),

              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(NeoBrutalTheme.spaceLG),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Error Message
                        if (_errorMessage != null) _buildErrorMessage(context),

                        if (_errorMessage != null)
                          SizedBox(height: NeoBrutalTheme.spaceMD),

                        // Image Picker - Asymmetric placement
                        _buildImagePickerSection(context),

                        SizedBox(height: NeoBrutalTheme.spaceLG),

                        // Product Name - Large input with icon
                        _buildProductNameField(context),

                        SizedBox(height: NeoBrutalTheme.spaceMD),

                        // Price Field
                        _buildPriceField(context),

                        SizedBox(height: NeoBrutalTheme.spaceMD),

                        // Cost Price Field
                        _buildCostPriceField(context),

                        SizedBox(height: NeoBrutalTheme.spaceMD),

                        // Stock Field
                        _buildStockField(context),

                        SizedBox(height: NeoBrutalTheme.spaceMD),

                        // Barcode Field
                        _buildBarcodeField(context),

                        SizedBox(height: NeoBrutalTheme.spaceMD),

                        // Category Dropdown
                        _buildCategoryDropdown(context),

                        SizedBox(height: NeoBrutalTheme.spaceMD),

                        // Supplier Dropdown
                        _buildSupplierDropdown(context),

                        SizedBox(height: NeoBrutalTheme.spaceMD),

                        // Variants Checkbox - Brutal styling
                        _buildVariantsCheckbox(context),
                      ],
                    ),
                  ),
                ),
              ),

              // Brutal Action Buttons
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  /// Dramatic header with asymmetric layout
  Widget _buildBrutalHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            NeoBrutalTheme.blockYellow,
            NeoBrutalTheme.blockYellow.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(NeoBrutalTheme.radiusLarge - 2),
          topRight: Radius.circular(NeoBrutalTheme.radiusLarge - 2),
        ),
        border: Border(bottom: BorderSide(color: Colors.black, width: 5)),
      ),
      child: Row(
        children: [
          // Dramatic icon container
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: NeoBrutalTheme.primary,
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: NeoBrutalTheme.chunkyShadow,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 32,
              color: Colors.white,
            ),
          ),
          SizedBox(width: NeoBrutalTheme.spaceMD),

          // Bold typography
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TAMBAH PRODUK',
                  style: NeoBrutalTheme.headlineLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 3,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'INVENTORY MANAGEMENT',
                  style: NeoBrutalTheme.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withValues(alpha: 0.6),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          // Close button with brutal styling
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: Icon(Icons.close_rounded, color: Colors.black, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  /// Error message with brutal styling
  Widget _buildErrorMessage(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(color: AppTheme.errorColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppTheme.errorColor.withValues(alpha: 0.2),
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.errorColor,
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          SizedBox(width: NeoBrutalTheme.spaceSM),
          Expanded(
            child: Text(
              _errorMessage!,
              style: NeoBrutalTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Image picker with asymmetric layout
  Widget _buildImagePickerSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NeoBrutalTheme.background,
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(color: Colors.black, width: 3),
      ),
      padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: NeoBrutalTheme.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(
                    NeoBrutalTheme.radiusSmall,
                  ),
                  border: Border.all(color: NeoBrutalTheme.secondary, width: 2),
                ),
                child: Icon(
                  Icons.image_outlined,
                  size: 16,
                  color: NeoBrutalTheme.secondary,
                ),
              ),
              SizedBox(width: NeoBrutalTheme.spaceSM),
              Text(
                'GAMBAR PRODUK',
                style: NeoBrutalTheme.labelMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: NeoBrutalTheme.spaceSM),
          ProductImagePicker(
            currentImagePath: _imagePath,
            onImageChanged: (path) {
              setState(() => _imagePath = path);
            },
            size: 120,
          ),
        ],
      ),
    );
  }

  /// Product name field with brutal styling
  Widget _buildProductNameField(BuildContext context) {
    return TextFormField(
      controller: _nameController,
      textInputAction: TextInputAction.next,
      style: NeoBrutalTheme.bodyLarge.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: 'NAMA PRODUK',
        labelStyle: NeoBrutalTheme.labelLarge.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: NeoBrutalTheme.primary,
        ),
        hintText: 'Contoh: Kopi Susu Aren',
        hintStyle: NeoBrutalTheme.bodyMedium.copyWith(
          color: AppTheme.textTertiary,
        ),
        prefixIcon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: NeoBrutalTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Icon(
            Icons.label_outline_rounded,
            color: NeoBrutalTheme.primary,
            size: 22,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: NeoBrutalTheme.spaceLG,
          vertical: NeoBrutalTheme.spaceMD,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(color: Colors.black, width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(
            color: NeoBrutalTheme.primary.withValues(alpha: 0.3),
            width: 3,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(color: NeoBrutalTheme.primary, width: 4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(color: AppTheme.errorColor, width: 4),
        ),
      ),
      validator: (value) {
        try {
          Validators.validateProductName(value ?? '');
          return null;
        } on ValidationException catch (e) {
          return e.message;
        }
      },
    );
  }

  /// Price field with brutal styling
  Widget _buildPriceField(BuildContext context) {
    return TextFormField(
      controller: _priceController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      style: NeoBrutalTheme.bodyLarge.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: 'HARGA JUAL',
        labelStyle: NeoBrutalTheme.labelLarge.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: AppTheme.successColor,
        ),
        prefixText: 'Rp ',
        prefixStyle: NeoBrutalTheme.bodyLarge.copyWith(
          fontWeight: FontWeight.w800,
          color: AppTheme.successColor,
        ),
        hintText: '0',
        hintStyle: NeoBrutalTheme.bodyMedium.copyWith(
          color: AppTheme.textTertiary,
        ),
        prefixIcon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.successColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Icon(
            Icons.sell_outlined,
            color: AppTheme.successColor,
            size: 22,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: NeoBrutalTheme.spaceLG,
          vertical: NeoBrutalTheme.spaceMD,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(color: Colors.black, width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(
            color: AppTheme.successColor.withValues(alpha: 0.3),
            width: 3,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(color: AppTheme.successColor, width: 4),
        ),
      ),
      validator: (value) {
        try {
          Validators.validatePrice(value ?? '');
          return null;
        } on ValidationException catch (e) {
          return e.message;
        }
      },
    );
  }

  /// Cost price field with brutal styling
  Widget _buildCostPriceField(BuildContext context) {
    return TextFormField(
      controller: _costPriceController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      style: NeoBrutalTheme.bodyLarge.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: 'HARGA MODAL',
        labelStyle: NeoBrutalTheme.labelLarge.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: NeoBrutalTheme.secondary,
        ),
        prefixText: 'Rp ',
        prefixStyle: NeoBrutalTheme.bodyLarge.copyWith(
          fontWeight: FontWeight.w800,
          color: NeoBrutalTheme.secondary,
        ),
        hintText: '0',
        hintStyle: NeoBrutalTheme.bodyMedium.copyWith(
          color: AppTheme.textTertiary,
        ),
        prefixIcon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: NeoBrutalTheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Icon(
            Icons.attach_money_rounded,
            color: NeoBrutalTheme.secondary,
            size: 22,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: NeoBrutalTheme.spaceLG,
          vertical: NeoBrutalTheme.spaceMD,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(color: Colors.black, width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(
            color: NeoBrutalTheme.secondary.withValues(alpha: 0.3),
            width: 3,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(color: NeoBrutalTheme.secondary, width: 4),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Wajib diisi';
        }
        final costPrice = double.tryParse(value);
        if (costPrice == null || costPrice < 0) {
          return 'Tidak valid';
        }
        return null;
      },
    );
  }

  /// Stock field with brutal styling
  Widget _buildStockField(BuildContext context) {
    return TextFormField(
      controller: _stockController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      style: NeoBrutalTheme.bodyLarge.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: 'STOK',
        labelStyle: NeoBrutalTheme.labelLarge.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: AppTheme.infoColor,
        ),
        hintText: '0',
        hintStyle: NeoBrutalTheme.bodyMedium.copyWith(
          color: AppTheme.textTertiary,
        ),
        prefixIcon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.infoColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Icon(Icons.inventory, color: AppTheme.infoColor, size: 22),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: NeoBrutalTheme.spaceLG,
          vertical: NeoBrutalTheme.spaceMD,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(color: Colors.black, width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(
            color: AppTheme.infoColor.withValues(alpha: 0.3),
            width: 3,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(color: AppTheme.infoColor, width: 4),
        ),
      ),
      validator: (value) {
        try {
          Validators.validateStock(value ?? '');
          return null;
        } on ValidationException catch (e) {
          return e.message;
        }
      },
    );
  }

  /// Barcode field with brutal styling
  Widget _buildBarcodeField(BuildContext context) {
    return TextFormField(
      controller: _barcodeController,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      style: NeoBrutalTheme.bodyLarge.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: 'BARCODE',
        labelStyle: NeoBrutalTheme.labelLarge.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: AppTheme.warningColor,
        ),
        hintText: 'Opsional',
        hintStyle: NeoBrutalTheme.bodyMedium.copyWith(
          color: AppTheme.textTertiary,
        ),
        prefixIcon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Icon(
            Icons.qr_code_2_rounded,
            color: AppTheme.warningColor,
            size: 22,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: NeoBrutalTheme.spaceLG,
          vertical: NeoBrutalTheme.spaceMD,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(color: Colors.black, width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(
            color: AppTheme.warningColor.withValues(alpha: 0.3),
            width: 3,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(color: AppTheme.warningColor, width: 4),
        ),
      ),
    );
  }

  /// Category dropdown with brutal styling
  Widget _buildCategoryDropdown(BuildContext context) {
    return DropdownButtonFormField<int>(
      isExpanded: true,
      initialValue: _selectedCategoryId,
      style: NeoBrutalTheme.bodyLarge.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: 'KATEGORI',
        labelStyle: NeoBrutalTheme.labelLarge.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: NeoBrutalTheme.primary,
        ),
        prefixIcon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: NeoBrutalTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Icon(
            Icons.category_outlined,
            color: NeoBrutalTheme.primary,
            size: 22,
          ),
        ),
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: NeoBrutalTheme.spaceSM),
          child: GestureDetector(
            onTap: _showAddCategoryDialog,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: NeoBrutalTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Icon(
                Icons.add_circle_outline,
                color: NeoBrutalTheme.primary,
                size: 18,
              ),
            ),
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: NeoBrutalTheme.spaceLG,
          vertical: NeoBrutalTheme.spaceMD,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(color: Colors.black, width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(
            color: NeoBrutalTheme.primary.withValues(alpha: 0.3),
            width: 3,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(color: NeoBrutalTheme.primary, width: 4),
        ),
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
      items: [
        DropdownMenuItem<int>(
          value: null,
          child: Text(
            'Tanpa Kategori',
            style: NeoBrutalTheme.bodyMedium.copyWith(
              color: AppTheme.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ..._categories.map((category) {
          return DropdownMenuItem<int>(
            value: category.id,
            child: Text(
              category.name,
              style: NeoBrutalTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
        });
      },
    );
  }

  /// Supplier dropdown with brutal styling
  Widget _buildSupplierDropdown(BuildContext context) {
    return DropdownButtonFormField<int>(
      isExpanded: true,
      initialValue: _selectedSupplierId,
      style: NeoBrutalTheme.bodyLarge.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: 'PEMASOK',
        labelStyle: NeoBrutalTheme.labelLarge.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: NeoBrutalTheme.secondary,
        ),
        prefixIcon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: NeoBrutalTheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Icon(
            Icons.local_shipping_outlined,
            color: NeoBrutalTheme.secondary,
            size: 22,
          ),
        ),
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: NeoBrutalTheme.spaceSM),
          child: GestureDetector(
            onTap: _showAddSupplierDialog,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: NeoBrutalTheme.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Icon(
                Icons.add_circle_outline,
                color: NeoBrutalTheme.secondary,
                size: 18,
              ),
            ),
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: NeoBrutalTheme.spaceLG,
          vertical: NeoBrutalTheme.spaceMD,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(color: Colors.black, width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(
            color: NeoBrutalTheme.secondary.withValues(alpha: 0.3),
            width: 3,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(color: NeoBrutalTheme.secondary, width: 4),
        ),
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
      items: [
        DropdownMenuItem<int>(
          value: null,
          child: Text(
            'Tanpa Pemasok',
            style: NeoBrutalTheme.bodyMedium.copyWith(
              color: AppTheme.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ..._suppliers.map((supplier) {
          return DropdownMenuItem<int>(
            value: supplier.id,
            child: Text(
              supplier.name,
              style: NeoBrutalTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedSupplierId = value;
        });
      },
    );
  }

  /// Variants checkbox with brutal styling
  Widget _buildVariantsCheckbox(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
      decoration: BoxDecoration(
        color: NeoBrutalTheme.blockCoral.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: CheckboxListTile(
        title: Text(
          'PRODUK INI MEMILIKI VARIAN',
          style: NeoBrutalTheme.labelMedium.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          'Aktifkan untuk mengatur varian seperti ukuran, warna, dll setelah produk dibuat',
          style: NeoBrutalTheme.bodySmall.copyWith(
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
        value: _hasVariants,
        onChanged: (value) {
          setState(() {
            _hasVariants = value ?? false;
          });
        },
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        checkboxShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: BorderSide(color: Colors.black, width: 2),
        activeColor: NeoBrutalTheme.primary,
        checkColor: Colors.white,
      ),
    );
  }

  /// Action buttons with brutal styling
  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceLG),
      decoration: BoxDecoration(
        color: NeoBrutalTheme.background,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(NeoBrutalTheme.radiusLarge - 2),
          bottomRight: Radius.circular(NeoBrutalTheme.radiusLarge - 2),
        ),
        border: Border(top: BorderSide(color: Colors.black, width: 5)),
      ),
      child: Row(
        children: [
          // Cancel Button
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  NeoBrutalTheme.radiusMedium,
                ),
                border: Border.all(color: Colors.black, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isSubmitting ? null : () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(
                    NeoBrutalTheme.radiusMedium,
                  ),
                  child: Center(
                    child: Text(
                      'BATAL',
                      style: NeoBrutalTheme.labelLarge.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: NeoBrutalTheme.spaceMD),

          // Save Button
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    NeoBrutalTheme.primary,
                    NeoBrutalTheme.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  NeoBrutalTheme.radiusMedium,
                ),
                border: Border.all(color: Colors.black, width: 4),
                boxShadow: NeoBrutalTheme.chunkyShadow,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isSubmitting ? null : _handleSubmit,
                  borderRadius: BorderRadius.circular(
                    NeoBrutalTheme.radiusMedium,
                  ),
                  child: Center(
                    child: _isSubmitting
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'SIMPAN',
                            style: NeoBrutalTheme.labelLarge.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                              color: Colors.white,
                            ),
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
}

/// Brutal Add Category Dialog
class _BrutalAddCategoryDialog extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  final GlobalKey<FormState> formKey;

  const _BrutalAddCategoryDialog({
    required this.nameController,
    required this.descController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 450),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusLarge),
          border: Border.all(color: Colors.black, width: 5),
          boxShadow: NeoBrutalTheme.chunkyShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(NeoBrutalTheme.spaceLG),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    NeoBrutalTheme.primary,
                    NeoBrutalTheme.primary.withValues(alpha: 0.85),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(NeoBrutalTheme.radiusLarge - 2),
                  topRight: Radius.circular(NeoBrutalTheme.radiusLarge - 2),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        NeoBrutalTheme.radiusMedium,
                      ),
                      border: Border.all(color: Colors.black, width: 3),
                    ),
                    child: Icon(
                      Icons.category_rounded,
                      color: NeoBrutalTheme.primary,
                      size: 26,
                    ),
                  ),
                  SizedBox(width: NeoBrutalTheme.spaceMD),
                  Text(
                    'KATEGORI BARU',
                    style: NeoBrutalTheme.headlineSmall.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Padding(
              padding: EdgeInsets.all(NeoBrutalTheme.spaceLG),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      style: NeoBrutalTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        labelText: 'NAMA KATEGORI',
                        labelStyle: NeoBrutalTheme.labelLarge.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            NeoBrutalTheme.radiusMedium,
                          ),
                          borderSide: BorderSide(color: Colors.black, width: 3),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama kategori wajib diisi';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: NeoBrutalTheme.spaceMD),
                    TextFormField(
                      controller: descController,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      style: NeoBrutalTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        labelText: 'DESKRIPSI (Opsional)',
                        labelStyle: NeoBrutalTheme.labelMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            NeoBrutalTheme.radiusMedium,
                          ),
                          borderSide: BorderSide(color: Colors.black, width: 3),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Padding(
              padding: EdgeInsets.all(NeoBrutalTheme.spaceLG),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          NeoBrutalTheme.radiusMedium,
                        ),
                        border: Border.all(color: Colors.black, width: 3),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context, false),
                          child: Center(
                            child: Text(
                              'BATAL',
                              style: NeoBrutalTheme.labelMedium.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: NeoBrutalTheme.spaceMD),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: NeoBrutalTheme.primary,
                        borderRadius: BorderRadius.circular(
                          NeoBrutalTheme.radiusMedium,
                        ),
                        border: Border.all(color: Colors.black, width: 3),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              final categoryController = context
                                  .read<CategoryController>();
                              final name = nameController.text.trim();
                              final description =
                                  descController.text.trim().isEmpty
                                  ? null
                                  : descController.text.trim();

                              final newCategory = entities.Category(
                                id: 0,
                                name: name,
                                description: description,
                                createdAt: DateTime.now(),
                              );

                              final success = await categoryController
                                  .addCategory(newCategory);

                              if (context.mounted) {
                                Navigator.pop(context, success);
                              }
                            }
                          },
                          child: Center(
                            child: Text(
                              'TAMBAH',
                              style: NeoBrutalTheme.labelMedium.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Brutal Add Supplier Dialog
class _BrutalAddSupplierDialog extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController contactController;
  final TextEditingController phoneController;
  final GlobalKey<FormState> formKey;

  const _BrutalAddSupplierDialog({
    required this.nameController,
    required this.contactController,
    required this.phoneController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 450),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusLarge),
          border: Border.all(color: Colors.black, width: 5),
          boxShadow: NeoBrutalTheme.chunkyShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(NeoBrutalTheme.spaceLG),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    NeoBrutalTheme.secondary,
                    NeoBrutalTheme.secondary.withValues(alpha: 0.85),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(NeoBrutalTheme.radiusLarge - 2),
                  topRight: Radius.circular(NeoBrutalTheme.radiusLarge - 2),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        NeoBrutalTheme.radiusMedium,
                      ),
                      border: Border.all(color: Colors.black, width: 3),
                    ),
                    child: Icon(
                      Icons.local_shipping_rounded,
                      color: NeoBrutalTheme.secondary,
                      size: 26,
                    ),
                  ),
                  SizedBox(width: NeoBrutalTheme.spaceMD),
                  Text(
                    'PEMASOK BARU',
                    style: NeoBrutalTheme.headlineSmall.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Padding(
              padding: EdgeInsets.all(NeoBrutalTheme.spaceLG),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      style: NeoBrutalTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        labelText: 'NAMA PEMASOK',
                        labelStyle: NeoBrutalTheme.labelLarge.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            NeoBrutalTheme.radiusMedium,
                          ),
                          borderSide: BorderSide(color: Colors.black, width: 3),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama pemasok wajib diisi';
                        }
                        if (value.trim().length < 2) {
                          return 'Minimal 2 karakter';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: NeoBrutalTheme.spaceMD),
                    TextFormField(
                      controller: contactController,
                      textCapitalization: TextCapitalization.words,
                      style: NeoBrutalTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        labelText: 'KONTAK (Opsional)',
                        labelStyle: NeoBrutalTheme.labelMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            NeoBrutalTheme.radiusMedium,
                          ),
                          borderSide: BorderSide(color: Colors.black, width: 3),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: NeoBrutalTheme.spaceMD),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: NeoBrutalTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        labelText: 'TELEPON (Opsional)',
                        labelStyle: NeoBrutalTheme.labelMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            NeoBrutalTheme.radiusMedium,
                          ),
                          borderSide: BorderSide(color: Colors.black, width: 3),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Padding(
              padding: EdgeInsets.all(NeoBrutalTheme.spaceLG),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          NeoBrutalTheme.radiusMedium,
                        ),
                        border: Border.all(color: Colors.black, width: 3),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context, false),
                          child: Center(
                            child: Text(
                              'BATAL',
                              style: NeoBrutalTheme.labelMedium.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: NeoBrutalTheme.spaceMD),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: NeoBrutalTheme.secondary,
                        borderRadius: BorderRadius.circular(
                          NeoBrutalTheme.radiusMedium,
                        ),
                        border: Border.all(color: Colors.black, width: 3),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              final supplierController = context
                                  .read<SupplierController>();
                              final name = nameController.text.trim();
                              final contactPerson =
                                  contactController.text.trim().isEmpty
                                  ? null
                                  : contactController.text.trim();
                              final phone = phoneController.text.trim().isEmpty
                                  ? null
                                  : phoneController.text.trim();

                              final newSupplier = Supplier(
                                id: 0,
                                name: name,
                                contactPerson: contactPerson,
                                phone: phone,
                                createdAt: DateTime.now(),
                              );

                              final success = await supplierController
                                  .addSupplier(newSupplier);

                              if (context.mounted) {
                                Navigator.pop(context, success);
                              }
                            }
                          },
                          child: Center(
                            child: Text(
                              'TAMBAH',
                              style: NeoBrutalTheme.labelMedium.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
