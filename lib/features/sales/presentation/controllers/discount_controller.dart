import 'package:flutter/foundation.dart';
import '../../domain/entities/promotion.dart';
import '../../domain/entities/discount_preset.dart';
import '../../domain/usecases/get_promotions_usecase.dart';
import '../../domain/usecases/add_promotion_usecase.dart';
import '../../domain/usecases/update_promotion_usecase.dart';
import '../../domain/usecases/delete_promotion_usecase.dart';
import '../../domain/usecases/toggle_promotion_usecase.dart';
import '../../domain/usecases/get_discount_presets_usecase.dart';
import '../../domain/usecases/add_discount_preset_usecase.dart';
import '../../domain/usecases/update_discount_preset_usecase.dart';
import '../../domain/usecases/delete_discount_preset_usecase.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Controller for managing discounts (promotions and discount presets)
class DiscountController extends ChangeNotifier {
  // Promotion use cases
  final GetPromotionsUseCase getPromotionsUseCase;
  final AddPromotionUseCase addPromotionUseCase;
  final UpdatePromotionUseCase updatePromotionUseCase;
  final DeletePromotionUseCase deletePromotionUseCase;
  final TogglePromotionUseCase togglePromotionUseCase;

  // Discount preset use cases
  final GetDiscountPresetsUseCase getDiscountPresetsUseCase;
  final AddDiscountPresetUseCase addDiscountPresetUseCase;
  final UpdateDiscountPresetUseCase updateDiscountPresetUseCase;
  final DeleteDiscountPresetUseCase deleteDiscountPresetUseCase;

  bool _disposed = false;

  DiscountController({
    required this.getPromotionsUseCase,
    required this.addPromotionUseCase,
    required this.updatePromotionUseCase,
    required this.deletePromotionUseCase,
    required this.togglePromotionUseCase,
    required this.getDiscountPresetsUseCase,
    required this.addDiscountPresetUseCase,
    required this.updateDiscountPresetUseCase,
    required this.deleteDiscountPresetUseCase,
  }) {
    loadPromotions();
    loadDiscountPresets();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // State
  List<Promotion> _promotions = [];
  List<Promotion> _activePromotions = [];
  List<DiscountPreset> _discountPresets = [];
  bool _isLoading = false;
  AppException? _error;

  // Getters
  List<Promotion> get promotions => _promotions;
  List<Promotion> get activePromotions => _activePromotions;
  List<DiscountPreset> get discountPresets => _discountPresets;
  bool get isLoading => _isLoading;
  AppException? get error => _error;
  bool get hasError => _error != null;
  bool get isEmpty => _promotions.isEmpty && _discountPresets.isEmpty;

  // ========== Promotions ==========

  /// Load all promotions
  Future<void> loadPromotions() async {
    try {
      AppLogger.ui('Loading promotions', details: 'DiscountController');
      _setLoading(true);
      _clearError();

      _promotions = await getPromotionsUseCase.execute();
      _activePromotions = await getPromotionsUseCase.executeActiveOnly();

      AppLogger.info('Promotions loaded successfully - DiscountController');
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to load promotions - DiscountController', error: e);
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal memuat promosi',
        operation: 'loadPromotions',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error loading promotions - DiscountController',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new promotion
  Future<bool> addPromotion({
    required String name,
    required String description,
    required double discountPercentage,
    DateTime? startDate,
    DateTime? endDate,
    bool isEnabled = true,
  }) async {
    try {
      AppLogger.ui('Adding promotion', details: 'DiscountController');
      _setLoading(true);
      _clearError();

      final promotion = Promotion(
        name: name,
        description: description,
        discountPercentage: discountPercentage,
        startDate: startDate,
        endDate: endDate,
        isEnabled: isEnabled,
        createdAt: DateTime.now(),
      );

      final created = await addPromotionUseCase.execute(promotion);

      _promotions.insert(0, created);
      if (created.isActive) {
        _activePromotions.insert(0, created);
      }

      AppLogger.info('Promotion added successfully - DiscountController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to add promotion - DiscountController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal menambahkan promosi',
        operation: 'addPromotion',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error adding promotion - DiscountController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing promotion
  Future<bool> updatePromotion(Promotion promotion) async {
    try {
      AppLogger.ui('Updating promotion', details: 'DiscountController');
      _setLoading(true);
      _clearError();

      final updated = await updatePromotionUseCase.execute(promotion);

      // Update in list
      final index = _promotions.indexWhere((p) => p.id == promotion.id);
      if (index != -1) {
        _promotions[index] = updated;
      }

      // Update active promotions list
      final activeIndex = _activePromotions.indexWhere((p) => p.id == promotion.id);
      if (updated.isActive) {
        if (activeIndex != -1) {
          _activePromotions[activeIndex] = updated;
        } else {
          _activePromotions.add(updated);
        }
      } else {
        if (activeIndex != -1) {
          _activePromotions.removeAt(activeIndex);
        }
      }

      AppLogger.info('Promotion updated successfully - DiscountController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to update promotion - DiscountController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal mengupdate promosi',
        operation: 'updatePromotion',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error updating promotion - DiscountController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a promotion
  Future<bool> deletePromotion(int promotionId) async {
    try {
      AppLogger.ui('Deleting promotion', details: 'DiscountController');
      _setLoading(true);
      _clearError();

      await deletePromotionUseCase.execute(promotionId);

      _promotions.removeWhere((p) => p.id == promotionId);
      _activePromotions.removeWhere((p) => p.id == promotionId);

      AppLogger.info('Promotion deleted successfully - DiscountController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to delete promotion - DiscountController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal menghapus promosi',
        operation: 'deletePromotion',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error deleting promotion - DiscountController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle promotion enabled status
  Future<bool> togglePromotion(int promotionId, bool isEnabled) async {
    try {
      AppLogger.ui('Toggling promotion', details: 'DiscountController');
      _setLoading(true);
      _clearError();

      final updated = await togglePromotionUseCase.execute(promotionId, isEnabled);

      // Update in list
      final index = _promotions.indexWhere((p) => p.id == promotionId);
      if (index != -1) {
        _promotions[index] = updated;
      }

      // Update active promotions list
      final activeIndex = _activePromotions.indexWhere((p) => p.id == promotionId);
      if (updated.isActive) {
        if (activeIndex == -1) {
          _activePromotions.add(updated);
        }
      } else {
        if (activeIndex != -1) {
          _activePromotions.removeAt(activeIndex);
        }
      }

      AppLogger.info('Promotion toggled successfully - DiscountController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to toggle promotion - DiscountController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal mengubah status promosi',
        operation: 'togglePromotion',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error toggling promotion - DiscountController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ========== Discount Presets ==========

  /// Load all discount presets
  Future<void> loadDiscountPresets() async {
    try {
      AppLogger.ui('Loading discount presets', details: 'DiscountController');
      _setLoading(true);
      _clearError();

      _discountPresets = await getDiscountPresetsUseCase.execute();

      AppLogger.info('Discount presets loaded successfully - DiscountController');
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to load discount presets - DiscountController', error: e);
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal memuat preset diskon',
        operation: 'loadDiscountPresets',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error loading discount presets - DiscountController',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new discount preset
  Future<bool> addDiscountPreset({
    required String name,
    required String description,
    required double discountPercentage,
  }) async {
    try {
      AppLogger.ui('Adding discount preset', details: 'DiscountController');
      _setLoading(true);
      _clearError();

      final preset = DiscountPreset(
        name: name,
        description: description,
        discountPercentage: discountPercentage,
        createdAt: DateTime.now(),
      );

      final created = await addDiscountPresetUseCase.execute(preset);

      _discountPresets.insert(0, created);

      AppLogger.info('Discount preset added successfully - DiscountController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to add discount preset - DiscountController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal menambahkan preset diskon',
        operation: 'addDiscountPreset',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error adding discount preset - DiscountController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing discount preset
  Future<bool> updateDiscountPreset(DiscountPreset preset) async {
    try {
      AppLogger.ui('Updating discount preset', details: 'DiscountController');
      _setLoading(true);
      _clearError();

      final updated = await updateDiscountPresetUseCase.execute(preset);

      // Update in list
      final index = _discountPresets.indexWhere((p) => p.id == preset.id);
      if (index != -1) {
        _discountPresets[index] = updated;
      }

      AppLogger.info('Discount preset updated successfully - DiscountController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to update discount preset - DiscountController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal mengupdate preset diskon',
        operation: 'updateDiscountPreset',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error updating discount preset - DiscountController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a discount preset
  Future<bool> deleteDiscountPreset(int presetId) async {
    try {
      AppLogger.ui('Deleting discount preset', details: 'DiscountController');
      _setLoading(true);
      _clearError();

      await deleteDiscountPresetUseCase.execute(presetId);

      _discountPresets.removeWhere((p) => p.id == presetId);

      AppLogger.info('Discount preset deleted successfully - DiscountController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to delete discount preset - DiscountController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal menghapus preset diskon',
        operation: 'deleteDiscountPreset',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error deleting discount preset - DiscountController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear error
  void clearError() {
    _clearError();
  }

  // Private methods

  void _setLoading(bool value) {
    _isLoading = value;
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _setError(AppException error) {
    _error = error;
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _clearError() {
    _error = null;
    if (!_disposed) {
      notifyListeners();
    }
  }
}
