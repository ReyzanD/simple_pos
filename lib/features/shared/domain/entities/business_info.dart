/// Business information entity
class BusinessInfo {
  final String name;
  final String address;
  final String phone;
  final String email;

  const BusinessInfo({
    required this.name,
    this.address = '',
    this.phone = '',
    this.email = '',
  });

  /// Creates a copy with the given fields replaced
  BusinessInfo copyWith({
    String? name,
    String? address,
    String? phone,
    String? email,
  }) {
    return BusinessInfo(
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }

  /// Validates business information
  bool get isValid => name.isNotEmpty;

  /// Formats phone number for display
  String get formattedPhone {
    if (phone.isEmpty) return '-';
    return phone;
  }

  @override
  String toString() =>
      'BusinessInfo(name: $name, address: $address, phone: $phone, email: $email)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BusinessInfo &&
        other.name == name &&
        other.address == address &&
        other.phone == phone &&
        other.email == email;
  }

  @override
  int get hashCode =>
      name.hashCode ^ address.hashCode ^ phone.hashCode ^ email.hashCode;
}
