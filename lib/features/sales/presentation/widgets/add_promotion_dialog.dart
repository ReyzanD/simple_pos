import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme.dart';

/// Dialog for adding a new time-limited promotion campaign
class AddPromotionDialog extends StatefulWidget {
  final Future<bool> Function({
    required String name,
    required String description,
    required double discountPercentage,
    DateTime? startDate,
    DateTime? endDate,
    bool isEnabled,
  }) onAdd;

  const AddPromotionDialog({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddPromotionDialog> createState() => _AddPromotionDialogState();
}

class _AddPromotionDialogState extends State<AddPromotionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isEnabled = true;
  bool _isSaving = false;

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

    final success = await widget.onAdd(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      discountPercentage: double.parse(_discountController.text),
      startDate: _startDate,
      endDate: _endDate,
      isEnabled: _isEnabled,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Promosi berhasil ditambahkan'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && mounted) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, clear it
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && mounted) {
      setState(() => _endDate = picked);
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
              color: AppTheme.warningColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.campaign,
              color: AppTheme.warningColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Buat Promosi Baru'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Promosi',
                  hintText: 'Contoh: Flash Sale Akhir Tahun',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama promosi wajib diisi';
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
                  hintText: 'Jelaskan promosi ini',
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
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 16),

              // Date Range
              Text(
                'Periode Promosi (Opsional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectStartDate,
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        _startDate == null
                            ? 'Mulai'
                            : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _startDate == null ? null : _selectEndDate,
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        _endDate == null
                            ? 'Selesai'
                            : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (_startDate != null && _endDate == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Tanpa tanggal selesai, promosi akan terus berjalan',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.infoColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Enabled toggle
              SwitchListTile(
                title: const Text('Aktifkan Promosi'),
                subtitle: Text(
                  _isEnabled
                      ? 'Promosi akan langsung aktif'
                      : 'Promosi akan dibuat dalam kondisi nonaktif',
                ),
                value: _isEnabled,
                onChanged: (value) => setState(() => _isEnabled = value),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
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
            backgroundColor: AppTheme.warningColor,
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
              : const Text('Buat Promosi'),
        ),
      ],
    );
  }
}
