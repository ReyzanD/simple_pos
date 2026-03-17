// test/core/widgets/quick_actions_menu_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pos/core/widgets/quick_actions_menu.dart';

void main() {
  group('QuickActionsMenu widget', () {
    testWidgets('QuickActionsMenu shows all actions on long press', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionsMenu(
              onFavorites: () {},
              onHeldOrders: () {},
              onQuickAdd: () {},
              onQuickQuantity: () {},
              onTodaySummary: () {},
              onRefresh: () {},
            ),
          ),
        ),
      );

      // Initially shows just the FAB
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Long press to expand
      await tester.longPress(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Now shows action buttons (find by semantics label)
      expect(find.bySemanticsLabel('Favorites'), findsOneWidget);
      expect(find.bySemanticsLabel('Held Orders'), findsOneWidget);
      expect(find.bySemanticsLabel('Quick Add'), findsOneWidget);
      expect(find.bySemanticsLabel('Quick Quantity'), findsOneWidget);
      expect(find.bySemanticsLabel("Today's Summary"), findsOneWidget);
      expect(find.bySemanticsLabel('Refresh'), findsOneWidget);
    });

    testWidgets('QuickActionsMenu collapses on tap when expanded', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionsMenu(
              onFavorites: () {},
              onHeldOrders: () {},
              onQuickAdd: () {},
              onQuickQuantity: () {},
              onTodaySummary: () {},
              onRefresh: () {},
            ),
          ),
        ),
      );

      // Long press to expand
      await tester.longPress(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify actions are visible
      expect(find.bySemanticsLabel('Favorites'), findsOneWidget);

      // Tap to collapse
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Actions should be hidden
      expect(find.bySemanticsLabel('Favorites'), findsNothing);
    });

    testWidgets('QuickActionsMenu calls appropriate callbacks', (tester) async {
      bool favoritesTapped = false;
      bool heldOrdersTapped = false;
      bool quickAddTapped = false;
      bool quickQuantityTapped = false;
      bool todaySummaryTapped = false;
      bool refreshTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionsMenu(
              onFavorites: () => favoritesTapped = true,
              onHeldOrders: () => heldOrdersTapped = true,
              onQuickAdd: () => quickAddTapped = true,
              onQuickQuantity: () => quickQuantityTapped = true,
              onTodaySummary: () => todaySummaryTapped = true,
              onRefresh: () => refreshTapped = true,
            ),
          ),
        ),
      );

      // Expand menu
      await tester.longPress(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Tap Favorites - use Icon finder
      await tester.tap(find.byIcon(Icons.star));
      await tester.pumpAndSettle();
      expect(favoritesTapped, true);

      // Expand again
      await tester.longPress(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Tap Held Orders - use Icon finder
      await tester.tap(find.byIcon(Icons.receipt_long));
      await tester.pumpAndSettle();
      expect(heldOrdersTapped, true);

      // Expand again
      await tester.longPress(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Tap Quick Add - use Icon finder
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pumpAndSettle();
      expect(quickAddTapped, true);

      // Expand again
      await tester.longPress(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Tap Quick Quantity - use Icon finder
      await tester.tap(find.byIcon(Icons.pin));
      await tester.pumpAndSettle();
      expect(quickQuantityTapped, true);

      // Expand again
      await tester.longPress(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Tap Today's Summary - use Icon finder
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();
      expect(todaySummaryTapped, true);

      // Expand again
      await tester.longPress(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Tap Refresh - use Icon finder
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      expect(refreshTapped, true);
    });

    testWidgets('QuickActionsMenu shows correct icons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionsMenu(
              onFavorites: () {},
              onHeldOrders: () {},
              onQuickAdd: () {},
              onQuickQuantity: () {},
              onTodaySummary: () {},
              onRefresh: () {},
            ),
          ),
        ),
      );

      // Long press to expand
      await tester.longPress(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
      expect(find.byIcon(Icons.add_circle), findsOneWidget);
      expect(find.byIcon(Icons.pin), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('QuickActionsMenu does nothing on tap when collapsed', (tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionsMenu(
              onFavorites: () => callbackCalled = true,
              onHeldOrders: () {},
              onQuickAdd: () {},
              onQuickQuantity: () {},
              onTodaySummary: () {},
              onRefresh: () {},
            ),
          ),
        ),
      );

      // Tap without long press (collapsed state)
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Callback should not be called
      expect(callbackCalled, false);
    });
  });
}
