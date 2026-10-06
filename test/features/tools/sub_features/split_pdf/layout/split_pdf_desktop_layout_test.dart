import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('SplitPdfDesktopLayout', () {
    SplitPdfViewModel buildViewModel({
      String? inputFilePath,
      SplitPdfMode mode = SplitPdfMode.byPageCount,
      List<String> selections = const [],
      String pageCount = '10',
      String? outputDirectory,
      bool isSubmitting = false,
      bool canSplit = false,
      VoidCallback? onPickFile,
      ValueChanged<SplitPdfMode>? onModeChanged,
      ValueChanged<String>? onPageCountChanged,
      VoidCallback? onAddSelection,
      void Function(int index, String value)? onSelectionChanged,
      ValueChanged<int>? onRemoveSelection,
      VoidCallback? onChooseOutputFolder,
      VoidCallback? onSplit,
    }) {
      return SplitPdfViewModel(
        inputFilePath: inputFilePath,
        mode: mode,
        selections: selections,
        pageCount: pageCount,
        outputDirectory: outputDirectory,
        isSubmitting: isSubmitting,
        canSplit: canSplit,
        onPickFile: onPickFile ?? () {},
        onModeChanged: onModeChanged ?? (_) {},
        onPageCountChanged: onPageCountChanged ?? (_) {},
        onAddSelection: onAddSelection ?? () {},
        onSelectionChanged: onSelectionChanged ?? (_, _) {},
        onRemoveSelection: onRemoveSelection ?? (_) {},
        onChooseOutputFolder: onChooseOutputFolder ?? () {},
        onSplit: onSplit ?? () {},
      );
    }

    testWidgets('always renders the source section', (tester) async {
      await pumpApp(tester, SplitPdfDesktopLayout(viewModel: buildViewModel()));

      final l10n = lookupAppLocalizations(const Locale('en'));

      expect(find.text(l10n.toolsSplitPdf), findsOneWidget);
      expect(find.text(l10n.toolsSplitIntro), findsOneWidget);
      expect(find.text(l10n.toolsSplitSourceSectionTitle), findsOneWidget);
      expect(find.byType(SingleFilePicker), findsOneWidget);
    });

    testWidgets(
      'does not show split configuration before an input file is selected',
      (tester) async {
        await pumpApp(
          tester,
          SplitPdfDesktopLayout(viewModel: buildViewModel()),
        );

        expect(find.byType(SplitModeEditor), findsNothing);
        expect(find.byType(OutputFilePicker), findsNothing);
        expect(find.byType(ToolActionBar), findsNothing);
      },
    );

    testWidgets('shows split configuration after an input file is selected', (
      tester,
    ) async {
      await pumpApp(
        tester,
        SplitPdfDesktopLayout(
          viewModel: buildViewModel(
            inputFilePath: '/documents/input.pdf',
            outputDirectory: '/documents/output',
          ),
        ),
      );

      final l10n = lookupAppLocalizations(const Locale('en'));

      expect(find.text(l10n.toolsSplitModeSectionTitle), findsOneWidget);
      expect(find.byType(SplitModeEditor), findsOneWidget);
      expect(find.byType(OutputFilePicker), findsOneWidget);
      expect(find.byType(ToolActionBar), findsOneWidget);
    });

    testWidgets('forwards file picker action', (tester) async {
      var picked = false;

      await pumpApp(
        tester,
        SplitPdfDesktopLayout(
          viewModel: buildViewModel(
            onPickFile: () {
              picked = true;
            },
          ),
        ),
      );

      final singleFilePicker = tester.widget<SingleFilePicker>(
        find.byType(SingleFilePicker),
      );

      singleFilePicker.onPickFile();

      expect(picked, isTrue);
    });

    testWidgets('forwards split mode changes', (tester) async {
      SplitPdfMode? selectedMode;

      await pumpApp(
        tester,
        SplitPdfDesktopLayout(
          viewModel: buildViewModel(
            inputFilePath: '/documents/input.pdf',
            onModeChanged: (mode) {
              selectedMode = mode;
            },
          ),
        ),
      );

      final splitModeEditor = tester.widget<SplitModeEditor>(
        find.byType(SplitModeEditor),
      );

      splitModeEditor.onModeChanged(SplitPdfMode.bySelection);

      expect(selectedMode, SplitPdfMode.bySelection);
    });

    testWidgets('forwards page count changes', (tester) async {
      String? changedPageCount;

      await pumpApp(
        tester,
        SplitPdfDesktopLayout(
          viewModel: buildViewModel(
            inputFilePath: '/documents/input.pdf',
            onPageCountChanged: (value) {
              changedPageCount = value;
            },
          ),
        ),
      );

      final splitModeEditor = tester.widget<SplitModeEditor>(
        find.byType(SplitModeEditor),
      );

      splitModeEditor.onPageCountChanged('25');

      expect(changedPageCount, '25');
    });

    testWidgets('forwards selection actions', (tester) async {
      var added = false;
      int? changedIndex;
      String? changedValue;
      int? removedIndex;

      await pumpApp(
        tester,
        SplitPdfDesktopLayout(
          viewModel: buildViewModel(
            inputFilePath: '/documents/input.pdf',
            onAddSelection: () {
              added = true;
            },
            onSelectionChanged: (index, value) {
              changedIndex = index;
              changedValue = value;
            },
            onRemoveSelection: (index) {
              removedIndex = index;
            },
          ),
        ),
      );

      final splitModeEditor = tester.widget<SplitModeEditor>(
        find.byType(SplitModeEditor),
      );

      splitModeEditor.onAddSelection();
      splitModeEditor.onSelectionChanged(1, '10-15');
      splitModeEditor.onRemoveSelection(2);

      expect(added, isTrue);
      expect(changedIndex, 1);
      expect(changedValue, '10-15');
      expect(removedIndex, 2);
    });

    testWidgets('forwards output folder action', (tester) async {
      var folderChosen = false;

      await pumpApp(
        tester,
        SplitPdfDesktopLayout(
          viewModel: buildViewModel(
            inputFilePath: '/documents/input.pdf',
            onChooseOutputFolder: () {
              folderChosen = true;
            },
          ),
        ),
      );

      final outputPicker = tester.widget<OutputFilePicker>(
        find.byType(OutputFilePicker),
      );

      outputPicker.onChooseFolder();

      expect(folderChosen, isTrue);
    });

    testWidgets('passes submitting and action state to action bar', (
      tester,
    ) async {
      await pumpApp(
        tester,
        SplitPdfDesktopLayout(
          viewModel: buildViewModel(
            inputFilePath: '/documents/input.pdf',
            isSubmitting: true,
            canSplit: true,
          ),
        ),
      );

      final actionBar = tester.widget<ToolActionBar>(
        find.byType(ToolActionBar),
      );

      expect(actionBar.isSubmitting, isTrue);
      expect(actionBar.canAction, isTrue);
    });

    testWidgets('forwards split action', (tester) async {
      var split = false;

      await pumpApp(
        tester,
        SplitPdfDesktopLayout(
          viewModel: buildViewModel(
            inputFilePath: '/documents/input.pdf',
            onSplit: () {
              split = true;
            },
          ),
        ),
      );

      final actionBar = tester.widget<ToolActionBar>(
        find.byType(ToolActionBar),
      );

      actionBar.onAction();

      expect(split, isTrue);
    });
  });
}
