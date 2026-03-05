import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/domain/entities/product_variant.dart';
import '../../../../core/utils/discount_calculator.dart';

/// Cart item entity representing a product in the shopping cart
class CartItem {
  final Product product;
  final ProductVariant? variant;
  int quantity;

  CartItem({
    required this.product,
    this.variant,
    this.quantity = 1,
  });

  /// Creates a copy of this cart item with the given fields replaced
  CartItem copyWith({
    Product? product,
    ProductVariant? variant,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      variant: variant ?? this.variant,
      quantity: quantity ?? this.quantity,
    );
  }

  /// Returns the price to use (variant price if available, otherwise product price)
  double get effectivePrice => variant?.price ?? product.price;

  /// Returns the cost price to use
  double get effectiveCostPrice => variant?.costPrice ?? product.costPrice;

  /// Calculates the total price for this cart item
  double get totalPrice => effectivePrice * quantity;

  /// Calculates the total discount for this cart item
  double get totalDiscount => product.discountAmount * quantity;

  /// Calculates the subtotal before discount
  double get subtotalBeforeDiscount => product.price * quantity;

  /// Checks if this cart item has a discount
  bool get hasDiscount => product.hasDiscount;

  /// Calculates the compound total price after applying all discounts
  double getCompoundTotalPrice({
    double? categoryDiscount,
    double? promotionDiscount,
  }) {
    return product.calculateCompoundPrice(
      categoryDiscount: categoryDiscount,
      promotionDiscount: promotionDiscount,
    ) * quantity;
  }

  /// Gets the compound discount breakdown for this cart item
  DiscountBreakdown getCompoundDiscountBreakdown({
    double? categoryDiscount,
    double? promotionDiscount,
  }) {
    final breakdown = product.getDiscountBreakdown(
      categoryDiscount: categoryDiscount,
      promotionDiscount: promotionDiscount,
    );

    // Multiply all amounts by quantity
    return DiscountBreakdown(
      basePrice: breakdown.basePrice * quantity,
      productDiscountAmount: breakdown.productDiscountAmount * quantity,
      categoryDiscountAmount: breakdown.categoryDiscountAmount * quantity,
      promotionDiscountAmount: breakdown.promotionDiscountAmount * quantity,
      totalDiscount: breakdown.totalDiscount * quantity,
      finalPrice: breakdown.finalPrice * quantity,
    );
  }

  /// Checks if more quantity can be added
  bool get canAddMore {
    final availableStock = variant?.stock ?? product.stock;
    return quantity < availableStock;
  }

  /// Checks if the product is out of stock
  bool get isOutOfStock {
    final availableStock = variant?.stock ?? product.stock;
    return availableStock <= 0;
  }

  /// Gets the display name for the cart item
  String get displayName {
    if (variant != null) {
      return '${product.name} (${variant!.displayName})';
    }
    return product.name;
  }

  /// Calculate subtotal (price * quantity)
  double get subtotal => totalPrice;

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'productId': product.id,
      'productName': product.name,
      'price': product.price,
      'costPrice': product.costPrice,
      'stock': product.stock,
      'quantity': quantity,
      'categoryId': product.categoryId,
      'supplierId': product.supplierId,
      'barcode': product.barcode,
      'imagePath': product.imagePath,
      'discountPercentage': product.discountPercentage,
      'variantId': variant?.id,
      'variantName': variant?.name,
      'variantPrice': variant?.price,
      'variantStock': variant?.stock,
      'variantAttributes': variant?.attributes,
    };
  }

  /// Create CartItem from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Create a Product from the JSON data
    final product = Product(
      id: json['productId'] as int?,
      name: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      costPrice: json['costPrice'] != null
          ? (json['costPrice'] as num).toDouble()
          : 0,
      stock: json['stock'] as int,
      categoryId: json['categoryId'] as int?,
      supplierId: json['supplierId'] as int?,
      barcode: json['barcode'] as String?,
      imagePath: json['imagePath'] as String?,
      discountPercentage: json['discountPercentage'] != null
          ? (json['discountPercentage'] as num).toDouble()
          : null,
    );

    // Create variant if present
    ProductVariant? variant;
    if (json['variantId'] != null) {
      variant = ProductVariant(
        id: json['variantId'] as int?,
        productId: product.id ?? 0,
        name: json['variantName'] as String? ?? '',
        price: (json['variantPrice'] as num?)?.toDouble() ?? product.price,
        costPrice: product.costPrice,
        stock: json['variantStock'] as int? ?? 0,
        attributes: json['variantAttributes'] != null
            ? Map<String, String>.from(json['variantAttributes'] as Map)
            : null,
        createdAt: DateTime.now(),
      );
    }

    return CartItem(
      product: product,
      variant: variant,
      quantity: json['quantity'] as int,
    );
  }

  @override
  String toString() =>
      'CartItem(product: ${product.name}, variant: ${variant?.name}, quantity: $quantity, total: $totalPrice)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CartItem &&
        other.product.id == product.id &&
        other.variant?.id == variant?.id &&
        other.quantity == quantity;
  }

  @override
  int get hashCode => product.id.hashCode ^ (variant?.id.hashCode ?? 0) ^ quantity.hashCode;
}
