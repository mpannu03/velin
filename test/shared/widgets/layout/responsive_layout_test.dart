import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/shared/widgets/widgets.dart';

import '../../../helpers/helpers.dart';

void main() {
  testWidgets('shows desktop layout on desktop platform', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    await pumpApp(tester, const ResponsiveLayout(
      desktop: Text('Desktop'),
      mobilePortrait: Text('Mobile Portrait'),
    ));

    expect(find.text('Desktop'), findsOneWidget);
    expect(find.text('Mobile Portrait'), findsNothing);

    debugDefaultTargetPlatformOverride = null;
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('shows mobile portrait layout on mobile portrait', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    await setViewSize(tester, const Size(400, 800));

    await pumpApp(tester, const ResponsiveLayout(
      desktop: Text('Desktop'),
      mobilePortrait: Text('Mobile Portrait'),
      mobileLandscape: Text('Mobile Landscape'),
    ));

    expect(find.text('Mobile Portrait'), findsOneWidget);
    expect(find.text('Mobile Landscape'), findsNothing);

    debugDefaultTargetPlatformOverride = null;
    await resetViewSize(tester);
  });

  testWidgets('shows mobile landscape layout on mobile landscape',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    await setViewSize(tester, const Size(800, 400));

    await pumpApp(tester, const ResponsiveLayout(
      desktop: Text('Desktop'),
      mobilePortrait: Text('Mobile Portrait'),
      mobileLandscape: Text('Mobile Landscape'),
    ));

    expect(find.text('Mobile Landscape'), findsOneWidget);
    expect(find.text('Mobile Portrait'), findsNothing);

    debugDefaultTargetPlatformOverride = null;
    await resetViewSize(tester);
  });

  testWidgets(
    'falls back to mobile portrait when landscape layout is not provided',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      await setViewSize(tester, const Size(800, 400));

      await pumpApp(tester, const ResponsiveLayout(
        desktop: Text('Desktop'),
        mobilePortrait: Text('Mobile Portrait'),
      ));

      expect(find.text('Mobile Portrait'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);

      debugDefaultTargetPlatformOverride = null;
      await resetViewSize(tester);
    },
  );
}