// lib/features/pos/presentation/controllers/favorites_controller.dart
import 'package:flutter/foundation.dart';
import '../../data/repositories/favorites_repository.dart';

/// Controller for managing favorites state
class FavoritesController extends ChangeNotifier {
  final FavoritesRepository _repository;

  FavoritesController(this._repository);

  Set<String> _favorites = {};

  /// Get current favorites
  Set<String> get favorites => _favorites;

  /// Check if product is favorited
  bool isFavorite(String productId) => _favorites.contains(productId);

  /// Load favorites from storage
  Future<void> loadFavorites() async {
    _favorites = await _repository.getFavorites();
    notifyListeners();
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String productId) async {
    final added = await _repository.toggleFavorite(productId);
    if (added) {
      _favorites.add(productId);
    } else {
      _favorites.remove(productId);
    }
    notifyListeners();
    return added;
  }

  /// Add to favorites
  Future<void> addFavorite(String productId) async {
    await _repository.addFavorite(productId);
    _favorites.add(productId);
    notifyListeners();
  }

  /// Remove from favorites
  Future<void> removeFavorite(String productId) async {
    await _repository.removeFavorite(productId);
    _favorites.remove(productId);
    notifyListeners();
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    await _repository.clearFavorites();
    _favorites.clear();
    notifyListeners();
  }
}
