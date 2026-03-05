import '../entities/product_variant.dart';
import '../entities/variant_attribute.dart';
import '../../../../core/exceptions/app_exceptions.dart';

/// Interface for product variant repository operations
abstract class ProductVariantRepository {
  /// Retrieves all variants for a specific product
  /// Throws [DatabaseException] if retrieval fails
  Future<List<ProductVariant>> getVariants(int productId);

  /// Retrieves a single variant by ID
  /// Throws [NotFoundException] if variant doesn't exist
  /// Throws [DatabaseException] if retrieval fails
  Future<ProductVariant> getVariantById(int variantId);

  /// Retrieves a variant by SKU
  /// Throws [NotFoundException] if variant doesn't exist
  /// Throws [DatabaseException] if retrieval fails
  Future<ProductVariant?> getVariantBySku(String sku);

  /// Retrieves a variant by barcode
  /// Throws [NotFoundException] if variant doesn't exist
  /// Throws [DatabaseException] if retrieval fails
  Future<ProductVariant?> getVariantByBarcode(String barcode);

  /// Adds a new variant to the data source
  /// Throws [ValidationException] if validation fails
  /// Throws [DatabaseException] if insertion fails
  Future<ProductVariant> addVariant(ProductVariant variant);

  /// Updates an existing variant in the data source
  /// Throws [NotFoundException] if variant doesn't exist
  /// Throws [ValidationException] if validation fails
  /// Throws [DatabaseException] if update fails
  Future<void> updateVariant(ProductVariant variant);

  /// Deletes a variant from the data source
  /// Throws [NotFoundException] if variant doesn't exist
  /// Throws [DatabaseException] if deletion fails
  Future<void> deleteVariant(int variantId);

  /// Deletes all variants for a specific product
  /// Throws [DatabaseException] if deletion fails
  Future<void> deleteVariantsByProductId(int productId);

  /// Updates stock for a variant
  /// Throws [NotFoundException] if variant doesn't exist
  /// Throws [DatabaseException] if update fails
  Future<void> updateVariantStock(int variantId, int stock);

  /// Batch inserts multiple variants
  /// Throws [DatabaseException] if insertion fails
  Future<List<ProductVariant>> addVariants(List<ProductVariant> variants);
}

/// Interface for variant attribute repository operations
abstract class VariantAttributeRepository {
  /// Retrieves all attributes for a specific product
  /// Throws [DatabaseException] if retrieval fails
  Future<List<VariantAttribute>> getAttributes(int productId);

  /// Adds a new attribute to the data source
  /// Throws [ValidationException] if validation fails
  /// Throws [DatabaseException] if insertion fails
  Future<VariantAttribute> addAttribute(VariantAttribute attribute);

  /// Updates an existing attribute in the data source
  /// Throws [NotFoundException] if attribute doesn't exist
  /// Throws [ValidationException] if validation fails
  /// Throws [DatabaseException] if update fails
  Future<void> updateAttribute(VariantAttribute attribute);

  /// Deletes an attribute from the data source
  /// Throws [NotFoundException] if attribute doesn't exist
  /// Throws [DatabaseException] if deletion fails
  Future<void> deleteAttribute(int attributeId);

  /// Deletes all attributes for a specific product
  /// Throws [DatabaseException] if deletion fails
  Future<void> deleteAttributesByProductId(int productId);

  /// Batch inserts multiple attributes
  /// Throws [DatabaseException] if insertion fails
  Future<List<VariantAttribute>> addAttributes(List<VariantAttribute> attributes);
}
