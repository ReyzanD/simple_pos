import '../entities/discount_preset.dart';

/// Repository interface for discount presets
abstract class DiscountPresetRepository {
  /// Retrieves all discount presets
  Future<List<DiscountPreset>> getDiscountPresets();

  /// Retrieves a single discount preset by ID
  Future<DiscountPreset> getDiscountPresetById(int id);

  /// Creates a new discount preset
  Future<DiscountPreset> createDiscountPreset(DiscountPreset preset);

  /// Updates an existing discount preset
  Future<DiscountPreset> updateDiscountPreset(DiscountPreset preset);

  /// Deletes a discount preset
  Future<void> deleteDiscountPreset(int id);
}
