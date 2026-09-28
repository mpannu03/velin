import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/app/navigation/app_navigation.dart';
import 'package:velin/app/navigation/mobile_navigation.dart';

void main() {
  group('MobileNavigation', () {
    testWidgets('renders all navigation items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileNavigation(
              selectedItem: AppNavigationItem.home,
              onItemSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Reader'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Tools'), findsOneWidget);
    });

    testWidgets('calls onItemSelected when an item is tapped', (
      tester,
    ) async {
      AppNavigationItem? selectedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MobileNavigation(
              selectedItem: AppNavigationItem.home,
              onItemSelected: (item) => selectedItem = item,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Reader'));
      await tester.pump();

      expect(selectedItem, AppNavigationItem.reader);
    });
  });
}