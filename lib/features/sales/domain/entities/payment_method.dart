/// Payment methods available in the system
enum PaymentMethod {
  cash('Tunai'),
  card('Kartu'),
  qr('QRIS'),
  transfer('Transfer');

  final String displayName;

  const PaymentMethod(this.displayName);

  /// Converts string to PaymentMethod enum
  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.name.toLowerCase() == value.toLowerCase(),
      orElse: () => PaymentMethod.cash,
    );
  }

  /// Returns the Indonesian display name
  String get displayNameId => displayName;

  @override
  String toString() => name;
}
