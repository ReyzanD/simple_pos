import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/entities/variant_attribute.dart';
import '../controllers/product_variant_controller.dart';

/// Widget for configuring product variants
/// Allows adding variant attributes (Size, Color, etc.) and generating variant combinations
class VariantConfigurator extends StatefulWidget {
  final int productId;
  final String productName;
  final double basePrice;
  final double baseCostPrice;
  final ProductVariantController controller;
  final Function(List<ProductVariant>)? onSave;
  final bool isEnabled;

  const VariantConfigurator({
    super.key,
    required this.productId,
    required this.productName,
    required this.basePrice,
    required this.baseCostPrice,
    required this.controller,
    this.onSave,
    this.isEnabled = true,
  });

  @override
  State<VariantConfigurator> createState() => _VariantConfiguratorState();
}

class _VariantConfiguratorState extends State<VariantConfigurator> {
  final List<_AttributeEditor> _attributeEditors = [];
  List<ProductVariant> _generatedVariants = [];
  bool _hasGeneratedVariants = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEnabled) {
      _loadExistingData();
    }
  }

  Future<void> _loadExistingData() async {
    await widget.controller.loadVariants(widget.productId);
    if (mounted) {
      setState(() {
        _attributeEditors.clear();
        for (final attr in widget.controller.attributes) {
          _attributeEditors.add(_AttributeEditor(
            name: attr.name,
            values: List.from(attr.values),
          ));
        }
        _generatedVariants.clear();
        _generatedVariants.addAll(widget.controller.variants);
        _hasGeneratedVariants = _generatedVariants.isNotEmpty;
      });
    }
  }

  void _addAttributeEditor() {
    setState(() {
      _attributeEditors.add(_AttributeEditor());
    });
  }

  void _removeAttributeEditor(int index) {
    setState(() {
      _attributeEditors.removeAt(index);
      _hasGeneratedVariants = false;
      _generatedVariants.clear();
    });
  }

  void _updateAttributeEditor(int index, _AttributeEditor editor) {
    setState(() {
      _attributeEditors[index] = editor;
      _hasGeneratedVariants = false;
    });
  }

  void _generateVariants() {
    // Validate attributes
    for (final editor in _attributeEditors) {
      if (editor.name.isEmpty) {
        _showError('Nama atribut tidak boleh kosong');
        return;
      }
      if (editor.values.isEmpty || editor.values.any((v) => v.isEmpty)) {
        _showError('Semua nilai atribut harus diisi');
        return;
      }
    }

    // Generate combinations
    final combinations = _generateCombinations();

    if (combinations.isEmpty) {
      _showError('Gagal membuat kombinasi varian');
      return;
    }

    // Create variants from combinations
    final variants = <ProductVariant>[];
    final now = DateTime.now();

    for (final combo in combinations) {
      // Generate readable name
      final name = combo.entries.map((e) => e.value).join(' / ');

      variants.add(ProductVariant(
        productId: widget.productId,
        name: name,
        price: widget.basePrice,
        costPrice: widget.baseCostPrice,
        stock: 0,
        attributes: combo,
        createdAt: now,
      ));
    }

    setState(() {
      _generatedVariants = variants;
      _hasGeneratedVariants = true;
    });
  }

  List<Map<String, String>> _generateCombinations() {
    if (_attributeEditors.isEmpty) return [];

    List<Map<String, String>> combinations = [{}];

    for (final editor in _attributeEditors) {
      if (editor.values.isEmpty) continue;
      final List<Map<String, String>> newCombinations = [];
      for (final combo in combinations) {
        for (final value in editor.values) {
          newCombinations.add({...combo, editor.name: value});
        }
      }
      combinations = newCombinations;
    }

    return combinations;
  }

  void _updateVariant(int index, ProductVariant variant) {
    setState(() {
      _generatedVariants[index] = variant;
    });
  }

  Future<void> _saveVariants() async {
    // Delete existing variants and attributes first
    await widget.controller.deleteVariantsByProductId(widget.productId);
    await widget.controller.deleteAttributesByProductId(widget.productId);

    // Save attributes
    final attributes = _attributeEditors.map((editor) {
      return VariantAttribute(
        productId: widget.productId,
        name: editor.name,
        values: editor.values,
        sortOrder: _attributeEditors.indexOf(editor),
      );
    }).toList();

    await widget.controller.addAttributes(attributes);

    // Save variants
    await widget.controller.addVariants(_generatedVariants);

    widget.onSave?.call(_generatedVariants);

    if (mounted) {
      _showSuccess('Varian produk berhasil disimpan');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Variant attributes section
        ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Atribut Varian',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (_attributeEditors.length < 4 && widget.isEnabled)
                    TextButton.icon(
                      onPressed: _addAttributeEditor,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tambah Atribut'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (_attributeEditors.isEmpty && widget.isEnabled)
                _EmptyAttributesState(onAdd: _addAttributeEditor)
              else
                ...List.generate(_attributeEditors.length, (index) {
                  return _AttributeEditorCard(
                    editor: _attributeEditors[index],
                    index: index,
                    onChanged: (editor) => _updateAttributeEditor(index, editor),
                    onRemove: widget.isEnabled
                        ? () => _removeAttributeEditor(index)
                        : null,
                    enabled: widget.isEnabled,
                  );
                }),
            ],
          ),
        ),

        // Generate variants button
        if (_attributeEditors.isNotEmpty &&
            _attributeEditors.every((e) => e.name.isNotEmpty && e.values.isNotEmpty) &&
            widget.isEnabled)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ModernButton(
              text: 'Generate Varian',
              icon: Icons.auto_awesome,
              isFullWidth: true,
              onPressed: _generateVariants,
            ),
          ),

        // Generated variants section
        if (_hasGeneratedVariants) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Varian Yang Dibuat (${_generatedVariants.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (widget.isEnabled)
                  ModernButton(
                    text: 'Simpan Semua',
                    icon: Icons.save,
                    backgroundColor: AppTheme.successColor,
                    onPressed: _saveVariants,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(_generatedVariants.length, (index) {
            return _VariantCard(
              variant: _generatedVariants[index],
              onChanged: (variant) => _updateVariant(index, variant),
              enabled: widget.isEnabled,
            );
          }),
        ],
      ],
    );
  }
}

class _EmptyAttributesState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyAttributesState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.category_outlined,
            size: 48,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada atribut varian',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan atribut seperti Size, Color, dll',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textTertiary,
                ),
          ),
          const SizedBox(height: 16),
          ModernSecondaryButton(
            text: 'Tambah Atribut',
            icon: Icons.add,
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}

class _AttributeEditor {
  String name;
  List<String> values;

  _AttributeEditor({this.name = '', List<String>? values}) : values = values ?? [''];
}

class _AttributeEditorCard extends StatefulWidget {
  final _AttributeEditor editor;
  final int index;
  final Function(_AttributeEditor) onChanged;
  final VoidCallback? onRemove;
  final bool enabled;

  const _AttributeEditorCard({
    required this.editor,
    required this.index,
    required this.onChanged,
    this.onRemove,
    this.enabled = true,
  });

  @override
  State<_AttributeEditorCard> createState() => _AttributeEditorCardState();
}

class _AttributeEditorCardState extends State<_AttributeEditorCard> {
  late TextEditingController _nameController;
  late List<TextEditingController> _valueControllers;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.editor.name);
    _valueControllers = widget.editor.values
        .map((v) => TextEditingController(text: v))
        .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final controller in _valueControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _notifyChanged() {
    widget.onChanged(_AttributeEditor(
      name: _nameController.text,
      values: _valueControllers.map((c) => c.text).toList(),
    ));
  }

  void _addValue() {
    setState(() {
      _valueControllers.add(TextEditingController());
    });
  }

  void _removeValue(int index) {
    if (_valueControllers.length <= 1) return;
    setState(() {
      _valueControllers.removeAt(index).dispose();
      _notifyChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Atribut ${widget.index + 1}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.primaryColor,
                    ),
              ),
              const Spacer(),
              if (widget.onRemove != null)
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.close, size: 18),
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            enabled: widget.enabled,
            decoration: const InputDecoration(
              labelText: 'Nama Atribut',
              hintText: 'Contoh: Size, Color, Material',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _notifyChanged(),
          ),
          const SizedBox(height: 12),
          Text(
            'Nilai Atribut',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          ...List.generate(_valueControllers.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _valueControllers[index],
                      enabled: widget.enabled,
                      decoration: InputDecoration(
                        labelText: 'Nilai ${index + 1}',
                        hintText: 'Contoh: S, M, L',
                        border: const OutlineInputBorder(),
                        suffixIcon: _valueControllers.length > 1 && widget.enabled
                            ? IconButton(
                                onPressed: () => _removeValue(index),
                                icon: const Icon(Icons.remove_circle_outline),
                              )
                            : null,
                      ),
                      onChanged: (_) => _notifyChanged(),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (widget.enabled && _valueControllers.length < 6)
            TextButton.icon(
              onPressed: _addValue,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah Nilai'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _VariantCard extends StatefulWidget {
  final ProductVariant variant;
  final Function(ProductVariant) onChanged;
  final bool enabled;

  const _VariantCard({
    required this.variant,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<_VariantCard> createState() => _VariantCardState();
}

class _VariantCardState extends State<_VariantCard> {
  late TextEditingController _priceController;
  late TextEditingController _costController;
  late TextEditingController _stockController;
  late TextEditingController _skuController;
  late TextEditingController _barcodeController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.variant.price.toStringAsFixed(0),
    );
    _costController = TextEditingController(
      text: widget.variant.costPrice.toStringAsFixed(0),
    );
    _stockController = TextEditingController(
      text: widget.variant.stock.toString(),
    );
    _skuController = TextEditingController(text: widget.variant.sku ?? '');
    _barcodeController = TextEditingController(text: widget.variant.barcode ?? '');
  }

  @override
  void dispose() {
    _priceController.dispose();
    _costController.dispose();
    _stockController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  void _notifyChanged() {
    widget.onChanged(widget.variant.copyWith(
      price: double.tryParse(_priceController.text) ?? widget.variant.price,
      costPrice: double.tryParse(_costController.text) ?? widget.variant.costPrice,
      stock: int.tryParse(_stockController.text) ?? widget.variant.stock,
      sku: _skuController.text.isEmpty ? null : _skuController.text,
      barcode: _barcodeController.text.isEmpty ? null : _barcodeController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.variant.displayName,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const Spacer(),
              _StockIndicator(stock: widget.variant.stock),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _priceController,
                  enabled: widget.enabled,
                  decoration: const InputDecoration(
                    labelText: 'Harga Jual',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => _notifyChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _costController,
                  enabled: widget.enabled,
                  decoration: const InputDecoration(
                    labelText: 'Harga Modal',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => _notifyChanged(),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _stockController,
                  enabled: widget.enabled,
                  decoration: const InputDecoration(
                    labelText: 'Stok',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => _notifyChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _skuController,
                  enabled: widget.enabled,
                  decoration: const InputDecoration(
                    labelText: 'SKU',
                    hintText: 'Opsional',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _notifyChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _barcodeController,
                  enabled: widget.enabled,
                  decoration: const InputDecoration(
                    labelText: 'Barcode',
                    hintText: 'Opsional',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _notifyChanged(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StockIndicator extends StatelessWidget {
  final int stock;

  const _StockIndicator({required this.stock});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    if (stock <= 0) {
      color = AppTheme.errorColor;
      text = 'Habis';
    } else if (stock <= 10) {
      color = AppTheme.warningColor;
      text = '$stock stok';
    } else {
      color = AppTheme.successColor;
      text = '$stock stok';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
