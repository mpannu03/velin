import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/sub_features/image_to_pdf/image_to_pdf.dart';
import 'package:velin/features/tools/widgets/widgets.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('ImageToPdfDesktopLayout', () {
    ImageToPdfViewModel createViewModel({
      List<ImageToPdfToolInput> inputs = const [],
      ImagePickerViewMode viewMode = ImagePickerViewMode.grid,
      ImageToPdfPageSize pageSize = ImageToPdfPageSize.auto,
      ImageToPdfOrientation orientation = ImageToPdfOrientation.auto,
      ImageToPdfFit fit = ImageToPdfFit.contain,
      String outputFileName = 'output.pdf',
      String? outputDirectory,
      bool isSubmitting = false,
      bool canConvert = false,
      VoidCallback? onAddImages,
      ValueChanged<int>? onRemoveImage,
      void Function(int oldIndex, int newIndex)? onReorder,
      ValueChanged<ImagePickerViewMode>? onViewModeChanged,
      ValueChanged<ImageToPdfPageSize>? onPageSizeChanged,
      ValueChanged<ImageToPdfOrientation>? onOrientationChanged,
      ValueChanged<ImageToPdfFit>? onFitChanged,
      ValueChanged<String>? onOutputFileNameChanged,
      VoidCallback? onChooseOutputFolder,
      VoidCallback? onConvert,
      VoidCallback? onBack,
    }) {
      return ImageToPdfViewModel(
        inputs: inputs,
        viewMode: viewMode,
        pageSize: pageSize,
        orientation: orientation,
        fit: fit,
        outputFileName: outputFileName,
        outputDirectory: outputDirectory,
        isSubmitting: isSubmitting,
        canConvert: canConvert,
        onAddImages: onAddImages ?? () {},
        onRemoveImage: onRemoveImage ?? (_) {},
        onReorder: onReorder ?? (_, _) {},
        onViewModeChanged: onViewModeChanged ?? (_) {},
        onPageSizeChanged: onPageSizeChanged ?? (_) {},
        onOrientationChanged: onOrientationChanged ?? (_) {},
        onFitChanged: onFitChanged ?? (_) {},
        onOutputFileNameChanged: onOutputFileNameChanged ?? (_) {},
        onChooseOutputFolder: onChooseOutputFolder ?? () {},
        onConvert: onConvert ?? () {},
        onBack: onBack ?? () {},
      );
    }

    ImageToPdfToolInput input(String filePath) {
      return ImageToPdfToolInput(filePath: filePath);
    }

    testWidgets('renders image picker when there are no images', (
      tester,
    ) async {
      await pumpApp(
        tester,
        ImageToPdfDesktopLayout(viewModel: createViewModel()),
      );

      expect(find.byType(ImageFilePicker), findsOneWidget);
      expect(find.byType(PageSizeSelector), findsNothing);
      expect(find.byType(OrientationSelector), findsNothing);
      expect(find.byType(FitSelector), findsNothing);
      expect(find.byType(OutputFilePicker), findsNothing);
      expect(find.byType(ToolActionBar), findsNothing);
    });

    testWidgets('hides dependent controls when there are no images', (
      tester,
    ) async {
      await pumpApp(
        tester,
        ImageToPdfDesktopLayout(viewModel: createViewModel()),
      );

      expect(find.byType(ToolSectionCard), findsNothing);
      expect(find.byType(OutputFilePicker), findsNothing);
      expect(find.byType(ToolActionBar), findsNothing);
    });

    testWidgets('renders page setup and output controls when images exist', (
      tester,
    ) async {
      await pumpApp(
        tester,
        ImageToPdfDesktopLayout(
          viewModel: createViewModel(
            inputs: [input('/images/one.png')],
            outputFileName: 'images.pdf',
            outputDirectory: '/documents',
          ),
        ),
      );

      expect(find.byType(ImageFilePicker), findsOneWidget);
      expect(find.byType(PageSizeSelector), findsOneWidget);
      expect(find.byType(OrientationSelector), findsOneWidget);
      expect(find.byType(FitSelector), findsOneWidget);
      expect(find.byType(OutputFilePicker), findsOneWidget);
      expect(find.byType(ToolActionBar), findsOneWidget);
    });

    testWidgets('passes image paths and view mode to image picker', (
      tester,
    ) async {
      await pumpApp(
        tester,
        ImageToPdfDesktopLayout(
          viewModel: createViewModel(
            inputs: [input('/images/one.png'), input('/images/two.jpg')],
            viewMode: ImagePickerViewMode.list,
          ),
        ),
      );

      final picker = tester.widget<ImageFilePicker>(
        find.byType(ImageFilePicker),
      );

      expect(picker.filePaths, ['/images/one.png', '/images/two.jpg']);
      expect(picker.viewMode, ImagePickerViewMode.list);
    });

    testWidgets('passes page setup values to selectors', (tester) async {
      await pumpApp(
        tester,
        ImageToPdfDesktopLayout(
          viewModel: createViewModel(
            inputs: [input('/images/one.png')],
            pageSize: ImageToPdfPageSize.a4,
            orientation: ImageToPdfOrientation.landscape,
            fit: ImageToPdfFit.cover,
          ),
        ),
      );

      final pageSizeSelector = tester.widget<PageSizeSelector>(
        find.byType(PageSizeSelector),
      );
      final orientationSelector = tester.widget<OrientationSelector>(
        find.byType(OrientationSelector),
      );
      final fitSelector = tester.widget<FitSelector>(find.byType(FitSelector));

      expect(pageSizeSelector.pageSize, ImageToPdfPageSize.a4);
      expect(orientationSelector.orientation, ImageToPdfOrientation.landscape);
      expect(fitSelector.fit, ImageToPdfFit.cover);
    });

    testWidgets('passes output values and action state to child widgets', (
      tester,
    ) async {
      await pumpApp(
        tester,
        ImageToPdfDesktopLayout(
          viewModel: createViewModel(
            inputs: [input('/images/one.png')],
            outputFileName: 'converted.pdf',
            outputDirectory: '/documents',
            isSubmitting: true,
            canConvert: false,
          ),
        ),
      );

      final outputPicker = tester.widget<OutputFilePicker>(
        find.byType(OutputFilePicker),
      );
      final actionBar = tester.widget<ToolActionBar>(
        find.byType(ToolActionBar),
      );

      expect(outputPicker.fileName, 'converted.pdf');
      expect(outputPicker.directoryPath, '/documents');
      expect(actionBar.isSubmitting, isTrue);
      expect(actionBar.canAction, isFalse);
    });

    testWidgets('forwards image picker callbacks', (tester) async {
      var added = false;
      int? removedIndex;
      int? oldIndex;
      int? newIndex;
      ImagePickerViewMode? changedViewMode;

      await pumpApp(
        tester,
        ImageToPdfDesktopLayout(
          viewModel: createViewModel(
            inputs: [input('/images/one.png'), input('/images/two.png')],
            onAddImages: () => added = true,
            onRemoveImage: (index) => removedIndex = index,
            onReorder: (oldValue, newValue) {
              oldIndex = oldValue;
              newIndex = newValue;
            },
            onViewModeChanged: (value) => changedViewMode = value,
          ),
        ),
      );

      final picker = tester.widget<ImageFilePicker>(
        find.byType(ImageFilePicker),
      );

      picker.onAddFiles();
      picker.onRemoveFile(1);
      picker.onReorderItem(1, 0);
      picker.onViewModeChanged(ImagePickerViewMode.list);

      expect(added, isTrue);
      expect(removedIndex, 1);
      expect(oldIndex, 1);
      expect(newIndex, 0);
      expect(changedViewMode, ImagePickerViewMode.list);
    });

    testWidgets('forwards page setup callbacks', (tester) async {
      ImageToPdfPageSize? pageSize;
      ImageToPdfOrientation? orientation;
      ImageToPdfFit? fit;

      await pumpApp(
        tester,
        ImageToPdfDesktopLayout(
          viewModel: createViewModel(
            inputs: [input('/images/one.png')],
            onPageSizeChanged: (value) => pageSize = value,
            onOrientationChanged: (value) => orientation = value,
            onFitChanged: (value) => fit = value,
          ),
        ),
      );

      final pageSizeSelector = tester.widget<PageSizeSelector>(
        find.byType(PageSizeSelector),
      );
      final orientationSelector = tester.widget<OrientationSelector>(
        find.byType(OrientationSelector),
      );
      final fitSelector = tester.widget<FitSelector>(find.byType(FitSelector));

      pageSizeSelector.onPageSizeChanged(ImageToPdfPageSize.letter);
      orientationSelector.onOrientationChanged(ImageToPdfOrientation.portrait);
      fitSelector.onFitChanged(ImageToPdfFit.stretch);

      expect(pageSize, ImageToPdfPageSize.letter);
      expect(orientation, ImageToPdfOrientation.portrait);
      expect(fit, ImageToPdfFit.stretch);
    });

    testWidgets('forwards output and convert callbacks', (tester) async {
      String? outputFileName;
      var choseFolder = false;
      var converted = false;

      await pumpApp(
        tester,
        ImageToPdfDesktopLayout(
          viewModel: createViewModel(
            inputs: [input('/images/one.png')],
            onOutputFileNameChanged: (value) => outputFileName = value,
            onChooseOutputFolder: () => choseFolder = true,
            onConvert: () => converted = true,
          ),
        ),
      );

      final outputPicker = tester.widget<OutputFilePicker>(
        find.byType(OutputFilePicker),
      );
      final actionBar = tester.widget<ToolActionBar>(
        find.byType(ToolActionBar),
      );

      outputPicker.onFileNameChanged?.call('result.pdf');
      outputPicker.onChooseFolder();
      actionBar.onAction();

      expect(outputFileName, 'result.pdf');
      expect(choseFolder, isTrue);
      expect(converted, isTrue);
    });
  });
}
