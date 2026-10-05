import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/sub_features/sub_features.dart';
import 'package:velin/features/tools/widgets/widgets.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('CompressPdfDesktopLayout', () {
    testWidgets('always renders source picker', (tester) async {
      await pumpApp(tester, CompressPdfDesktopLayout(viewModel: _viewModel()));

      expect(find.byType(SingleFilePicker), findsOneWidget);
    });

    testWidgets('hides compression controls when there is no input file', (
      tester,
    ) async {
      await pumpApp(tester, CompressPdfDesktopLayout(viewModel: _viewModel()));

      expect(find.byType(QualityEditor), findsNothing);
      expect(find.byType(OutputFilePicker), findsNothing);
      expect(find.byType(ToolActionBar), findsNothing);
    });

    testWidgets('treats whitespace-only input path as missing', (tester) async {
      await pumpApp(
        tester,
        CompressPdfDesktopLayout(viewModel: _viewModel(inputFilePath: '   ')),
      );

      expect(find.byType(SingleFilePicker), findsOneWidget);
      expect(find.byType(QualityEditor), findsNothing);
      expect(find.byType(OutputFilePicker), findsNothing);
      expect(find.byType(ToolActionBar), findsNothing);
    });

    testWidgets('renders compression controls when input file exists', (
      tester,
    ) async {
      var selectedQuality = 0;
      String? selectedFileName;
      String? selectedDirectory;
      var compressed = false;

      await pumpApp(
        tester,
        CompressPdfDesktopLayout(
          viewModel: _viewModel(
            inputFilePath: '/documents/input.pdf',
            outputFileName: 'compressed.pdf',
            outputDirectory: '/documents',
            quality: 75,
            onQualityChanged: (value) => selectedQuality = value,
            onOutputFileNameChanged: (value) {
              selectedFileName = value;
            },
            onChooseOutputFolder: () {
              selectedDirectory = '/documents/output';
            },
            onCompress: () {
              compressed = true;
            },
          ),
        ),
      );

      expect(find.byType(QualityEditor), findsOneWidget);
      expect(find.byType(OutputFilePicker), findsOneWidget);
      expect(find.byType(ToolActionBar), findsOneWidget);

      final qualityEditor = tester.widget<QualityEditor>(
        find.byType(QualityEditor),
      );
      qualityEditor.onQualityChanged(80);

      expect(selectedQuality, 80);

      final outputPicker = tester.widget<OutputFilePicker>(
        find.byType(OutputFilePicker),
      );
      expect(outputPicker.fileName, 'compressed.pdf');
      expect(outputPicker.directoryPath, '/documents');

      outputPicker.onFileNameChanged?.call('final.pdf');
      expect(selectedFileName, 'final.pdf');

      outputPicker.onChooseFolder();
      expect(selectedDirectory, '/documents/output');

      final actionBar = tester.widget<ToolActionBar>(
        find.byType(ToolActionBar),
      );
      actionBar.onAction();

      expect(compressed, isTrue);
    });
  });
}

CompressPdfViewModel _viewModel({
  String? inputFilePath,
  String? outputFileName,
  String? outputDirectory,
  int quality = 50,
  bool isSubmitting = false,
  bool canCompress = true,
  VoidCallback? onPickFile,
  ValueChanged<int>? onQualityChanged,
  ValueChanged<String>? onOutputFileNameChanged,
  VoidCallback? onChooseOutputFolder,
  VoidCallback? onCompress,
}) {
  return CompressPdfViewModel(
    inputFilePath: inputFilePath,
    outputFileName: outputFileName,
    outputDirectory: outputDirectory,
    quality: quality,
    isSubmitting: isSubmitting,
    canCompress: canCompress,
    onPickFile: onPickFile ?? () {},
    onQualityChanged: onQualityChanged ?? (_) {},
    onOutputFileNameChanged: onOutputFileNameChanged ?? (_) {},
    onChooseOutputFolder: onChooseOutputFolder ?? () {},
    onCompress: onCompress ?? () {},
    onBack: () {},
  );
}
