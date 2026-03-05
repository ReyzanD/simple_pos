/// Discount calculation utility for compound discounts
/// Handles sequential application of product, category, and promotion discounts
class DiscountCalculator {
  /// Calculates the final price after applying all discounts sequentially
  ///
  /// [basePrice] - Original price of the product
  /// [productDiscount] - Optional product-level discount percentage (0-100)
  /// [categoryDiscount] - Optional category-level discount percentage (0-100)
  /// [promotionDiscount] - Optional promotion-level discount percentage (0-100)
  ///
  /// Returns the final price after all discounts are applied sequentially
  static double calculateFinalPrice({
    required double basePrice,
    double? productDiscount,
    double? categoryDiscount,
    double? promotionDiscount,
  }) {
    double price = basePrice;

    // Apply product discount first
    if (productDiscount != null && productDiscount > 0) {
      price = price * (1 - productDiscount / 100);
    }

    // Apply category discount second (on reduced price)
    if (categoryDiscount != null && categoryDiscount > 0) {
      price = price * (1 - categoryDiscount / 100);
    }

    // Apply promotion discount last (on further reduced price)
    if (promotionDiscount != null && promotionDiscount > 0) {
      price = price * (1 - promotionDiscount / 100);
    }

    return price;
  }

  /// Calculates the total discount amount from original price
  ///
  /// Returns the total savings after all discounts are applied
  static double calculateTotalDiscount({
    required double basePrice,
    double? productDiscount,
    double? categoryDiscount,
    double? promotionDiscount,
  }) {
    final finalPrice = calculateFinalPrice(
      basePrice: basePrice,
      productDiscount: productDiscount,
      categoryDiscount: categoryDiscount,
      promotionDiscount: promotionDiscount,
    );

    return basePrice - finalPrice;
  }

  /// Gets a breakdown of discounts applied at each level
  ///
  /// Returns a map containing the discount amount at each level
  static DiscountBreakdown getDiscountBreakdown({
    required double basePrice,
    double? productDiscount,
    double? categoryDiscount,
    double? promotionDiscount,
  }) {
    double priceAfterProduct = basePrice;
    double productDiscountAmount = 0;

    if (productDiscount != null && productDiscount > 0) {
      final discountedPrice = basePrice * (1 - productDiscount / 100);
      productDiscountAmount = basePrice - discountedPrice;
      priceAfterProduct = discountedPrice;
    }

    double priceAfterCategory = priceAfterProduct;
    double categoryDiscountAmount = 0;

    if (categoryDiscount != null && categoryDiscount > 0) {
      final discountedPrice = priceAfterProduct * (1 - categoryDiscount / 100);
      categoryDiscountAmount = priceAfterProduct - discountedPrice;
      priceAfterCategory = discountedPrice;
    }

    double promotionDiscountAmount = 0;

    if (promotionDiscount != null && promotionDiscount > 0) {
      final discountedPrice = priceAfterCategory * (1 - promotionDiscount / 100);
      promotionDiscountAmount = priceAfterCategory - discountedPrice;
    }

    return DiscountBreakdown(
      basePrice: basePrice,
      productDiscountAmount: productDiscountAmount,
      categoryDiscountAmount: categoryDiscountAmount,
      promotionDiscountAmount: promotionDiscountAmount,
      totalDiscount: productDiscountAmount +
          categoryDiscountAmount +
          promotionDiscountAmount,
      finalPrice: basePrice -
          (productDiscountAmount + categoryDiscountAmount + promotionDiscountAmount),
    );
  }

  /// Checks if any discount is available
  static bool hasAnyDiscount({
    double? productDiscount,
    double? categoryDiscount,
    double? promotionDiscount,
  }) {
    return (productDiscount != null && productDiscount > 0) ||
        (categoryDiscount != null && categoryDiscount > 0) ||
        (promotionDiscount != null && promotionDiscount > 0);
  }

  /// Calculates the effective discount percentage from original price
  ///
  /// Returns the effective single discount percentage equivalent
  static double calculateEffectiveDiscountPercentage({
    required double basePrice,
    double? productDiscount,
    double? categoryDiscount,
    double? promotionDiscount,
  }) {
    final totalDiscount = calculateTotalDiscount(
      basePrice: basePrice,
      productDiscount: productDiscount,
      categoryDiscount: categoryDiscount,
      promotionDiscount: promotionDiscount,
    );

    return (totalDiscount / basePrice) * 100;
  }
}

/// Data class representing a breakdown of discounts applied
class DiscountBreakdown {
  final double basePrice;
  final double productDiscountAmount;
  final double categoryDiscountAmount;
  final double promotionDiscountAmount;
  final double totalDiscount;
  final double finalPrice;

  const DiscountBreakdown({
    required this.basePrice,
    required this.productDiscountAmount,
    required this.categoryDiscountAmount,
    required this.promotionDiscountAmount,
    required this.totalDiscount,
    required this.finalPrice,
  });

  /// Gets the percentage of total discount relative to base price
  double get totalDiscountPercentage => (totalDiscount / basePrice) * 100;

  @override
  String toString() =>
      'DiscountBreakdown(basePrice: $basePrice, productDiscount: $productDiscountAmount, '
      'categoryDiscount: $categoryDiscountAmount, promotionDiscount: $promotionDiscountAmount, '
      'totalDiscount: $totalDiscount, finalPrice: $finalPrice)';
}
