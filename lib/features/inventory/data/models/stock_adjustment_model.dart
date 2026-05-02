import 'package:simple_pos/features/inventory/domain/entities/stock_adjustment.dart';

class StockAdjustmentModel {
  final int id;
  final int productId;
  final int previousQuantity;
  final int newQuantity;
  final StockAdjustmentType adjustmentType;
  final String? reason;
  final String createdBy;
  final DateTime createdAt;

  StockAdjustmentModel({
    required this.id,
    required this.productId,
    required this.previousQuantity,
    required this.newQuantity,
    required this.adjustmentType,
    this.reason,
    required this.createdBy,
    required this.createdAt,
  });

  factory StockAdjustmentModel.fromJson(Map<String, dynamic> json) {
    return StockAdjustmentModel(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      previousQuantity: json['previous_quantity'] as int,
      newQuantity: json['new_quantity'] as int,
      adjustmentType: _parseAdjustmentType(
        json['adjustment_type'] as String? ?? 'other',
      ),
      reason: json['reason'] as String?,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static StockAdjustmentType _parseAdjustmentType(String type) {
    switch (type) {
      case 'set':
        return StockAdjustmentType.set;
      case 'purchase':
        return StockAdjustmentType.purchase;
      case 'sale':
        return StockAdjustmentType.sale;
      case 'damage':
        return StockAdjustmentType.damage;
      case 'return':
        return StockAdjustmentType.itemReturn;
      case 'manual':
        return StockAdjustmentType.manual;
      case 'other':
      default:
        return StockAdjustmentType.other;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'previous_quantity': previousQuantity,
      'new_quantity': newQuantity,
      'adjustment_type': adjustmentType == StockAdjustmentType.itemReturn
          ? 'return'
          : adjustmentType.name,
      'reason': reason,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  StockAdjustment toEntity() {
    return StockAdjustment(
      id: id,
      productId: productId,
      previousQuantity: previousQuantity,
      newQuantity: newQuantity,
      adjustmentType: adjustmentType,
      reason: reason,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }

  factory StockAdjustmentModel.fromEntity(StockAdjustment entity) {
    return StockAdjustmentModel(
      id: entity.id,
      productId: entity.productId,
      previousQuantity: entity.previousQuantity,
      newQuantity: entity.newQuantity,
      adjustmentType: entity.adjustmentType,
      reason: entity.reason,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
    );
  }
}
