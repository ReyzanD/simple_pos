import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme.dart';
import '../../domain/entities/discount_preset.dart';

/// Dialog for adding or editing a reusable discount preset
class AddPresetDialog extends StatefulWidget {
  final Future<bool> Function({
    required String name,
    required String description,
    required double discountPercentage,
  }) onAdd;

  final Future<bool> Function(DiscountPreset)? onUpdate;
  final DiscountPreset? preset;

  const AddPresetDialog({
    super.key,
    required this.onAdd,
    this.onUpdate,
    this.preset,
  });

  @override
  State<AddPresetDialog> createState() => _AddPresetDialogState();
}

class _AddPresetDialogState extends State<AddPresetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _discountController;

  bool _isSaving = false;

  bool get _isEditing => widget.preset != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.preset?.name ?? '');
    _descriptionController = TextEditingController(text: widget.preset?.description ?? '');
    _discountController = TextEditingController(
      text: widget.preset?.discountPercentage.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    bool success = false;

    if (_isEditing && widget.onUpdate != null) {
      // Update existing preset
      final updatedPreset = widget.preset!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        discountPercentage: double.parse(_discountController.text),
      );
      success = await widget.onUpdate!(updatedPreset);
    } else {
      // Add new preset
      success = await widget.onAdd(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        discountPercentage: double.parse(_discountController.text),
      );
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Preset diskon berhasil diupdate' : 'Preset diskon berhasil ditambahkan'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
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
              color: AppTheme.infoColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isEditing ? Icons.edit : Icons.bookmark,
              color: AppTheme.infoColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(_isEditing ? 'Edit Preset Diskon' : 'Buat Preset Diskon'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Preset',
                hintText: 'Contoh: Diskon Akhir Pekan',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama preset wajib diisi';
                }
                if (value.trim().length < 3) {
                  return 'Nama minimal 3 karakter';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Jelaskan preset diskon ini',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 16),

            // Discount Percentage
            TextFormField(
              controller: _discountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Diskon (%)',
                hintText: '0-100',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.percent),
                suffixText: '%',
                helperText: 'Preset ini bisa digunakan kembali nanti',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Diskon wajib diisi';
                }
                final discount = double.tryParse(value);
                if (discount == null || discount < 0 || discount > 100) {
                  return 'Masukkan angka 0-100';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.infoColor,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(_isEditing ? 'Update' : 'Buat Preset'),
        ),
      ],
    );
  }
}
