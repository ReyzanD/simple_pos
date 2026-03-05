import '../entities/promotion.dart';

/// Repository interface for promotions
abstract class PromotionRepository {
  /// Retrieves all promotions
  Future<List<Promotion>> getPromotions();

  /// Retrieves only active promotions (enabled and within date range)
  Future<List<Promotion>> getActivePromotions();

  /// Retrieves a single promotion by ID
  Future<Promotion> getPromotionById(int id);

  /// Creates a new promotion
  Future<Promotion> createPromotion(Promotion promotion);

  /// Updates an existing promotion
  Future<Promotion> updatePromotion(Promotion promotion);

  /// Deletes a promotion
  Future<void> deletePromotion(int id);

  /// Toggles promotion enabled status
  Future<Promotion> togglePromotion(int id, bool isEnabled);
}
