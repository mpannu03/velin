import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/sub_features/image_to_pdf/image_to_pdf.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('OrientationSelector', () {
    testWidgets('renders the orientation selector', (tester) async {
      await pumpApp(
        tester,
        OrientationSelector(
          orientation: ImageToPdfOrientation.auto,
          onOrientationChanged: (_) {},
        ),
      );

      expect(
        find.byKey(const ValueKey('image-to-pdf-orientation')),
        findsOneWidget,
      );
    });

    testWidgets('passes the selected orientation to the segmented button', (
      tester,
    ) async {
      await pumpApp(
        tester,
        OrientationSelector(
          orientation: ImageToPdfOrientation.landscape,
          onOrientationChanged: (_) {},
        ),
      );

      final button = tester.widget<SegmentedButton<ImageToPdfOrientation>>(
        find.byKey(const ValueKey('image-to-pdf-orientation')),
      );

      expect(button.selected, {ImageToPdfOrientation.landscape});
    });

    testWidgets('forwards the selected orientation', (tester) async {
      ImageToPdfOrientation? selectedOrientation;

      await pumpApp(
        tester,
        OrientationSelector(
          orientation: ImageToPdfOrientation.auto,
          onOrientationChanged: (orientation) {
            selectedOrientation = orientation;
          },
        ),
      );

      final button = tester.widget<SegmentedButton<ImageToPdfOrientation>>(
        find.byKey(const ValueKey('image-to-pdf-orientation')),
      );

      button.onSelectionChanged?.call({ImageToPdfOrientation.portrait});

      expect(selectedOrientation, ImageToPdfOrientation.portrait);
    });
  });
}
