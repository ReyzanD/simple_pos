import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/features/shared/widgets/loading_indicator.dart';

void main() {
  group('LoadingIndicator widget', () {
    testWidgets('should display CircularProgressIndicator', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('should display message when provided', (tester) async {
      // Arrange
      const message = 'Loading data...';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(message: message),
          ),
        ),
      );

      // Assert
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('should not display message when not provided', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(),
          ),
        ),
      );

      // Assert
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('should apply custom size', (tester) async {
      // Arrange
      const customSize = 60.0;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(size: customSize),
          ),
        ),
      );

      // Assert
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(Center),
          matching: find.byType(SizedBox).first,
        ),
      );
      expect(sizedBox.width, customSize);
      expect(sizedBox.height, customSize);
    });

    testWidgets('should center content', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(),
          ),
        ),
      );

      // Assert
      expect(find.byType(Center), findsOneWidget);
      final column = tester.widget<Column>(
        find.descendant(
          of: find.byType(Center),
          matching: find.byType(Column),
        ),
      );
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('should display message with proper spacing', (tester) async {
      // Arrange
      const message = 'Please wait...';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(message: message),
          ),
        ),
      );

      // Assert
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.text(message), findsOneWidget);

      final textWidget = tester.widget<Text>(find.text(message));
      expect(textWidget.style?.color, Colors.grey);
    });
  });

  group('SmallLoadingIndicator widget', () {
    testWidgets('should display small CircularProgressIndicator', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmallLoadingIndicator(),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('should have correct size', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmallLoadingIndicator(),
          ),
        ),
      );

      // Assert
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, 20.0);
      expect(sizedBox.height, 20.0);
    });

    testWidgets('should have thin stroke width', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmallLoadingIndicator(),
          ),
        ),
      );

      // Assert
      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(progressIndicator.strokeWidth, 2);
    });
  });
}
