import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/document_workspace/document_workspace.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('PanelShell', () {
    testWidgets('renders title and child', (tester) async {
      await pumpApp(
        tester,
        PanelShell(title: 'Bookmarks', child: const Text('Panel content')),
      );

      expect(find.text('Bookmarks'), findsOneWidget);
      expect(find.text('Panel content'), findsOneWidget);
    });

    testWidgets('renders trailing widget when provided', (tester) async {
      await pumpApp(
        tester,
        PanelShell(
          title: 'Bookmarks',
          trailing: const Icon(Icons.close),
          child: const SizedBox(),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('does not render trailing widget when not provided', (
      tester,
    ) async {
      await pumpApp(
        tester,
        PanelShell(title: 'Bookmarks', child: const SizedBox()),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });
  });
}
