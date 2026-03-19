/// Constants for expense categories
class ExpenseCategories {
  /// Predefined expense categories (Indonesian)
  static const List<String> predefined = [
    'Sewa',
    'Listrik & Air',
    'Perlengkapan',
    'Pemeliharaan',
    'Gaji Karyawan',
    'Lain-lain',
  ];

  /// Get all categories including custom ones
  static List<String> withCustom(List<String> customCategories) {
    return [...predefined, ...customCategories];
  }

  /// Check if category is predefined
  static bool isPredefined(String category) {
    return predefined.contains(category);
  }

  /// Get category icon (for UI display)
  static String getCategoryIcon(String category) {
    switch (category) {
      case 'Sewa':
        return 'home';
      case 'Listrik & Air':
        return 'bolt';
      case 'Perlengkapan':
        return 'shopping_cart';
      case 'Pemeliharaan':
        return 'build';
      case 'Gaji Karyawan':
        return 'people';
      default:
        return 'receipt';
    }
  }

  /// Get category color (for UI display)
  static String getCategoryColor(String category) {
    switch (category) {
      case 'Sewa':
        return 'purple';
      case 'Listrik & Air':
        return 'yellow';
      case 'Perlengkapan':
        return 'blue';
      case 'Pemeliharaan':
        return 'orange';
      case 'Gaji Karyawan':
        return 'green';
      default:
        return 'grey';
    }
  }
}
