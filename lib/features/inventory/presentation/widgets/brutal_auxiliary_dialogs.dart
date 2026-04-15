import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../inventory/domain/entities/category.dart' as entities;
import '../../../inventory/domain/entities/supplier.dart';
import '../controllers/category_controller.dart';
import '../controllers/supplier_controller.dart';

class BrutalAddCategoryDialog extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  final GlobalKey<FormState> formKey;

  const BrutalAddCategoryDialog({
    super.key,
    required this.nameController,
    required this.descController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseDialog(
      title: 'KATEGORI BARU',
      color: NeoBrutalTheme.primary,
      icon: Icons.category_rounded,
      onSave: () async {
        if (formKey.currentState!.validate()) {
          final controller = context.read<CategoryController>();
          final success = await controller.addCategory(
            entities.Category(
              id: 0,
              name: nameController.text.trim(),
              description: descController.text.isEmpty
                  ? null
                  : descController.text.trim(),
              createdAt: DateTime.now(),
            ),
          );
          if (context.mounted) Navigator.pop(context, success);
        }
      },
      child: Form(
        key: formKey,
        child: Column(
          children: [
            _DialogInput(
              controller: nameController,
              label: 'NAMA KATEGORI',
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            _DialogInput(
              controller: descController,
              label: 'DESKRIPSI',
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class BrutalAddSupplierDialog extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController contactController;
  final TextEditingController phoneController;
  final GlobalKey<FormState> formKey;

  const BrutalAddSupplierDialog({
    super.key,
    required this.nameController,
    required this.contactController,
    required this.phoneController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseDialog(
      title: 'PEMASOK BARU',
      color: NeoBrutalTheme.secondary,
      icon: Icons.local_shipping_rounded,
      onSave: () async {
        if (formKey.currentState!.validate()) {
          final controller = context.read<SupplierController>();
          final success = await controller.addSupplier(
            Supplier(
              id: 0,
              name: nameController.text.trim(),
              contactPerson: contactController.text.trim(),
              phone: phoneController.text.trim(),
              createdAt: DateTime.now(),
            ),
          );
          if (context.mounted) Navigator.pop(context, success);
        }
      },
      child: Form(
        key: formKey,
        child: Column(
          children: [
            _DialogInput(
              controller: nameController,
              label: 'NAMA PEMASOK',
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            _DialogInput(controller: contactController, label: 'KONTAK'),
            const SizedBox(height: 16),
            _DialogInput(
              controller: phoneController,
              label: 'TELEPON',
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }
}

// --- Internal Helper Components ---

class _BaseDialog extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final Widget child;
  final VoidCallback onSave;

  const _BaseDialog({
    required this.title,
    required this.color,
    required this.icon,
    required this.child,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusLarge),
          border: Border.all(color: Colors.black, width: 5),
          boxShadow: NeoBrutalTheme.chunkyShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Padding(padding: const EdgeInsets.all(20), child: child),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color,
      border: const Border(bottom: BorderSide(color: Colors.black, width: 5)),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(width: 12),
        Text(
          title,
          style: NeoBrutalTheme.headlineSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );

  Widget _buildActions(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Expanded(
          child: _Btn(
            text: 'BATAL',
            onTap: () => Navigator.pop(context),
            color: Colors.white,
            textColor: Colors.black,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Btn(
            text: 'SIMPAN',
            onTap: onSave,
            color: color,
            textColor: Colors.white,
          ),
        ),
      ],
    ),
  );
}

class _DialogInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _DialogInput({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}

class _Btn extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;
  const _Btn({
    required this.text,
    required this.onTap,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
