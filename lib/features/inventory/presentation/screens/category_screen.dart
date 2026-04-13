import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/category.dart';
import '../controllers/category_controller.dart';
import '../../../../core/constants/ui_constants.dart';

/// Screen for managing categories
class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Kategori'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.categories.isEmpty
                  ? _buildEmptyState(context)
                  : _buildCategoryList(controller),
          floatingActionButton: FloatingActionButton(
            heroTag: 'category_fab', // ✅ Unique hero tag
            onPressed: () => _showAddEditDialog(context, controller),
            tooltip: 'Tambah Kategori',
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
            Icons.category,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: UIConstants.spacingMedium),
          Text(
            'Tidak ada kategori',
            style: TextStyle(
              fontSize: UIConstants.fontSizeLarge,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: UIConstants.spacingSmall),
          Text(
            'Tekan + untuk menambah kategori',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(CategoryController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(UIConstants.spacingSmall),
      itemCount: controller.categories.length,
      itemBuilder: (context, index) {
        final category = controller.categories[index];
        return _buildCategoryCard(context, category, controller);
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category, CategoryController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingSmall),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: UIConstants.primaryColor.withValues(alpha: 0.1),
          child: Icon(
            Icons.category,
            color: UIConstants.primaryColor,
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: category.description != null
            ? Text(category.description!)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showAddEditDialog(context, controller, category),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _showDeleteDialog(context, category, controller),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddEditDialog(
    BuildContext context,
    CategoryController controller, [
    Category? category,
  ]) async {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descriptionController = TextEditingController(text: category?.description ?? '');
    final formKey = GlobalKey<FormState>();

    final isEditing = category != null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Kategori' : 'Tambah Kategori'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kategori',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama kategori wajib diisi';
                  }
                  if (value.trim().length < 2) {
                    return 'Nama kategori minimal 2 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: UIConstants.spacingMedium),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (Opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
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
                final newCategory = Category(
                  id: category?.id,
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                  createdAt: category?.createdAt ?? DateTime.now(),
                );

                Navigator.pop(context);

                final success = isEditing
                    ? await controller.updateCategory(newCategory)
                    : await controller.addCategory(newCategory);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Kategori berhasil disimpan'
                          : controller.errorMessage ?? 'Gagal menyimpan kategori'),
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
    Category category,
    CategoryController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text(
          'Apakah Anda yakin ingin menghapus kategori "${category.name}"?',
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
      final success = await controller.deleteCategory(category.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Kategori berhasil dihapus'
                : controller.errorMessage ?? 'Gagal menghapus kategori'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
