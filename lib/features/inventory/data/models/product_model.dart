import '../../domain/entities/product.dart';

/// Product model for data layer - extends domain entity
/// This is a simple wrapper that provides additional data layer functionality
class ProductModel extends Product {
  const ProductModel({
    super.id,
    required super.name,
    required super.price,
    required super.stock,
    super.categoryId,
    super.supplierId,
    super.barcode,
    super.costPrice,
    super.imagePath,
    super.discountPercentage,
    super.hasVariants,
    super.unitOfMeasurement = 'pcs',
  });

  /// Creates ProductModel from domain Product
  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      price: product.price,
      stock: product.stock,
      categoryId: product.categoryId,
      supplierId: product.supplierId,
      barcode: product.barcode,
      costPrice: product.costPrice,
      imagePath: product.imagePath,
      discountPercentage: product.discountPercentage,
      hasVariants: product.hasVariants,
      unitOfMeasurement: product.unitOfMeasurement,
    );
  }

  /// Converts to domain Product
  Product toEntity() {
    return Product(
      id: id,
      name: name,
      price: price,
      stock: stock,
      categoryId: categoryId,
      supplierId: supplierId,
      barcode: barcode,
      costPrice: costPrice,
      imagePath: imagePath,
      discountPercentage: discountPercentage,
      hasVariants: hasVariants,
      unitOfMeasurement: unitOfMeasurement,
    );
  }

  /// Creates ProductModel from database map
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      stock: map['stock'] as int,
      categoryId: map['category_id'] as int?,
      supplierId: map['supplier_id'] as int?,
      barcode: map['barcode'] as String?,
      costPrice: (map['cost_price'] as num?)?.toDouble() ?? 0,
      imagePath: map['image_path'] as String?,
      discountPercentage: (map['discount_percentage'] as num?)?.toDouble(),
      hasVariants: (map['has_variants'] as int? ?? 0) == 1,
      unitOfMeasurement: map['unit_of_measurement'] as String? ?? 'pcs',
    );
  }

  /// Converts to map for database storage
  @override
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
      'supplier_id': supplierId,
      'barcode': barcode,
      'cost_price': costPrice,
      'image_path': imagePath,
      'discount_percentage': discountPercentage,
      'has_variants': hasVariants ? 1 : 0,
      'unit_of_measurement': unitOfMeasurement,
    };
  }
}
