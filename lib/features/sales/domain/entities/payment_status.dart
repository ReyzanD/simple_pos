/// Payment status for transactions
enum PaymentStatus {
  pending('Pending'),
  completed('Selesai'),
  cancelled('Dibatalkan'),
  refunded('Dikembalikan');

  final String displayName;

  const PaymentStatus(this.displayName);

  /// Converts string to PaymentStatus enum
  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.name.toLowerCase() == value.toLowerCase(),
      orElse: () => PaymentStatus.pending,
    );
  }

  /// Returns the Indonesian display name
  String get displayNameId => displayName;

  @override
  String toString() => name;
}
