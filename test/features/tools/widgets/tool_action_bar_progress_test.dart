import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/bloc/tool_task_handle.dart';
import 'package:velin/features/tools/widgets/tool_action_bar.dart';

import '../../../helpers/helpers.dart';

void main() {
  late ToolTaskHandle handle;
  late int cancelCalls;

  setUp(() {
    handle = ToolTaskHandle();
    cancelCalls = 0;
  });

  tearDown(() => handle.dispose());

  Future<void> pumpBar(WidgetTester tester) => pumpApp(
    tester,
    ToolActionBar(
      isSubmitting: true,
      submittingText: 'Merging…',
      canAction: true,
      icon: Icons.merge,
      label: 'Merge',
      hintText: '',
      onAction: () {},
      task: handle,
    ),
  );

  LinearProgressIndicator indicator(WidgetTester tester) =>
      tester.widget(find.byType(LinearProgressIndicator));

  testWidgets('shows queued state with an indeterminate bar', (tester) async {
    handle.queued(cancel: () => cancelCalls++);
    await pumpBar(tester);

    expect(find.text(testL10n.toolsTaskQueued), findsOneWidget);
    expect(indicator(tester).value, isNull);
  });

  testWidgets('shows determinate progress while running', (tester) async {
    handle
      ..queued(cancel: () => cancelCalls++)
      ..running(0.42);
    await pumpBar(tester);

    expect(
      find.text('Merging… · ${testL10n.toolsTaskProgress(42)}'),
      findsOneWidget,
    );
    expect(indicator(tester).value, 0.42);

    handle.running(0.8);
    await tester.pump();

    expect(indicator(tester).value, 0.8);
  });

  testWidgets('cancel button cancels once and then disables', (tester) async {
    handle
      ..queued(cancel: () => cancelCalls++)
      ..running(0.1);
    await pumpBar(tester);

    await tester.tap(find.text(testL10n.commonCancel));
    await tester.pump();

    expect(cancelCalls, 1);
    expect(find.text(testL10n.toolsTaskCancelling), findsOneWidget);

    final cancel = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(cancel.onPressed, isNull);
  });
}
