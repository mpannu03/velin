import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/widgets/tool_scaffold.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('ToolScaffold', () {
    testWidgets('renders title', (tester) async {
      await pumpApp(
        tester,
        const ToolScaffold(title: 'Merge PDF', child: Text('Tool content')),
      );

      expect(find.text('Merge PDF'), findsOneWidget);
    });

    testWidgets('renders description when supplied', (tester) async {
      await pumpApp(
        tester,
        const ToolScaffold(
          title: 'Merge PDF',
          description: 'Combine multiple PDF files.',
          child: Text('Tool content'),
        ),
      );

      expect(find.text('Combine multiple PDF files.'), findsOneWidget);
    });

    testWidgets('does not render description when omitted', (tester) async {
      await pumpApp(
        tester,
        const ToolScaffold(title: 'Merge PDF', child: Text('Tool content')),
      );

      expect(find.text('Merge PDF'), findsOneWidget);
      expect(find.text('Combine multiple PDF files.'), findsNothing);
    });

    testWidgets('renders child content', (tester) async {
      await pumpApp(
        tester,
        const ToolScaffold(title: 'Merge PDF', child: Text('Tool content')),
      );

      expect(find.text('Tool content'), findsOneWidget);
    });

    testWidgets('calls onBack when back button is tapped', (tester) async {
      var backCalled = false;

      await pumpApp(
        tester,
        ToolScaffold(
          title: 'Merge PDF',
          onBack: () => backCalled = true,
          child: const Text('Tool content'),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(backCalled, isTrue);
    });

    testWidgets('renders back button without callback', (tester) async {
      await pumpApp(
        tester,
        const ToolScaffold(title: 'Merge PDF', child: Text('Tool content')),
      );

      final button = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.arrow_back),
      );

      expect(button.onPressed, isNull);
    });

    testWidgets('renders back button with Back tooltip', (tester) async {
      await pumpApp(
        tester,
        const ToolScaffold(title: 'Merge PDF', child: Text('Tool content')),
      );

      final tooltip = tester.widget<Tooltip>(
        find.ancestor(
          of: find.byIcon(Icons.arrow_back),
          matching: find.byType(Tooltip),
        ),
      );

      expect(tooltip.message, 'Back');
    });

    testWidgets('places child inside scrollable content', (tester) async {
      await pumpApp(
        tester,
        const ToolScaffold(title: 'Merge PDF', child: Text('Tool content')),
      );

      expect(
        find.ancestor(
          of: find.text('Tool content'),
          matching: find.byType(SingleChildScrollView),
        ),
        findsOneWidget,
      );
    });
  });
}
