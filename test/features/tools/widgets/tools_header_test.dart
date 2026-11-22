import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('ToolsHeader', () {
    testWidgets('renders tools title and introduction', (tester) async {
      await pumpApp(tester, ToolsHeader(onQueryChanged: (_) {}));

      final l10n = tester.element(find.byType(ToolsHeader)).l10n;
      expect(find.text(l10n.navigationTools), findsOneWidget);
      expect(find.text(l10n.toolsIntro), findsOneWidget);
    });

    testWidgets('forwards what is typed in the search box', (tester) async {
      String? query;

      await pumpApp(tester, ToolsHeader(onQueryChanged: (q) => query = q));
      await tester.enterText(find.byType(TextField), 'merge');

      expect(query, 'merge');
    });
  });
}
