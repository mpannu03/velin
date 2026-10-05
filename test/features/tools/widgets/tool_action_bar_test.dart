import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/widgets/tool_action_bar.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('ToolActionBar', () {
    testWidgets('shows submitting state when submitting', (tester) async {
      await pumpApp(
        tester,
        const ToolActionBar(
          isSubmitting: true,
          submittingText: 'Processing...',
          canAction: true,
          icon: Icons.play_arrow,
          label: 'Run',
          hintText: 'Cannot run yet.',
          onAction: _noop,
        ),
      );

      expect(find.text('Processing...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('disables action button while submitting', (tester) async {
      await pumpApp(
        tester,
        const ToolActionBar(
          isSubmitting: true,
          submittingText: 'Processing...',
          canAction: true,
          icon: Icons.play_arrow,
          label: 'Run',
          hintText: 'Cannot run yet.',
          onAction: _noop,
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));

      expect(button.onPressed, isNull);
    });

    testWidgets('shows filled button when action is available', (tester) async {
      var actionCalled = false;

      await pumpApp(
        tester,
        ToolActionBar(
          isSubmitting: false,
          submittingText: 'Processing...',
          canAction: true,
          icon: Icons.play_arrow,
          label: 'Run',
          hintText: 'Cannot run yet.',
          onAction: () => actionCalled = true,
        ),
      );

      expect(find.text('Run'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);

      await tester.tap(find.text('Run'));
      await tester.pump();

      expect(actionCalled, isTrue);
    });

    testWidgets('shows outlined button when action is unavailable', (
      tester,
    ) async {
      var actionCalled = false;

      await pumpApp(
        tester,
        ToolActionBar(
          isSubmitting: false,
          submittingText: 'Processing...',
          canAction: false,
          icon: Icons.play_arrow,
          label: 'Run',
          hintText: 'Add a file first.',
          onAction: () => actionCalled = true,
        ),
      );

      expect(find.text('Run'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);

      await tester.tap(find.text('Run'));
      await tester.pump();

      expect(actionCalled, isTrue);
    });

    testWidgets('shows hint text when action is unavailable', (tester) async {
      await pumpApp(
        tester,
        const ToolActionBar(
          isSubmitting: false,
          submittingText: 'Processing...',
          canAction: false,
          icon: Icons.play_arrow,
          label: 'Run',
          hintText: 'Add a file first.',
          onAction: _noop,
        ),
      );

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));

      expect(tooltip.message, 'Add a file first.');
    });

    testWidgets('does not show hint text when action is available', (
      tester,
    ) async {
      await pumpApp(
        tester,
        const ToolActionBar(
          isSubmitting: false,
          submittingText: 'Processing...',
          canAction: true,
          icon: Icons.play_arrow,
          label: 'Run',
          hintText: 'Add a file first.',
          onAction: _noop,
        ),
      );

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));

      expect(tooltip.message, isEmpty);
    });

    testWidgets('uses supplied icon', (tester) async {
      await pumpApp(
        tester,
        const ToolActionBar(
          isSubmitting: false,
          submittingText: 'Processing...',
          canAction: true,
          icon: Icons.picture_as_pdf,
          label: 'Run',
          hintText: 'Add a file first.',
          onAction: _noop,
        ),
      );

      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
    });

    testWidgets('does not show action button while submitting', (tester) async {
      await pumpApp(
        tester,
        const ToolActionBar(
          isSubmitting: true,
          submittingText: 'Processing...',
          canAction: false,
          icon: Icons.play_arrow,
          label: 'Run',
          hintText: 'Add a file first.',
          onAction: _noop,
        ),
      );

      expect(find.text('Run'), findsNothing);
      expect(find.text('Processing...'), findsOneWidget);
    });
  });
}

void _noop() {}
