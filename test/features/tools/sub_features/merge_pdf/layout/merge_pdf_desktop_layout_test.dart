import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/tools.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  MergePdfViewModel createViewModel({
    List<MergePdfToolInput> inputs = const [],
    String outputFileName = 'merged.pdf',
    String? outputDirectory,
    bool isSubmitting = false,
    bool hasInputFiles = false,
    bool canMerge = false,
    VoidCallback? onAddFiles,
    ValueChanged<int>? onRemoveFile,
    void Function(int oldIndex, int newIndex)? onReorder,
    void Function(int index, String value)? onPageSelectionChanged,
    ValueChanged<String>? onOutputFileNameChanged,
    VoidCallback? onChooseOutputFolder,
    VoidCallback? onMerge,
  }) {
    return MergePdfViewModel(
      inputs: inputs,
      outputFileName: outputFileName,
      outputDirectory: outputDirectory,
      onAddFiles: onAddFiles ?? () {},
      onRemoveFile: onRemoveFile ?? (_) {},
      onReorder: onReorder ?? (_, _) {},
      onPageSelectionChanged: onPageSelectionChanged ?? (_, _) {},
      onOutputFileNameChanged: onOutputFileNameChanged ?? (_) {},
      onChooseOutputFolder: onChooseOutputFolder ?? () {},
      onMerge: onMerge ?? () {},
      isSubmitting: isSubmitting,
      hasInputFiles: hasInputFiles,
      canMerge: canMerge,
    );
  }

  MergePdfToolInput input(String filePath, {String? pageSelection}) {
    return MergePdfToolInput(filePath: filePath, pageSelection: pageSelection);
  }

  group('MergePdfDesktopLayout', () {
    testWidgets('renders the multi-file picker', (tester) async {
      final viewModel = createViewModel();

      await pumpApp(tester, MergePdfDesktopLayout(viewModel: viewModel));

      expect(find.byType(MultiFilePicker), findsOneWidget);
    });

    testWidgets('hides output controls when there are no input files', (
      tester,
    ) async {
      final viewModel = createViewModel(inputs: const [], hasInputFiles: false);

      await pumpApp(tester, MergePdfDesktopLayout(viewModel: viewModel));

      expect(find.byType(OutputFilePicker), findsNothing);
      expect(find.byType(ToolActionBar), findsNothing);
    });

    testWidgets('renders output controls when input files exist', (
      tester,
    ) async {
      final viewModel = createViewModel(
        inputs: [input('/documents/first.pdf'), input('/documents/second.pdf')],
        hasInputFiles: true,
      );

      await pumpApp(tester, MergePdfDesktopLayout(viewModel: viewModel));

      expect(find.byType(OutputFilePicker), findsOneWidget);
      expect(find.byType(ToolActionBar), findsOneWidget);
    });

    testWidgets('passes file paths and page selections to the picker', (
      tester,
    ) async {
      final viewModel = createViewModel(
        inputs: [
          input('/documents/first.pdf', pageSelection: '1-5'),
          input('/documents/second.pdf', pageSelection: 'odd'),
        ],
        hasInputFiles: true,
      );

      await pumpApp(tester, MergePdfDesktopLayout(viewModel: viewModel));

      final picker = tester.widget<MultiFilePicker>(
        find.byType(MultiFilePicker),
      );

      expect(picker.filePaths, [
        '/documents/first.pdf',
        '/documents/second.pdf',
      ]);
      expect(picker.pageSelections, ['1-5', 'odd']);
      expect(picker.showPageSelection, isTrue);
    });

    testWidgets('passes output values to the output picker', (tester) async {
      final viewModel = createViewModel(
        inputs: [input('/documents/source.pdf')],
        hasInputFiles: true,
        outputFileName: 'combined.pdf',
        outputDirectory: '/documents/output',
      );

      await pumpApp(tester, MergePdfDesktopLayout(viewModel: viewModel));

      final picker = tester.widget<OutputFilePicker>(
        find.byType(OutputFilePicker),
      );

      expect(picker.fileName, 'combined.pdf');
      expect(picker.directoryPath, '/documents/output');
    });

    testWidgets('passes submitting and action state to ToolActionBar', (
      tester,
    ) async {
      final viewModel = createViewModel(
        inputs: [input('/documents/source.pdf')],
        hasInputFiles: true,
        isSubmitting: true,
        canMerge: false,
      );

      await pumpApp(tester, MergePdfDesktopLayout(viewModel: viewModel));

      final actionBar = tester.widget<ToolActionBar>(
        find.byType(ToolActionBar),
      );

      expect(actionBar.isSubmitting, isTrue);
      expect(actionBar.canAction, isFalse);
    });

    testWidgets('forwards file picker callbacks', (tester) async {
      var addFilesCalled = false;
      var removedIndex = -1;
      var reorderedOldIndex = -1;
      var reorderedNewIndex = -1;
      var selectionIndex = -1;
      var selectionValue = '';

      final viewModel = createViewModel(
        inputs: [input('/documents/first.pdf'), input('/documents/second.pdf')],
        hasInputFiles: true,
        onAddFiles: () => addFilesCalled = true,
        onRemoveFile: (index) => removedIndex = index,
        onReorder: (oldIndex, newIndex) {
          reorderedOldIndex = oldIndex;
          reorderedNewIndex = newIndex;
        },
        onPageSelectionChanged: (index, value) {
          selectionIndex = index;
          selectionValue = value;
        },
      );

      await pumpApp(tester, MergePdfDesktopLayout(viewModel: viewModel));

      final picker = tester.widget<MultiFilePicker>(
        find.byType(MultiFilePicker),
      );

      picker.onAddFiles();
      picker.onRemoveFile(1);
      picker.onReorderItem(0, 1);
      picker.onPageSelectionChanged?.call(1, '2-4');

      expect(addFilesCalled, isTrue);
      expect(removedIndex, 1);
      expect(reorderedOldIndex, 0);
      expect(reorderedNewIndex, 1);
      expect(selectionIndex, 1);
      expect(selectionValue, '2-4');
    });

    testWidgets('forwards output picker callbacks', (tester) async {
      var fileName = '';
      var chooseFolderCalled = false;

      final viewModel = createViewModel(
        inputs: [input('/documents/source.pdf')],
        hasInputFiles: true,
        onOutputFileNameChanged: (value) => fileName = value,
        onChooseOutputFolder: () => chooseFolderCalled = true,
      );

      await pumpApp(tester, MergePdfDesktopLayout(viewModel: viewModel));

      final picker = tester.widget<OutputFilePicker>(
        find.byType(OutputFilePicker),
      );

      picker.onFileNameChanged?.call('combined.pdf');
      picker.onChooseFolder();

      expect(fileName, 'combined.pdf');
      expect(chooseFolderCalled, isTrue);
    });

    testWidgets('forwards merge action callback', (tester) async {
      var mergeCalled = false;

      final viewModel = createViewModel(
        inputs: [input('/documents/source.pdf')],
        hasInputFiles: true,
        canMerge: true,
        onMerge: () => mergeCalled = true,
      );

      await pumpApp(tester, MergePdfDesktopLayout(viewModel: viewModel));

      final actionBar = tester.widget<ToolActionBar>(
        find.byType(ToolActionBar),
      );

      actionBar.onAction();

      expect(mergeCalled, isTrue);
    });

    testWidgets('passes hasInputFiles independently from inputs', (
      tester,
    ) async {
      final viewModel = createViewModel(
        inputs: [MergePdfToolInput(filePath: '/documents/source.pdf')],
        hasInputFiles: true,
      );

      await pumpApp(tester, MergePdfDesktopLayout(viewModel: viewModel));

      expect(find.byType(OutputFilePicker), findsOneWidget);
      expect(find.byType(ToolActionBar), findsOneWidget);
    });
  });
}
