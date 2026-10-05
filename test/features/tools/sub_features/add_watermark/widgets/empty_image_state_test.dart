import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/sub_features/sub_features.dart';
import 'package:velin/shared/extensions/extensions.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('ImageEmptyState', () {
    testWidgets('renders the empty state content', (tester) async {
      await pumpApp(tester, ImageEmptyState(onPickImage: () {}));

      final context = tester.element(find.byType(ImageEmptyState));

      expect(
        find.text(context.l10n.toolsWatermarkImageDescription),
        findsOneWidget,
      );
      expect(find.text(context.l10n.toolsWatermarkImageChoose), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('calls onPickImage when choose image is tapped', (
      tester,
    ) async {
      var picked = false;

      await pumpApp(tester, ImageEmptyState(onPickImage: () => picked = true));

      await tester.tap(find.byKey(const ValueKey('add-watermark-pick-image')));
      await tester.pump();

      expect(picked, isTrue);
    });
  });
}
