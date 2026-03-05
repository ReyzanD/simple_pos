import '../entities/variant_attribute.dart';
import '../repositories/product_variant_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for retrieving all variant attributes for a product
class GetVariantAttributesUseCase {
  final VariantAttributeRepository repository;

  GetVariantAttributesUseCase({required this.repository});

  /// Executes the use case
  /// Returns a list of all attributes for the specified product
  Future<List<VariantAttribute>> execute(int productId) async {
    try {
      AppLogger.useCase('GetVariantAttributes', details: 'Product ID: $productId');

      final attributes = await repository.getAttributes(productId);

      AppLogger.info(
        'Variant attributes retrieved successfully',
        tag: 'GetVariantAttributesUseCase',
      );
      return attributes;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in GetVariantAttributesUseCase',
        error: e,
        stackTrace: stackTrace,
        tag: 'GetVariantAttributesUseCase',
      );
      throw DatabaseException(
        'Gagal mengambil data atribut varian',
        operation: 'GetVariantAttributes',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

/// Use case for adding a variant attribute
class AddVariantAttributeUseCase {
  final VariantAttributeRepository repository;

  AddVariantAttributeUseCase({required this.repository});

  /// Executes the use case
  /// Returns the created attribute with generated ID
  Future<VariantAttribute> execute(VariantAttribute attribute) async {
    try {
      AppLogger.useCase('AddVariantAttribute', details: 'Product: ${attribute.productId}');

      if (attribute.name.isEmpty) {
        throw const ValidationException('Nama atribut tidak boleh kosong', field: 'Nama Atribut');
      }
      if (attribute.values.isEmpty) {
        throw const ValidationException('Atribut harus memiliki minimal satu nilai', field: 'Nilai Atribut');
      }

      final result = await repository.addAttribute(attribute);

      AppLogger.info(
        'Variant attribute added successfully',
        tag: 'AddVariantAttributeUseCase',
      );
      return result;
    } on ValidationException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in AddVariantAttributeUseCase',
        error: e,
        stackTrace: stackTrace,
        tag: 'AddVariantAttributeUseCase',
      );
      throw DatabaseException(
        'Gagal menambahkan atribut varian',
        operation: 'AddVariantAttribute',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

/// Use case for batch adding variant attributes
class AddVariantAttributesBatchUseCase {
  final VariantAttributeRepository repository;

  AddVariantAttributesBatchUseCase({required this.repository});

  /// Executes the use case
  /// Returns the list of created attributes with generated IDs
  Future<List<VariantAttribute>> execute(List<VariantAttribute> attributes) async {
    try {
      AppLogger.useCase('AddVariantAttributesBatch', details: '${attributes.length} attributes');

      if (attributes.isEmpty) {
        throw const ValidationException('Daftar atribut tidak boleh kosong');
      }

      final results = await repository.addAttributes(attributes);

      AppLogger.info(
        'Variant attributes batch added successfully',
        tag: 'AddVariantAttributesBatchUseCase',
      );
      return results;
    } on ValidationException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in AddVariantAttributesBatchUseCase',
        error: e,
        stackTrace: stackTrace,
        tag: 'AddVariantAttributesBatchUseCase',
      );
      throw DatabaseException(
        'Gagal menambahkan atribut varian',
        operation: 'AddVariantAttributesBatch',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

/// Use case for deleting all variant attributes for a product
class DeleteVariantAttributesByProductIdUseCase {
  final VariantAttributeRepository repository;

  DeleteVariantAttributesByProductIdUseCase({required this.repository});

  /// Executes the use case
  Future<void> execute(int productId) async {
    try {
      AppLogger.useCase('DeleteVariantAttributesByProductId', details: 'Product ID: $productId');

      await repository.deleteAttributesByProductId(productId);

      AppLogger.info(
        'Variant attributes deleted successfully',
        tag: 'DeleteVariantAttributesByProductIdUseCase',
      );
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in DeleteVariantAttributesByProductIdUseCase',
        error: e,
        stackTrace: stackTrace,
        tag: 'DeleteVariantAttributesByProductIdUseCase',
      );
      throw DatabaseException(
        'Gagal menghapus atribut varian',
        operation: 'DeleteVariantAttributesByProductId',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
