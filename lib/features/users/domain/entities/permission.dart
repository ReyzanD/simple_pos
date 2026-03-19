/// Permission enum for role-based access control
enum Permission {
  // POS permissions
  posProcessSales,
  posApplyDiscounts,
  posProcessReturns,

  // Inventory permissions
  inventoryView,
  inventoryAdd,
  inventoryEdit,
  inventoryDelete,

  // Sales permissions
  salesViewReports,
  salesManagePromotions,

  // Settings permissions
  settingsView,
  settingsManageUsers,
  settingsManagePrinters,
  settingsManageData;
}

/// Extension for Permission to provide display names
extension PermissionExtension on Permission {
  /// Get the display name for the permission (Indonesian)
  String get displayName {
    switch (this) {
      case Permission.posProcessSales:
        return 'Proses Penjualan';
      case Permission.posApplyDiscounts:
        return 'Terapkan Diskon';
      case Permission.posProcessReturns:
        return 'Proses Retur';
      case Permission.inventoryView:
        return 'Lihat Inventaris';
      case Permission.inventoryAdd:
        return 'Tambah Produk';
      case Permission.inventoryEdit:
        return 'Edit Produk';
      case Permission.inventoryDelete:
        return 'Hapus Produk';
      case Permission.salesViewReports:
        return 'Lihat Laporan';
      case Permission.salesManagePromotions:
        return 'Kelola Promosi';
      case Permission.settingsView:
        return 'Akses Pengaturan';
      case Permission.settingsManageUsers:
        return 'Kelola Pengguna';
      case Permission.settingsManagePrinters:
        return 'Kelola Printer';
      case Permission.settingsManageData:
        return 'Kelola Data';
    }
  }
}
