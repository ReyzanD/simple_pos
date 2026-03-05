import '../../domain/entities/supplier.dart';

/// Supplier model for data layer
class SupplierModel extends Supplier {
  const SupplierModel({
    super.id,
    required super.name,
    super.contactPerson,
    super.phone,
    super.email,
    super.address,
    required super.createdAt,
  });

  /// Creates SupplierModel from domain Supplier
  factory SupplierModel.fromEntity(Supplier supplier) {
    return SupplierModel(
      id: supplier.id,
      name: supplier.name,
      contactPerson: supplier.contactPerson,
      phone: supplier.phone,
      email: supplier.email,
      address: supplier.address,
      createdAt: supplier.createdAt,
    );
  }

  /// Converts to domain Supplier
  Supplier toEntity() {
    return Supplier(
      id: id,
      name: name,
      contactPerson: contactPerson,
      phone: phone,
      email: email,
      address: address,
      createdAt: createdAt,
    );
  }

  /// Creates SupplierModel from database map
  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      contactPerson: map['contact_person'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Converts to map for database storage
  @override
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
