import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/supplier.dart';
import '../controllers/supplier_controller.dart';
import '../../../../core/constants/ui_constants.dart';

/// Screen for managing suppliers
class SupplierScreen extends StatelessWidget {
  const SupplierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SupplierController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Pemasok'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.suppliers.isEmpty
                  ? _buildEmptyState(context)
                  : _buildSupplierList(controller),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddEditDialog(context, controller),
            tooltip: 'Tambah Pemasok',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: UIConstants.spacingMedium),
          Text(
            'Tidak ada pemasok',
            style: TextStyle(
              fontSize: UIConstants.fontSizeLarge,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: UIConstants.spacingSmall),
          Text(
            'Tekan + untuk menambah pemasok',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierList(SupplierController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(UIConstants.spacingSmall),
      itemCount: controller.suppliers.length,
      itemBuilder: (context, index) {
        final supplier = controller.suppliers[index];
        return _buildSupplierCard(context, supplier, controller);
      },
    );
  }

  Widget _buildSupplierCard(BuildContext context, Supplier supplier, SupplierController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingSmall),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: UIConstants.primaryColor.withValues(alpha: 0.1),
          child: Icon(
            Icons.local_shipping,
            color: UIConstants.primaryColor,
          ),
        ),
        title: Text(
          supplier.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (supplier.contactPerson != null)
              Text('Kontak: ${supplier.contactPerson}'),
            if (supplier.phone != null)
              Text('Telepon: ${supplier.phone}'),
            if (supplier.email != null)
              Text('Email: ${supplier.email}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showAddEditDialog(context, controller, supplier),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _showDeleteDialog(context, supplier, controller),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddEditDialog(
    BuildContext context,
    SupplierController controller, [
    Supplier? supplier,
  ]) async {
    final nameController = TextEditingController(text: supplier?.name ?? '');
    final contactController = TextEditingController(text: supplier?.contactPerson ?? '');
    final phoneController = TextEditingController(text: supplier?.phone ?? '');
    final emailController = TextEditingController(text: supplier?.email ?? '');
    final addressController = TextEditingController(text: supplier?.address ?? '');
    final formKey = GlobalKey<FormState>();

    final isEditing = supplier != null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Pemasok' : 'Tambah Pemasok'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Pemasok',
                    border: OutlineInputBorder(),
                  ),
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
                const SizedBox(height: UIConstants.spacingMedium),
                TextFormField(
                  controller: contactController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Kontak (Opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: UIConstants.spacingSmall),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telepon (Opsional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: UIConstants.spacingSmall),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email (Opsional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: UIConstants.spacingSmall),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Alamat (Opsional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newSupplier = Supplier(
                  id: supplier?.id,
                  name: nameController.text.trim(),
                  contactPerson: contactController.text.trim().isEmpty
                      ? null
                      : contactController.text.trim(),
                  phone: phoneController.text.trim().isEmpty
                      ? null
                      : phoneController.text.trim(),
                  email: emailController.text.trim().isEmpty
                      ? null
                      : emailController.text.trim(),
                  address: addressController.text.trim().isEmpty
                      ? null
                      : addressController.text.trim(),
                  createdAt: supplier?.createdAt ?? DateTime.now(),
                );

                Navigator.pop(context);

                final success = isEditing
                    ? await controller.updateSupplier(newSupplier)
                    : await controller.addSupplier(newSupplier);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Pemasok berhasil disimpan'
                          : controller.errorMessage ?? 'Gagal menyimpan pemasok'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(isEditing ? 'Simpan' : 'Tambah'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    Supplier supplier,
    SupplierController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pemasok'),
        content: Text(
          'Apakah Anda yakin ingin menghapus pemasok "${supplier.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await controller.deleteSupplier(supplier.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Pemasok berhasil dihapus'
                : controller.errorMessage ?? 'Gagal menghapus pemasok'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
