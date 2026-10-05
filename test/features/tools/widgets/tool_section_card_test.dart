import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/widgets/tool_section_card.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('ToolSectionCard', () {
    testWidgets('renders title', (tester) async {
      await pumpApp(
        tester,
        const ToolSectionCard(title: 'Input Files', child: Text('File picker')),
      );

      expect(find.text('Input Files'), findsOneWidget);
    });

    testWidgets('renders child', (tester) async {
      await pumpApp(
        tester,
        const ToolSectionCard(title: 'Input Files', child: Text('File picker')),
      );

      expect(find.text('File picker'), findsOneWidget);
    });

    testWidgets('renders title and child together', (tester) async {
      await pumpApp(
        tester,
        const ToolSectionCard(
          title: 'Output',
          child: SizedBox(key: ValueKey('output-widget')),
        ),
      );

      expect(find.text('Output'), findsOneWidget);
      expect(find.byKey(const ValueKey('output-widget')), findsOneWidget);
    });
  });
}
