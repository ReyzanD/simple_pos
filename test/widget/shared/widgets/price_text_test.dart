import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/features/shared/widgets/price_text.dart';

void main() {
  group('PriceText widget', () {
    testWidgets('should display price with decimals by default', (tester) async {
      // Arrange
      const price = 15000.50;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceText(price: price),
          ),
        ),
      );

      // Assert
      expect(find.text('Rp 15.000,50'), findsOneWidget);
    });

    testWidgets('should display price without decimals when showDecimals is false', (tester) async {
      // Arrange
      const price = 15000.50;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceText(
              price: price,
              showDecimals: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Rp 15.001'), findsOneWidget);
    });

    testWidgets('should display large price with thousand separators', (tester) async {
      // Arrange
      const price = 15000000.0;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceText(price: price),
          ),
        ),
      );

      // Assert
      expect(find.text('Rp 15.000.000,00'), findsOneWidget);
    });

    testWidgets('should display zero price correctly', (tester) async {
      // Arrange
      const price = 0.0;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceText(price: price),
          ),
        ),
      );

      // Assert
      expect(find.text('Rp 0,00'), findsOneWidget);
    });

    testWidgets('should apply custom style', (tester) async {
      // Arrange
      const price = 15000.0;
      const customStyle = TextStyle(
        fontSize: 24,
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceText(
              price: price,
              style: customStyle,
            ),
          ),
        ),
      );

      // Assert
      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.style?.fontSize, 24);
      expect(textWidget.style?.color, Colors.blue);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('should display prefix when provided', (tester) async {
      // Arrange
      const price = 15000.0;
      const prefix = 'Total';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceText(
              price: price,
              prefix: prefix,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Total Rp 15.000,00'), findsOneWidget);
    });

    testWidgets('should handle negative prices', (tester) async {
      // Arrange
      const price = -100.0;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceText(price: price),
          ),
        ),
      );

      // Assert
      expect(find.text('Rp -100,00'), findsOneWidget);
    });

    testWidgets('should format small amounts correctly', (tester) async {
      // Arrange
      const price = 100.0;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceText(price: price),
          ),
        ),
      );

      // Assert
      expect(find.text('Rp 100,00'), findsOneWidget);
    });

    testWidgets('should combine prefix and showDecimals correctly', (tester) async {
      // Arrange
      const price = 15000.50;
      const prefix = 'Subtotal';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceText(
              price: price,
              prefix: prefix,
              showDecimals: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Subtotal Rp 15.001'), findsOneWidget);
    });
  });
}
