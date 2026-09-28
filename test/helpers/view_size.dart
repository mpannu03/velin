import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

Future<void> setViewSize(WidgetTester tester, Size logicalSize) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = logicalSize;
  await tester.pump();
}

/// Resets the view metrics back to their defaults.
Future<void> resetViewSize(WidgetTester tester) async {
  tester.view.reset();
  await tester.pump();
}