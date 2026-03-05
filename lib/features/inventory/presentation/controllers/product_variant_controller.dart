import 'package:flutter/foundation.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/entities/variant_attribute.dart';
import '../../domain/usecases/get_product_variants_usecase.dart';
import '../../domain/usecases/add_product_variant_usecase.dart';
import '../../domain/usecases/update_product_variant_usecase.dart';
import '../../domain/usecases/delete_product_variant_usecase.dart';
import '../../domain/usecases/variant_attribute_usecases.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Controller for managing product variant state and operations
class ProductVariantController extends ChangeNotifier {
  final GetProductVariantsUseCase getVariantsUseCase;
  final AddProductVariantUseCase addVariantUseCase;
  final AddProductVariantsBatchUseCase addVariantsBatchUseCase;
  final UpdateProductVariantUseCase updateVariantUseCase;
  final UpdateVariantStockUseCase updateVariantStockUseCase;
  final DeleteProductVariantUseCase deleteVariantUseCase;
  final DeleteProductVariantsByProductIdUseCase deleteVariantsByProductIdUseCase;
  final GetVariantAttributesUseCase getAttributesUseCase;
  final AddVariantAttributeUseCase addAttributeUseCase;
  final AddVariantAttributesBatchUseCase addAttributesBatchUseCase;
  final DeleteVariantAttributesByProductIdUseCase deleteAttributesByProductIdUseCase;

  bool _disposed = false;

  ProductVariantController({
    required this.getVariantsUseCase,
    required this.addVariantUseCase,
    required this.addVariantsBatchUseCase,
    required this.updateVariantUseCase,
    required this.updateVariantStockUseCase,
    required this.deleteVariantUseCase,
    required this.deleteVariantsByProductIdUseCase,
    required this.getAttributesUseCase,
    required this.addAttributeUseCase,
    required this.addAttributesBatchUseCase,
    required this.deleteAttributesByProductIdUseCase,
  });

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // State
  List<ProductVariant> _variants = [];
  List<VariantAttribute> _attributes = [];
  bool _isLoading = false;
  AppException? _error;
  int? _currentProductId;

  // Getters
  List<ProductVariant> get variants => _variants;
  List<VariantAttribute> get attributes => _attributes;
  bool get isLoading => _isLoading;
  AppException? get error => _error;
  bool get hasError => _error != null;
  bool get isEmpty => _variants.isEmpty;
  bool get hasVariants => _variants.isNotEmpty;
  int? get currentProductId => _currentProductId;
  int get totalStock => _variants.fold(0, (sum, v) => sum + v.stock);

  // Private state setters
  void _setLoading(bool value) {
    _isLoading = value;
    if (!_disposed) notifyListeners();
  }

  void _setError(AppException? error) {
    _error = error;
    if (!_disposed) notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Load variants and attributes for a product
  Future<void> loadVariants(int productId) async {
    try {
      AppLogger.ui('Loading variants for product $productId', details: 'ProductVariantController');
      _setLoading(true);
      _clearError();
      _currentProductId = productId;

      final results = await Future.wait([
        getVariantsUseCase.execute(productId),
        getAttributesUseCase.execute(productId),
      ]);

      _variants = results[0] as List<ProductVariant>;
      _attributes = results[1] as List<VariantAttribute>;

      if (!_disposed) notifyListeners();
      AppLogger.info('Variants loaded successfully - ProductVariantController');
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to load variants - ProductVariantController', error: e);
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal memuat varian produk',
        operation: 'loadVariants',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error loading variants - ProductVariantController',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Add a single variant
  Future<bool> addVariant(ProductVariant variant) async {
    try {
      AppLogger.ui('Adding variant', details: 'ProductVariantController');
      _setLoading(true);
      _clearError();

      final created = await addVariantUseCase.execute(variant);
      _variants.add(created);

      if (!_disposed) notifyListeners();
      AppLogger.info('Variant added successfully - ProductVariantController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to add variant - ProductVariantController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal menambahkan varian',
        operation: 'addVariant',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error adding variant - ProductVariantController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Add multiple variants at once
  Future<bool> addVariants(List<ProductVariant> variants) async {
    try {
      AppLogger.ui('Adding ${variants.length} variants', details: 'ProductVariantController');
      _setLoading(true);
      _clearError();

      final created = await addVariantsBatchUseCase.execute(variants);
      _variants.addAll(created);

      if (!_disposed) notifyListeners();
      AppLogger.info('Variants added successfully - ProductVariantController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to add variants - ProductVariantController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal menambahkan varian',
        operation: 'addVariants',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error adding variants - ProductVariantController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing variant
  Future<bool> updateVariant(ProductVariant variant) async {
    try {
      AppLogger.ui('Updating variant ${variant.id}', details: 'ProductVariantController');
      _setLoading(true);
      _clearError();

      await updateVariantUseCase.execute(variant);

      final index = _variants.indexWhere((v) => v.id == variant.id);
      if (index != -1) {
        _variants[index] = variant;
      }

      if (!_disposed) notifyListeners();
      AppLogger.info('Variant updated successfully - ProductVariantController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to update variant - ProductVariantController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal mengupdate varian',
        operation: 'updateVariant',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error updating variant - ProductVariantController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update stock for a variant
  Future<bool> updateVariantStock(int variantId, int stock) async {
    try {
      AppLogger.ui('Updating stock for variant $variantId', details: 'ProductVariantController');
      _clearError();

      await updateVariantStockUseCase.execute(variantId, stock);

      final index = _variants.indexWhere((v) => v.id == variantId);
      if (index != -1) {
        _variants[index] = _variants[index].copyWith(stock: stock);
      }

      if (!_disposed) notifyListeners();
      AppLogger.info('Variant stock updated successfully - ProductVariantController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to update variant stock - ProductVariantController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal mengupdate stok varian',
        operation: 'updateVariantStock',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error updating variant stock - ProductVariantController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Delete a variant
  Future<bool> deleteVariant(int variantId) async {
    try {
      AppLogger.ui('Deleting variant $variantId', details: 'ProductVariantController');
      _setLoading(true);
      _clearError();

      await deleteVariantUseCase.execute(variantId);
      _variants.removeWhere((v) => v.id == variantId);

      if (!_disposed) notifyListeners();
      AppLogger.info('Variant deleted successfully - ProductVariantController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to delete variant - ProductVariantController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal menghapus varian',
        operation: 'deleteVariant',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error deleting variant - ProductVariantController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete all variants for a product
  Future<bool> deleteVariantsByProductId(int productId) async {
    try {
      AppLogger.ui('Deleting variants for product $productId', details: 'ProductVariantController');
      _setLoading(true);
      _clearError();

      await deleteVariantsByProductIdUseCase.execute(productId);
      _variants.clear();

      if (!_disposed) notifyListeners();
      AppLogger.info('Variants deleted successfully - ProductVariantController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to delete variants - ProductVariantController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal menghapus varian',
        operation: 'deleteVariantsByProductId',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error deleting variants - ProductVariantController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Add a single variant attribute
  Future<bool> addAttribute(VariantAttribute attribute) async {
    try {
      AppLogger.ui('Adding attribute', details: 'ProductVariantController');
      _clearError();

      final created = await addAttributeUseCase.execute(attribute);
      _attributes.add(created);

      if (!_disposed) notifyListeners();
      AppLogger.info('Attribute added successfully - ProductVariantController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to add attribute - ProductVariantController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal menambahkan atribut varian',
        operation: 'addAttribute',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error adding attribute - ProductVariantController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Add multiple variant attributes at once
  Future<bool> addAttributes(List<VariantAttribute> attributes) async {
    try {
      AppLogger.ui('Adding ${attributes.length} attributes', details: 'ProductVariantController');
      _clearError();

      final created = await addAttributesBatchUseCase.execute(attributes);
      _attributes.addAll(created);

      if (!_disposed) notifyListeners();
      AppLogger.info('Attributes added successfully - ProductVariantController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to add attributes - ProductVariantController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal menambahkan atribut varian',
        operation: 'addAttributes',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error adding attributes - ProductVariantController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Delete all attributes for a product
  Future<bool> deleteAttributesByProductId(int productId) async {
    try {
      AppLogger.ui('Deleting attributes for product $productId', details: 'ProductVariantController');
      _clearError();

      await deleteAttributesByProductIdUseCase.execute(productId);
      _attributes.clear();

      if (!_disposed) notifyListeners();
      AppLogger.info('Attributes deleted successfully - ProductVariantController');
      return true;
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to delete attributes - ProductVariantController', error: e);
      return false;
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal menghapus atribut varian',
        operation: 'deleteAttributesByProductId',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error deleting attributes - ProductVariantController',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Clear all data
  void clear() {
    _variants.clear();
    _attributes.clear();
    _currentProductId = null;
    _clearError();
    if (!_disposed) notifyListeners();
  }

  /// Generate variant combinations from attributes
  /// Example: Size: [S, M], Color: [Red, Blue] -> 4 variants
  List<Map<String, String>> generateVariantCombinations() {
    if (_attributes.isEmpty) return [];

    List<Map<String, String>> combinations = [{}];

    for (final attr in _attributes) {
      final List<Map<String, String>> newCombinations = [];
      for (final combo in combinations) {
        for (final value in attr.values) {
          newCombinations.add({...combo, attr.name: value});
        }
      }
      combinations = newCombinations;
    }

    return combinations;
  }

  /// Get variant by attribute combination
  ProductVariant? getVariantByAttributes(Map<String, String> attributes) {
    try {
      return _variants.firstWhere((v) {
        if (v.attributes == null) return false;
        final map = v.attributes!;
        // Check if all attributes match
        for (final entry in attributes.entries) {
          if (map[entry.key] != entry.value) return false;
        }
        // Check if same number of attributes
        if (map.length != attributes.length) return false;
        return true;
      });
    } catch (_) {
      return null;
    }
  }
}
