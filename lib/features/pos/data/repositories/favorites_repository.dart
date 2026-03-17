// lib/features/pos/data/repositories/favorites_repository.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for managing favorite products
/// Persists favorite product IDs using SharedPreferences
class FavoritesRepository {
  static const String _key = 'favorite_product_ids';

  /// Get SharedPreferences instance
  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  /// Get all favorite product IDs
  Future<Set<String>> getFavorites() async {
    final prefs = await _getPrefs();
    final List<String>? favorites = prefs.getStringList(_key);
    return favorites?.toSet() ?? {};
  }

  /// Check if a product is favorited
  Future<bool> isFavorite(String productId) async {
    final favorites = await getFavorites();
    return favorites.contains(productId);
  }

  /// Add a product to favorites
  Future<void> addFavorite(String productId) async {
    final prefs = await _getPrefs();
    final current = await getFavorites();
    current.add(productId);
    await prefs.setStringList(_key, current.toList());
  }

  /// Remove a product from favorites
  Future<void> removeFavorite(String productId) async {
    final prefs = await _getPrefs();
    final current = await getFavorites();
    current.remove(productId);
    await prefs.setStringList(_key, current.toList());
  }

  /// Toggle favorite status
  /// Returns true if added, false if removed
  Future<bool> toggleFavorite(String productId) async {
    if (await isFavorite(productId)) {
      await removeFavorite(productId);
      return false;
    } else {
      await addFavorite(productId);
      return true;
    }
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    final prefs = await _getPrefs();
    await prefs.remove(_key);
  }
}
