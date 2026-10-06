import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('RotatePdfDesktopLayout', () {
    RotatePdfViewModel createViewModel({
      String? inputFilePath,
      RotatePdfDirection direction = RotatePdfDirection.clockwise90,
      RotatePdfPageScope scope = RotatePdfPageScope.allPages,
      String selection = '',
      String? outputFileName = 'rotated.pdf',
      String? outputDirectory = '/output',
      bool isSubmitting = false,
      bool canRotate = true,
      VoidCallback? onPickFile,
      ValueChanged<RotatePdfDirection>? onDirectionChanged,
      ValueChanged<RotatePdfPageScope>? onScopeChanged,
      ValueChanged<String>? onSelectionChanged,
      ValueChanged<String>? onOutputFileNameChanged,
      VoidCallback? onChooseOutputFolder,
      VoidCallback? onRotate,
      VoidCallback? onBack,
    }) {
      return RotatePdfViewModel(
        inputFilePath: inputFilePath,
        direction: direction,
        scope: scope,
        selection: selection,
        outputFileName: outputFileName,
        outputDirectory: outputDirectory,
        isSubmitting: isSubmitting,
        canRotate: canRotate,
        onPickFile: onPickFile ?? () {},
        onDirectionChanged: onDirectionChanged ?? (_) {},
        onScopeChanged: onScopeChanged ?? (_) {},
        onSelectionChanged: onSelectionChanged ?? (_) {},
        onOutputFileNameChanged: onOutputFileNameChanged ?? (_) {},
        onChooseOutputFolder: onChooseOutputFolder ?? () {},
        onRotate: onRotate ?? () {},
        onBack: onBack ?? () {},
      );
    }

    testWidgets('renders source section without an input file', (tester) async {
      await pumpApp(
        tester,
        RotatePdfDesktopLayout(viewModel: createViewModel()),
      );

      final l10n = lookupAppLocalizations(const Locale('en'));

      expect(find.text(l10n.toolsRotatePdf), findsOneWidget);
      expect(find.text(l10n.toolsRotateIntro), findsOneWidget);
      expect(find.text(l10n.toolsRotateSourceSectionTitle), findsOneWidget);

      expect(find.text(l10n.toolsRotateDirectionSectionTitle), findsNothing);
      expect(find.text(l10n.toolsRotatePagesSectionTitle), findsNothing);
      expect(find.byType(OutputFilePicker), findsNothing);
      expect(find.byType(ToolActionBar), findsNothing);
    });

    testWidgets('does not show tool sections for whitespace-only input path', (
      tester,
    ) async {
      await pumpApp(
        tester,
        RotatePdfDesktopLayout(
          viewModel: createViewModel(inputFilePath: '   '),
        ),
      );

      final l10n = lookupAppLocalizations(const Locale('en'));

      expect(find.text(l10n.toolsRotateDirectionSectionTitle), findsNothing);
      expect(find.text(l10n.toolsRotatePagesSectionTitle), findsNothing);
      expect(find.byType(OutputFilePicker), findsNothing);
      expect(find.byType(ToolActionBar), findsNothing);
    });

    testWidgets('renders all tool sections with an input file', (tester) async {
      await pumpApp(
        tester,
        RotatePdfDesktopLayout(
          viewModel: createViewModel(inputFilePath: '/documents/sample.pdf'),
        ),
      );

      final l10n = lookupAppLocalizations(const Locale('en'));

      expect(find.text(l10n.toolsRotateSourceSectionTitle), findsOneWidget);
      expect(find.text(l10n.toolsRotateDirectionSectionTitle), findsOneWidget);
      expect(find.text(l10n.toolsRotatePagesSectionTitle), findsOneWidget);
      expect(find.byType(OutputFilePicker), findsOneWidget);
      expect(find.byType(ToolActionBar), findsOneWidget);
      expect(find.byType(DirectionSelector), findsOneWidget);
      expect(find.byType(PageScopeEditor<RotatePdfPageScope>), findsOneWidget);
    });

    testWidgets('passes values to child widgets', (tester) async {
      await pumpApp(
        tester,
        RotatePdfDesktopLayout(
          viewModel: createViewModel(
            inputFilePath: '/documents/sample.pdf',
            direction: RotatePdfDirection.counterClockwise90,
            scope: RotatePdfPageScope.selectedPages,
            selection: '1-5,8',
            outputFileName: 'rotated-output.pdf',
            outputDirectory: '/documents/output',
          ),
        ),
      );

      final directionSelector = tester.widget<DirectionSelector>(
        find.byType(DirectionSelector),
      );

      expect(
        directionSelector.direction,
        RotatePdfDirection.counterClockwise90,
      );

      final pageScopeEditor = tester
          .widget<PageScopeEditor<RotatePdfPageScope>>(
            find.byType(PageScopeEditor<RotatePdfPageScope>),
          );

      expect(pageScopeEditor.scope, RotatePdfPageScope.selectedPages);
      expect(pageScopeEditor.selection, '1-5,8');
      expect(pageScopeEditor.requiresSelection, isTrue);

      final outputFilePicker = tester.widget<OutputFilePicker>(
        find.byType(OutputFilePicker),
      );

      expect(outputFilePicker.fileName, 'rotated-output.pdf');
      expect(outputFilePicker.directoryPath, '/documents/output');
    });

    testWidgets('forwards child callbacks', (tester) async {
      RotatePdfDirection? direction;
      RotatePdfPageScope? scope;
      String? selection;
      String? outputFileName;
      var chooseFolderCalled = false;
      var rotateCalled = false;
      var pickFileCalled = false;
      var backCalled = false;

      await pumpApp(
        tester,
        RotatePdfDesktopLayout(
          viewModel: createViewModel(
            inputFilePath: '/documents/sample.pdf',
            onPickFile: () => pickFileCalled = true,
            onDirectionChanged: (value) => direction = value,
            onScopeChanged: (value) => scope = value,
            onSelectionChanged: (value) => selection = value,
            onOutputFileNameChanged: (value) => outputFileName = value,
            onChooseOutputFolder: () => chooseFolderCalled = true,
            onRotate: () => rotateCalled = true,
            onBack: () => backCalled = true,
          ),
        ),
      );

      final singleFilePicker = tester.widget<SingleFilePicker>(
        find.byType(SingleFilePicker),
      );
      singleFilePicker.onPickFile();

      final directionSelector = tester.widget<DirectionSelector>(
        find.byType(DirectionSelector),
      );
      directionSelector.onDirectionChanged(RotatePdfDirection.upsideDown);

      final pageScopeEditor = tester
          .widget<PageScopeEditor<RotatePdfPageScope>>(
            find.byType(PageScopeEditor<RotatePdfPageScope>),
          );
      pageScopeEditor.onScopeChanged(RotatePdfPageScope.selectedPages);
      pageScopeEditor.onSelectionChanged('2,4,6');

      final outputFilePicker = tester.widget<OutputFilePicker>(
        find.byType(OutputFilePicker),
      );
      outputFilePicker.onFileNameChanged?.call('output.pdf');
      outputFilePicker.onChooseFolder();

      final toolActionBar = tester.widget<ToolActionBar>(
        find.byType(ToolActionBar),
      );
      toolActionBar.onAction();

      final scaffold = tester.widget<ToolScaffold>(find.byType(ToolScaffold));
      scaffold.onBack?.call();

      expect(pickFileCalled, isTrue);
      expect(direction, RotatePdfDirection.upsideDown);
      expect(scope, RotatePdfPageScope.selectedPages);
      expect(selection, '2,4,6');
      expect(outputFileName, 'output.pdf');
      expect(chooseFolderCalled, isTrue);
      expect(rotateCalled, isTrue);
      expect(backCalled, isTrue);
    });

    testWidgets('passes action state to ToolActionBar', (tester) async {
      await pumpApp(
        tester,
        RotatePdfDesktopLayout(
          viewModel: createViewModel(
            inputFilePath: '/documents/sample.pdf',
            isSubmitting: true,
            canRotate: false,
          ),
        ),
      );

      final l10n = lookupAppLocalizations(const Locale('en'));

      final actionBar = tester.widget<ToolActionBar>(
        find.byType(ToolActionBar),
      );

      expect(actionBar.isSubmitting, isTrue);
      expect(actionBar.canAction, isFalse);
      expect(actionBar.submittingText, l10n.toolsRotateSubmitting);
      expect(actionBar.label, l10n.toolsRotateButton);
      expect(actionBar.hintText, l10n.toolsRotateButtonDisabledHint);
    });
  });
}
