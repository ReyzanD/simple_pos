import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../../../shared/presentation/providers.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Screen for managing categories
class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(categoryControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.category_title)),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.categories.isEmpty
          ? _buildEmptyState(context)
          : _buildCategoryList(controller),
      floatingActionButton: FloatingActionButton(
        heroTag: 'category_fab', // ✅ Unique hero tag
        onPressed: () => _showAddEditDialog(context, controller),
        tooltip: AppLocalizations.of(context)!.category_add,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category, size: 64, color: AppTheme.textTertiary),
          const SizedBox(height: UIConstants.spacingMedium),
          Text(
            AppLocalizations.of(context)!.category_noCategories,
            style: TextStyle(
              fontSize: UIConstants.fontSizeLarge,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: UIConstants.spacingSmall),
          Text(
            AppLocalizations.of(context)!.category_noCategories,
            style: TextStyle(color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(dynamic controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(UIConstants.spacingSmall),
      itemCount: controller.categories.length,
      itemBuilder: (context, index) {
        final category = controller.categories[index];
        return _buildCategoryCard(context, category, controller);
      },
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    Category category,
    dynamic controller,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingSmall),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: UIConstants.primaryColor.withValues(alpha: 0.1),
          child: Icon(Icons.category, color: UIConstants.primaryColor),
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
              onPressed: () =>
                  _showAddEditDialog(context, controller, category),
              tooltip: AppLocalizations.of(context)!.common_edit,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete,
                size: 20,
                color: AppTheme.errorColor,
              ),
              onPressed: () => _showDeleteDialog(context, category, controller),
              tooltip: AppLocalizations.of(context)!.common_delete,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddEditDialog(
    BuildContext context,
    dynamic controller, [
    Category? category,
  ]) async {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descriptionController = TextEditingController(
      text: category?.description ?? '',
    );
    final formKey = GlobalKey<FormState>();

    final isEditing = category != null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isEditing
              ? AppLocalizations.of(context)!.category_edit
              : AppLocalizations.of(context)!.category_add,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.category_name,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.category_nameRequired;
                  }
                  if (value.trim().length < 2) {
                    return AppLocalizations.of(context)!.category_nameTooShort;
                  }
                  return null;
                },
              ),
              const SizedBox(height: UIConstants.spacingMedium),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.category_description,
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
            child: Text(AppLocalizations.of(context)!.common_cancel),
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
                      content: Text(
                        success
                            ? AppLocalizations.of(context)!.category_addSuccess
                            : controller.errorMessage ??
                                  AppLocalizations.of(context)!.common_error,
                      ),
                      backgroundColor: success
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            child: Text(
              isEditing
                  ? AppLocalizations.of(context)!.common_save
                  : AppLocalizations.of(context)!.category_add,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    Category category,
    dynamic controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.category_delete),
        content: Text(AppLocalizations.of(context)!.category_deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.common_cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text(AppLocalizations.of(context)!.common_delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await controller.deleteCategory(category.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? AppLocalizations.of(context).category_deleteSuccess
                  : controller.errorMessage ??
                        AppLocalizations.of(context).common_error,
            ),
            backgroundColor: success
                ? AppTheme.successColor
                : AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
