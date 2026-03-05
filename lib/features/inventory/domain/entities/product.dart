import '../../../../core/utils/validators.dart';
import '../../../../core/utils/discount_calculator.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/app_exceptions.dart';

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

  /// Checks if the product is out of stock
  bool get isOutOfStock => stock <= AppConstants.outOfStockThreshold;

  /// Checks if the product has low stock
  bool get isLowStock =>
      stock > AppConstants.outOfStockThreshold &&
      stock <= AppConstants.lowStockThreshold;

  /// Calculates profit margin
  double get profitMargin {
    if (costPrice <= 0) return 0;
    return ((price - costPrice) / price * 100);
  }

  /// Calculates profit amount
  double get profit => price - costPrice;

  /// Checks if the product has a discount
  bool get hasDiscount => discountPercentage != null && discountPercentage! > 0;

  /// Calculates the effective price after discount
  double get effectivePrice {
    if (!hasDiscount) return price;
    return price * (1 - discountPercentage! / 100);
  }

  /// Calculates the discount amount per unit
  double get discountAmount {
    if (!hasDiscount) return 0;
    return price - effectivePrice;
  }

  /// Calculates the compound final price after applying all discounts
  /// [categoryDiscount] - Optional category-level discount percentage
  /// [promotionDiscount] - Optional promotion-level discount percentage
  /// Returns the final price after sequential application of all discounts
  double calculateCompoundPrice({
    double? categoryDiscount,
    double? promotionDiscount,
  }) {
    return DiscountCalculator.calculateFinalPrice(
      basePrice: price,
      productDiscount: discountPercentage,
      categoryDiscount: categoryDiscount,
      promotionDiscount: promotionDiscount,
    );
  }

  /// Gets the compound discount breakdown
  /// [categoryDiscount] - Optional category-level discount percentage
  /// [promotionDiscount] - Optional promotion-level discount percentage
  DiscountBreakdown getDiscountBreakdown({
    double? categoryDiscount,
    double? promotionDiscount,
  }) {
    return DiscountCalculator.getDiscountBreakdown(
      basePrice: price,
      productDiscount: discountPercentage,
      categoryDiscount: categoryDiscount,
      promotionDiscount: promotionDiscount,
    );
  }

  /// Checks if the product has any discount (including category and promotion)
  bool hasAnyDiscount({
    double? categoryDiscount,
    double? promotionDiscount,
  }) {
    return DiscountCalculator.hasAnyDiscount(
      productDiscount: discountPercentage,
      categoryDiscount: categoryDiscount,
      promotionDiscount: promotionDiscount,
    );
  }

  /// Validates the product data
  /// Throws [ValidationException] if validation fails
  void validate() {
    Validators.validateProductName(name);
    Validators.validatePrice(price);
    Validators.validateStock(stock);

    if (costPrice < 0) {
      throw const ValidationException('Harga modal tidak boleh negatif', field: 'Harga Modal');
    }

    if (discountPercentage != null && (discountPercentage! < 0 || discountPercentage! > 100)) {
      throw const ValidationException('Diskon harus antara 0-100', field: 'Diskon');
    }
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
