import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/discount_calculator.dart';

/// Product entity representing a product in the inventory
class Product {
  final int? id;
  final String name;
  final double price;
  final int stock;
  final int? categoryId;
  final int? supplierId;
  final String? barcode;
  final double costPrice;
  final String? imagePath;
  final double? discountPercentage;
  final bool hasVariants;

  const Product({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.categoryId,
    this.supplierId,
    this.barcode,
    this.costPrice = 0,
    this.imagePath,
    this.discountPercentage,
    this.hasVariants = false,
  });

  /// Gets the active product variant (if hasVariants is true)
  Product? get variant {
    if (!hasVariants) return null;
    // TODO: Return active variant when variant system is implemented
    return null;
  }

  /// Checks if the product is out of stock
  bool get isOutOfStock => stock <= AppConstants.outOfStockThreshold;

  /// Checks if the product has low stock
  bool get isLowStock =>
      stock > AppConstants.outOfStockThreshold &&
      stock <= AppConstants.lowStockThreshold;

  /// Calculates profit margin
  double get profitMargin {
    if (costPrice <= 0) return 0;
    return ((price - costPrice) / price) * 100;
  }

  /// Calculates profit amount
  double get profit => price - costPrice;

  /// Checks if the product has a discount
  bool get hasDiscount => discountPercentage != null && discountPercentage! > 0;

  /// Checks if product has any discount available
  bool hasAnyDiscount({double? categoryDiscount, double? promotionDiscount}) {
    return hasDiscount ||
        (categoryDiscount != null && categoryDiscount > 0) ||
        (promotionDiscount != null && promotionDiscount > 0);
  }

  /// Calculates the effective price after discount
  double get effectivePrice {
    if (!hasDiscount) return price;
    return price * (1 - discountPercentage! / 100);
  }

  /// Validates product data
  /// Throws Exception if any field is invalid
  void validate() {
    if (name.trim().length < 3) {
      throw Exception('Nama produk minimal 3 karakter');
    }
    if (price <= 0) {
      throw Exception('Harga produk harus lebih dari 0');
    }
    if (stock < 0) {
      throw Exception('Stok produk tidak boleh negatif');
    }
  }

  /// Gets the discount amount for this product
  double get discountAmount {
    if (!hasDiscount) return 0;
    return price - effectivePrice;
  }

  /// Calculates compound price with category and promotion discounts
  double calculateCompoundPrice({
    double? categoryDiscount,
    double? promotionDiscount,
  }) {
    var finalPrice = price;

    // Apply product discount
    if (hasDiscount) {
      finalPrice = effectivePrice;
    }

    // Apply additional discounts
    if (categoryDiscount != null && categoryDiscount > 0) {
      finalPrice -= categoryDiscount;
    }
    if (promotionDiscount != null && promotionDiscount > 0) {
      finalPrice -= promotionDiscount;
    }

    return finalPrice < 0 ? 0 : finalPrice;
  }

  /// Gets discount breakdown for this product
  DiscountBreakdown getDiscountBreakdown({
    double? categoryDiscount,
    double? promotionDiscount,
  }) {
    final productDiscount = hasDiscount ? discountAmount : 0;
    final totalDiscount =
        productDiscount + (categoryDiscount ?? 0) + (promotionDiscount ?? 0);

    return DiscountBreakdown(
      basePrice: price,
      productDiscountAmount: productDiscount.toDouble(),
      categoryDiscountAmount: (categoryDiscount ?? 0).toDouble(),
      promotionDiscountAmount: (promotionDiscount ?? 0).toDouble(),
      totalDiscount: totalDiscount.toDouble(),
      finalPrice: (price - totalDiscount).toDouble(),
    );
  }

  /// Calculates category discount amount
  double calculateCategoryDiscountAmount(List<dynamic> cart) {
    // Simple implementation - can be enhanced later
    return hasDiscount ? discountAmount : 0;
  }

  /// Calculates promotion discount amount
  double calculatePromotionDiscountAmount(List<dynamic> cart) {
    // Simple implementation - can be enhanced later
    return 0; // No promotion discounts currently
  }

  /// Calculates compound total price
  double calculateCompoundTotalPrice({
    double? categoryDiscount,
    double? promotionDiscount,
  }) {
    return calculateCompoundPrice(
      categoryDiscount: categoryDiscount,
      promotionDiscount: promotionDiscount,
    );
  }

  /// Creates a copy of this product with the given fields replaced
  Product copyWith({
    int? id,
    String? name,
    double? price,
    int? stock,
    int? categoryId,
    int? supplierId,
    String? barcode,
    double? costPrice,
    String? imagePath,
    double? discountPercentage,
    bool? hasVariants,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      supplierId: supplierId ?? this.supplierId,
      barcode: barcode ?? this.barcode,
      costPrice: costPrice ?? this.costPrice,
      imagePath: imagePath ?? this.imagePath,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      hasVariants: hasVariants ?? this.hasVariants,
    );
  }

  /// Converts product to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
    };
  }

  /// Creates a Product from a database map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
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
    );
  }

  @override
  String toString() =>
      'Product(id: $id, name: $name, price: $price, stock: $stock, categoryId: $categoryId, supplierId: $supplierId, barcode: $barcode, costPrice: $costPrice, imagePath: $imagePath, discountPercentage: $discountPercentage, hasVariants: $hasVariants)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product &&
        other.id == id &&
        other.name == name &&
        other.price == price &&
        other.stock == stock &&
        other.categoryId == categoryId &&
        other.supplierId == supplierId &&
        other.barcode == barcode &&
        other.costPrice == costPrice &&
        other.imagePath == imagePath &&
        other.discountPercentage == discountPercentage &&
        other.hasVariants == hasVariants;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      price.hashCode ^
      stock.hashCode ^
      categoryId.hashCode ^
      supplierId.hashCode ^
      barcode.hashCode ^
      costPrice.hashCode ^
      imagePath.hashCode ^
      discountPercentage.hashCode ^
      hasVariants.hashCode;
}
