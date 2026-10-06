import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/sub_features/image_to_pdf/image_to_pdf.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('PageSizeSelector', () {
    testWidgets('renders the page size selector', (tester) async {
      await pumpApp(
        tester,
        PageSizeSelector(
          pageSize: ImageToPdfPageSize.auto,
          onPageSizeChanged: (_) {},
        ),
      );

      expect(
        find.byKey(const ValueKey('image-to-pdf-page-size')),
        findsOneWidget,
      );
    });

    testWidgets('passes the selected page size to the segmented button', (
      tester,
    ) async {
      await pumpApp(
        tester,
        PageSizeSelector(
          pageSize: ImageToPdfPageSize.a4,
          onPageSizeChanged: (_) {},
        ),
      );

      final button = tester.widget<SegmentedButton<ImageToPdfPageSize>>(
        find.byKey(const ValueKey('image-to-pdf-page-size')),
      );

      expect(button.selected, {ImageToPdfPageSize.a4});
    });

    testWidgets('forwards the selected page size', (tester) async {
      ImageToPdfPageSize? selectedPageSize;

      await pumpApp(
        tester,
        PageSizeSelector(
          pageSize: ImageToPdfPageSize.auto,
          onPageSizeChanged: (pageSize) {
            selectedPageSize = pageSize;
          },
        ),
      );

      final button = tester.widget<SegmentedButton<ImageToPdfPageSize>>(
        find.byKey(const ValueKey('image-to-pdf-page-size')),
      );

      button.onSelectionChanged?.call({ImageToPdfPageSize.letter});

      expect(selectedPageSize, ImageToPdfPageSize.letter);
    });
  });
}
