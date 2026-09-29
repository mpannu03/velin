import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/reader/widgets/widgets.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('ReaderEmptyState', () {
    testWidgets('shows empty state content', (tester) async {
      await pumpApp(
        tester,
        ReaderEmptyState(
          onOpenDocument: () {},
        ),
      );

      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
      expect(find.text('No document open'), findsOneWidget);
      expect(find.text('Open a file to start reading.'), findsOneWidget);
      expect(find.text('Open document'), findsOneWidget);
      expect(find.byIcon(Icons.folder_open_outlined), findsOneWidget);
    });

    testWidgets('calls onOpenDocument when button is tapped', (tester) async {
      var opened = false;

      await pumpApp(
        tester,
        ReaderEmptyState(
          onOpenDocument: () {
            opened = true;
          },
        ),
      );

      await tester.tap(find.text('Open document'));

      expect(opened, isTrue);
    });
  });
}