import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/sub_features/sub_features.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('VColorSwatch', () {
    testWidgets('renders the color tooltip', (tester) async {
      await pumpApp(
        tester,
        const VColorSwatch(hex: '#FF0000', isSelected: false, onTap: _noop),
      );

      expect(find.byType(Tooltip), findsOneWidget);

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));

      expect(tooltip.message, '#FF0000');
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await pumpApp(
        tester,
        VColorSwatch(
          hex: '#FF0000',
          isSelected: false,
          onTap: () => tapped = true,
        ),
      );

      await tester.tap(find.byType(VColorSwatch));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows check icon when selected', (tester) async {
      await pumpApp(
        tester,
        const VColorSwatch(hex: '#FF0000', isSelected: true, onTap: _noop),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('does not show check icon when not selected', (tester) async {
      await pumpApp(
        tester,
        const VColorSwatch(hex: '#FF0000', isSelected: false, onTap: _noop),
      );

      expect(find.byIcon(Icons.check), findsNothing);
    });
  });
}

void _noop() {}
