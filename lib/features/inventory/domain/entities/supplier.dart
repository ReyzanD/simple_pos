import '../../../../core/exceptions/app_exceptions.dart';

/// Supplier entity for product suppliers
class Supplier {
  final int? id;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final DateTime createdAt;

  const Supplier({
    this.id,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    required this.createdAt,
  });

  /// Creates a copy of this supplier with the given fields replaced
  Supplier copyWith({
    int? id,
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    DateTime? createdAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Validates the supplier data
  /// Throws [ValidationException] if validation fails
  void validate() {
    if (name.trim().isEmpty) {
      throw const ValidationException('Nama pemasok tidak boleh kosong', field: 'Nama Pemasok');
    }

    if (name.length < 2) {
      throw const ValidationException('Nama pemasok minimal 2 karakter', field: 'Nama Pemasok');
    }

    if (name.length > 100) {
      throw const ValidationException('Nama pemasok maksimal 100 karakter', field: 'Nama Pemasok');
    }

    if (email != null && email!.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email!)) {
        throw const ValidationException('Format email tidak valid', field: 'Email');
      }
    }

    if (phone != null && phone!.isNotEmpty) {
      final phoneRegex = RegExp(r'^[0-9+\-\s()]+$');
      if (!phoneRegex.hasMatch(phone!)) {
        throw const ValidationException('Format telepon tidak valid', field: 'Telepon');
      }
    }
  }

  /// Converts supplier to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a Supplier from a database map
  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'] as int?,
      name: map['name'] as String,
      contactPerson: map['contact_person'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  String toString() =>
      'Supplier(id: $id, name: $name, contactPerson: $contactPerson, phone: $phone, email: $email)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Supplier &&
        other.id == id &&
        other.name == name &&
        other.contactPerson == contactPerson &&
        other.phone == phone &&
        other.email == email &&
        other.address == address;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      contactPerson.hashCode ^
      phone.hashCode ^
      email.hashCode ^
      address.hashCode;
}
