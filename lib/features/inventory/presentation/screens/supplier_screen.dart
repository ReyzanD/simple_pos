import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/supplier.dart';
import '../../../shared/presentation/providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../l10n/app_localizations.dart';

/// Screen for managing suppliers with search and contact actions
class SupplierScreen extends ConsumerStatefulWidget {
  const SupplierScreen({super.key});

  @override
  ConsumerState<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends ConsumerState<SupplierScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Supplier> _filterSuppliers(List<Supplier> suppliers) {
    if (_searchQuery.isEmpty) return suppliers;

    final query = _searchQuery.toLowerCase();
    return suppliers.where((supplier) {
      return supplier.name.toLowerCase().contains(query) ||
          (supplier.contactPerson?.toLowerCase().contains(query) ?? false) ||
          (supplier.phone?.contains(query) ?? false) ||
          (supplier.email?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final supplierController = ref.watch(supplierControllerProvider);
    final inventoryController = ref.watch(inventoryControllerProvider);
    final filteredSuppliers = _filterSuppliers(supplierController.suppliers);
    final products = inventoryController.allProducts;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.supplier_title)),
      body: supplierController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : supplierController.suppliers.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: _buildSupplierList(filteredSuppliers, products),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'supplier_fab', // ✅ Unique hero tag
        onPressed: () => _showAddEditDialog(context, supplierController),
        tooltip: AppLocalizations.of(context)!.supplier_add,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _searchQuery.isNotEmpty
              ? AppTheme.primaryColor.withValues(alpha: 0.5)
              : AppTheme.getBorderColor(context),
          width: 2,
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.common_search,
          hintStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context)),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppTheme.getTextSecondaryColor(context),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping, size: 64, color: AppTheme.textTertiary),
          const SizedBox(height: UIConstants.spacingMedium),
          Text(
            AppLocalizations.of(context)!.supplier_noSuppliers,
            style: TextStyle(
              fontSize: UIConstants.fontSizeLarge,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: UIConstants.spacingSmall),
          Text(
            AppLocalizations.of(context)!.supplier_noSuppliers,
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierList(List<Supplier> suppliers, List products) {
    if (suppliers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(
                context,
              )!.common_supplierNotFound(_searchQuery),
              style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(UIConstants.spacingSmall),
      itemCount: suppliers.length,
      itemBuilder: (context, index) {
        final supplier = suppliers[index];
        // Count products for this supplier
        final productCount = products
            .where((p) => p.supplierId == supplier.id)
            .length;
        return _buildSupplierCard(context, supplier, productCount);
      },
    );
  }

  Widget _buildSupplierCard(
    BuildContext context,
    Supplier supplier,
    int productCount,
  ) {
    final controller = ref.read(supplierControllerProvider);
    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingSmall),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.getBorderColor(context)),
      ),
      child: InkWell(
        onTap: () => _showAddEditDialog(context, controller, supplier),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and contact actions
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_shipping,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplier.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.getTextPrimaryColor(context),
                          ),
                        ),
                        if (supplier.contactPerson != null)
                          Text(
                            supplier.contactPerson!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Contact action buttons
                  if (supplier.phone != null)
                    _buildContactButton(
                      icon: Icons.phone_rounded,
                      color: AppTheme.successColor,
                      onTap: () => _callSupplier(supplier.phone!),
                    ),
                  if (supplier.email != null)
                    _buildContactButton(
                      icon: Icons.email_rounded,
                      color: AppTheme.infoColor,
                      onTap: () => _emailSupplier(supplier.email!),
                    ),
                  _buildEditButton(
                    icon: Icons.edit,
                    color: AppTheme.textSecondary,
                    onTap: () =>
                        _showAddEditDialog(context, controller, supplier),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Contact info
              _buildContactInfo(context, supplier),
              const SizedBox(height: 8),
              // Action row
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 16,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${AppLocalizations.of(context)!.product_stok}: $productCount',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  _buildDeleteButton(context, supplier, controller),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildEditButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: Material(
        color: AppTheme.getCardColor(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context, Supplier supplier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (supplier.phone != null)
          _buildInfoRow(context, Icons.phone_outlined, supplier.phone!),
        if (supplier.email != null)
          _buildInfoRow(context, Icons.email_outlined, supplier.email!),
        if (supplier.address != null)
          _buildInfoRow(context, Icons.location_on_outlined, supplier.address!),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.textTertiary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(
    BuildContext context,
    Supplier supplier,
    dynamic controller,
  ) {
    return TextButton.icon(
      onPressed: () => _showDeleteDialog(context, supplier, controller),
      icon: Icon(Icons.delete_outline, size: 16, color: AppTheme.errorColor),
      label: Text(
        AppLocalizations.of(context)!.common_delete,
        style: TextStyle(fontSize: 12, color: AppTheme.errorColor),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Future<void> _callSupplier(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(launchUri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.common_cannotOpenDialer,
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _emailSupplier(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (!await launchUrl(launchUri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.common_cannotOpenEmail),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _showAddEditDialog(
    BuildContext context,
    dynamic controller, [
    Supplier? supplier,
  ]) async {
    final nameController = TextEditingController(text: supplier?.name ?? '');
    final contactController = TextEditingController(
      text: supplier?.contactPerson ?? '',
    );
    final phoneController = TextEditingController(text: supplier?.phone ?? '');
    final emailController = TextEditingController(text: supplier?.email ?? '');
    final addressController = TextEditingController(
      text: supplier?.address ?? '',
    );
    final formKey = GlobalKey<FormState>();

    final isEditing = supplier != null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEditing
              ? AppLocalizations.of(context)!.supplier_edit
              : AppLocalizations.of(context)!.supplier_add,
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.supplier_name,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppTheme.getCardColor(context),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(
                        context,
                      )!.supplier_nameRequired;
                    }
                    if (value.trim().length < 2) {
                      return AppLocalizations.of(
                        context,
                      )!.supplier_nameTooShort;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: UIConstants.spacingMedium),
                TextFormField(
                  controller: contactController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    )!.common_contactPersonOptional,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppTheme.getCardColor(context),
                  ),
                ),
                const SizedBox(height: UIConstants.spacingSmall),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    )!.common_phoneOptional,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppTheme.getCardColor(context),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: UIConstants.spacingSmall),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    )!.common_emailOptional,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppTheme.getCardColor(context),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: UIConstants.spacingSmall),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    )!.common_addressOptional,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppTheme.getCardColor(context),
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
            child: Text(AppLocalizations.of(context)!.common_cancel),
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
                      content: Text(
                        success
                            ? AppLocalizations.of(
                                context,
                              )!.common_supplierSaveSuccess
                            : controller.errorMessage ??
                                  AppLocalizations.of(
                                    context,
                                  )!.common_supplierSaveFailed,
                      ),
                      backgroundColor: success
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: Text(
              isEditing
                  ? AppLocalizations.of(context)!.common_save
                  : AppLocalizations.of(context)!.common_add,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    Supplier supplier,
    dynamic controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.errorColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(AppLocalizations.of(context)!.supplier_delete),
          ],
        ),
        content: Text(AppLocalizations.of(context)!.supplier_deleteConfirm),
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
      final success = await controller.deleteSupplier(supplier.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? AppLocalizations.of(context)!.common_supplierDeleteSuccess
                  : controller.errorMessage ??
                        AppLocalizations.of(
                          context,
                        )!.common_supplierDeleteFailed,
            ),
            backgroundColor: success
                ? AppTheme.successColor
                : AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}
