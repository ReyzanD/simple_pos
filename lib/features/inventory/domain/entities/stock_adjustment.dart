enum StockAdjustmentType {
  set,
  purchase,
  sale,
  damage,
  itemReturn,
  manual,
  other,
}

class StockAdjustment {
  final int id;
  final int productId;
  final int previousQuantity;
  final int newQuantity;
  final StockAdjustmentType adjustmentType;
  final String? reason;
  final String createdBy;
  final DateTime createdAt;

  const StockAdjustment({
    required this.id,
    required this.productId,
    required this.previousQuantity,
    required this.newQuantity,
    required this.adjustmentType,
    this.reason,
    required this.createdBy,
    required this.createdAt,
  });

  int get adjustmentAmount => newQuantity - previousQuantity;

  bool get isIncrease => adjustmentAmount > 0;
  bool get isDecrease => adjustmentAmount < 0;
}
