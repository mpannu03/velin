import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/tools.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('ExtractPdfDesktopLayout', () {
    ExtractPdfViewModel createViewModel({
      String? inputFilePath,
      String? pageSelection,
      String? outputFileName,
      String? outputDirectory,
      bool isSubmitting = false,
      bool canExtract = false,
      VoidCallback? onBack,
      VoidCallback? onPickFile,
      ValueChanged<String>? onSelectionChanged,
      ValueChanged<String?>? onOutputFileNameChanged,
      VoidCallback? onChooseOutputFolder,
      VoidCallback? onExtract,
    }) {
      return ExtractPdfViewModel(
        inputFilePath: inputFilePath,
        pageSelection: pageSelection,
        outputFileName: outputFileName,
        outputDirectory: outputDirectory,
        isSubmitting: isSubmitting,
        canExtract: canExtract,
        onBack: onBack ?? () {},
        onPickFile: onPickFile ?? () {},
        onSelectionChanged: onSelectionChanged ?? (_) {},
        onOutputFileNameChanged: onOutputFileNameChanged ?? (_) {},
        onChooseOutputFolder: onChooseOutputFolder ?? () {},
        onExtract: onExtract ?? () {},
      );
    }

    testWidgets('renders source picker without input file', (tester) async {
      await pumpApp(
        tester,
        ExtractPdfDesktopLayout(viewModel: createViewModel()),
      );

      expect(find.byType(ToolScaffold), findsOneWidget);
      expect(find.byType(SingleFilePicker), findsOneWidget);
      expect(find.byType(PageSelectionField), findsNothing);
      expect(find.byType(OutputFilePicker), findsNothing);
      expect(find.byType(ToolActionBar), findsNothing);
    });

    testWidgets('hides dependent controls for empty input path', (
      tester,
    ) async {
      await pumpApp(
        tester,
        ExtractPdfDesktopLayout(viewModel: createViewModel(inputFilePath: '')),
      );

      expect(find.byType(SingleFilePicker), findsOneWidget);
      expect(find.byType(PageSelectionField), findsNothing);
      expect(find.byType(OutputFilePicker), findsNothing);
      expect(find.byType(ToolActionBar), findsNothing);
    });

    testWidgets('renders extraction controls when input file exists', (
      tester,
    ) async {
      await pumpApp(
        tester,
        ExtractPdfDesktopLayout(
          viewModel: createViewModel(
            inputFilePath: '/documents/sample.pdf',
            pageSelection: '1-3',
            outputFileName: 'extracted.pdf',
            outputDirectory: '/documents',
          ),
        ),
      );

      expect(find.byType(SingleFilePicker), findsOneWidget);
      expect(find.byType(PageSelectionField), findsOneWidget);
      expect(find.byType(OutputFilePicker), findsOneWidget);
      expect(find.byType(ToolActionBar), findsOneWidget);
    });

    testWidgets('passes page selection to selection field', (tester) async {
      await pumpApp(
        tester,
        ExtractPdfDesktopLayout(
          viewModel: createViewModel(
            inputFilePath: '/documents/sample.pdf',
            pageSelection: '1,3,5-7',
          ),
        ),
      );

      final field = tester.widget<PageSelectionField>(
        find.byType(PageSelectionField),
      );

      expect(field.value, '1,3,5-7');
      expect(field.fieldKey, const ValueKey('extract-page-selection'));
      expect(field.width, 260);
    });

    testWidgets('passes action state to action bar', (tester) async {
      await pumpApp(
        tester,
        ExtractPdfDesktopLayout(
          viewModel: createViewModel(
            inputFilePath: '/documents/sample.pdf',
            isSubmitting: true,
            canExtract: false,
          ),
        ),
      );

      final actionBar = tester.widget<ToolActionBar>(
        find.byType(ToolActionBar),
      );

      expect(actionBar.isSubmitting, isTrue);
      expect(actionBar.canAction, isFalse);
    });

    testWidgets('forwards callbacks to child widgets', (tester) async {
      var pickedFile = false;
      String? selectedPages;
      String? outputFileName;
      var choseFolder = false;
      var extracted = false;

      await pumpApp(
        tester,
        ExtractPdfDesktopLayout(
          viewModel: createViewModel(
            inputFilePath: '/documents/sample.pdf',
            onPickFile: () => pickedFile = true,
            onSelectionChanged: (value) => selectedPages = value,
            onOutputFileNameChanged: (value) => outputFileName = value,
            onChooseOutputFolder: () => choseFolder = true,
            onExtract: () => extracted = true,
          ),
        ),
      );

      final filePicker = tester.widget<SingleFilePicker>(
        find.byType(SingleFilePicker),
      );
      filePicker.onPickFile();

      final selectionField = tester.widget<PageSelectionField>(
        find.byType(PageSelectionField),
      );
      selectionField.onSubmitted?.call('2,4-6');

      final outputPicker = tester.widget<OutputFilePicker>(
        find.byType(OutputFilePicker),
      );
      outputPicker.onFileNameChanged?.call('result.pdf');
      outputPicker.onChooseFolder();

      final actionBar = tester.widget<ToolActionBar>(
        find.byType(ToolActionBar),
      );
      actionBar.onAction();

      expect(pickedFile, isTrue);
      expect(selectedPages, '2,4-6');
      expect(outputFileName, 'result.pdf');
      expect(choseFolder, isTrue);
      expect(extracted, isTrue);
    });

    testWidgets('passes output values to output picker', (tester) async {
      await pumpApp(
        tester,
        ExtractPdfDesktopLayout(
          viewModel: createViewModel(
            inputFilePath: '/documents/sample.pdf',
            outputFileName: 'pages.pdf',
            outputDirectory: '/documents/output',
          ),
        ),
      );

      final outputPicker = tester.widget<OutputFilePicker>(
        find.byType(OutputFilePicker),
      );

      expect(outputPicker.fileName, 'pages.pdf');
      expect(outputPicker.directoryPath, '/documents/output');
    });
  });
}
