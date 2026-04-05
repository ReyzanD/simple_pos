/// Indonesian Rupiah bill denominations for cash counting
enum CashDenomination {
  rupiah100000(100000),
  rupiah50000(50000),
  rupiah20000(20000),
  rupiah10000(10000),
  rupiah5000(5000),
  rupiah2000(2000),
  rupiah1000(1000),
  rupiah500(500),
  rupiah200(200),
  rupiah100(100);

  final int value;
  const CashDenomination(this.value);

  /// Display string formatted as Indonesian currency
  String get display {
    switch (this) {
      case rupiah100000: return '100.000';
      case rupiah50000: return '50.000';
      case rupiah20000: return '20.000';
      case rupiah10000: return '10.000';
      case rupiah5000: return '5.000';
      case rupiah2000: return '2.000';
      case rupiah1000: return '1.000';
      case rupiah500: return '500';
      case rupiah200: return '200';
      case rupiah100: return '100';
    }
  }

  /// Get all denominations in descending order
  static List<CashDenomination> get all => [
    rupiah100000,
    rupiah50000,
    rupiah20000,
    rupiah10000,
    rupiah5000,
    rupiah2000,
    rupiah1000,
    rupiah500,
    rupiah200,
    rupiah100,
  ];
}
