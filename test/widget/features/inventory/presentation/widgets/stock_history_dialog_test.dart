import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/features/inventory/presentation/widgets/stock_history_dialog.dart';

void main() {
  testWidgets('StockHistoryDialog should display title and product name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: StockHistoryDialog(
            productId: 1,
            productName: 'Test Product',
          ),
        ),
      ),
    );

    expect(find.text('Stock History'), findsOneWidget);
    expect(find.text('Test Product'), findsOneWidget);
  });
}
