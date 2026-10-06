import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/sub_features/image_to_pdf/image_to_pdf.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('FitSelector', () {
    testWidgets('renders the fit selector', (tester) async {
      await pumpApp(
        tester,
        FitSelector(fit: ImageToPdfFit.contain, onFitChanged: (_) {}),
      );

      expect(find.byKey(const ValueKey('image-to-pdf-fit')), findsOneWidget);
    });

    testWidgets('passes the selected fit to the segmented button', (
      tester,
    ) async {
      await pumpApp(
        tester,
        FitSelector(fit: ImageToPdfFit.cover, onFitChanged: (_) {}),
      );

      final button = tester.widget<SegmentedButton<ImageToPdfFit>>(
        find.byKey(const ValueKey('image-to-pdf-fit')),
      );

      expect(button.selected, {ImageToPdfFit.cover});
    });

    testWidgets('forwards the selected fit', (tester) async {
      ImageToPdfFit? selectedFit;

      await pumpApp(
        tester,
        FitSelector(
          fit: ImageToPdfFit.contain,
          onFitChanged: (fit) => selectedFit = fit,
        ),
      );

      final button = tester.widget<SegmentedButton<ImageToPdfFit>>(
        find.byKey(const ValueKey('image-to-pdf-fit')),
      );

      button.onSelectionChanged?.call({ImageToPdfFit.stretch});

      expect(selectedFit, ImageToPdfFit.stretch);
    });
  });
}
