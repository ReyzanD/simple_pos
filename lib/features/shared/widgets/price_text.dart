import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Reusable widget for displaying price text with consistent formatting
class PriceText extends StatelessWidget {
  final double price;
  final TextStyle? style;
  final bool showDecimals;
  final String? prefix;

  const PriceText({
    super.key,
    required this.price,
    this.style,
    this.showDecimals = true,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedPrice = showDecimals
        ? CurrencyFormatter.format(price)
        : CurrencyFormatter.formatWithoutDecimals(price);

    final String displayText = prefix != null ? '$prefix $formattedPrice' : formattedPrice;

    return Text(
      displayText,
      style: style,
    );
  }
}
