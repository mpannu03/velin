import 'package:flutter_test/flutter_test.dart';

import 'package:velin/app/navigation/app_navigation.dart';
import 'package:velin/app/navigation/desktop_navigation.dart';

import '../../helpers/helpers.dart';

void main() {
  group('DesktopNavigation', () {
    testWidgets('renders all navigation items', (tester) async {
      await pumpApp(tester, 
        DesktopNavigation(
        selectedItem: AppNavigationItem.home,
        onItemSelected: (_) {},
      ));

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Reader'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Tools'), findsOneWidget);
    });

    testWidgets('calls onItemSelected when an item is tapped', (
      tester,
    ) async {
      AppNavigationItem? selectedItem;

      await pumpApp(tester, 
        DesktopNavigation(
        selectedItem: AppNavigationItem.home,
        onItemSelected: (item) => selectedItem = item,
      ));

      await tester.tap(find.text('Reader'));
      await tester.pump();

      expect(selectedItem, AppNavigationItem.reader);
    });
  });
}