import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/sub_features/sub_features.dart';
import 'package:velin/features/tools/widgets/widgets.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('PdfToImageDesktopLayout', () {
    late AppLocalizations l10n;

    setUp(() {
      l10n = lookupAppLocalizations(const Locale('en'));
    });

    PdfToImageViewModel createViewModel({
      String? inputFilePath,
      PdfToImagePageScope scope = PdfToImagePageScope.allPages,
      String selection = '',
      PdfImageFormat format = PdfImageFormat.png,
      PdfImageColorMode colorMode = PdfImageColorMode.color,
      int dpi = 150,
      int quality = 90,
      bool supportsQuality = false,
      String? outputDirectory,
      bool isSubmitting = false,
      bool canConvert = false,
      VoidCallback? onPickFile,
      ValueChanged<PdfToImagePageScope>? onScopeChanged,
      ValueChanged<String>? onSelectionChanged,
      ValueChanged<PdfImageFormat>? onFormatChanged,
      ValueChanged<PdfImageColorMode>? onColorModeChanged,
      ValueChanged<int>? onDpiChanged,
      ValueChanged<int>? onQualityChanged,
      VoidCallback? onChooseOutputFolder,
      VoidCallback? onConvert,
      VoidCallback? onBack,
    }) {
      return PdfToImageViewModel(
        inputFilePath: inputFilePath,
        scope: scope,
        selection: selection,
        format: format,
        colorMode: colorMode,
        dpi: dpi,
        quality: quality,
        supportsQuality: supportsQuality,
        outputDirectory: outputDirectory,
        isSubmitting: isSubmitting,
        canConvert: canConvert,
        onPickFile: onPickFile ?? () {},
        onScopeChanged: onScopeChanged ?? (_) {},
        onSelectionChanged: onSelectionChanged ?? (_) {},
        onFormatChanged: onFormatChanged ?? (_) {},
        onColorModeChanged: onColorModeChanged ?? (_) {},
        onDpiChanged: onDpiChanged ?? (_) {},
        onQualityChanged: onQualityChanged ?? (_) {},
        onChooseOutputFolder: onChooseOutputFolder ?? () {},
        onConvert: onConvert ?? () {},
        onBack: onBack ?? () {},
      );
    }

    testWidgets('renders title and description', (tester) async {
      final viewModel = createViewModel();

      await pumpApp(tester, PdfToImageDesktopLayout(viewModel: viewModel));

      expect(find.text(l10n.toolsPdfToImage), findsOneWidget);
      expect(find.text(l10n.toolsPdfToImageIntro), findsOneWidget);
    });

    testWidgets('always renders the source section', (tester) async {
      final viewModel = createViewModel();

      await pumpApp(tester, PdfToImageDesktopLayout(viewModel: viewModel));

      expect(find.text(l10n.toolsPdfToImageSourceSectionTitle), findsOneWidget);
      expect(find.byType(SingleFilePicker), findsOneWidget);
    });

    testWidgets('hides configuration sections when no input file is selected', (
      tester,
    ) async {
      final viewModel = createViewModel();

      await pumpApp(tester, PdfToImageDesktopLayout(viewModel: viewModel));

      expect(find.text(l10n.toolsPdfToImageFormatSectionTitle), findsNothing);
      expect(find.text(l10n.toolsPdfToImageColorSectionTitle), findsNothing);
      expect(
        find.text(l10n.toolsPdfToImageResolutionSectionTitle),
        findsNothing,
      );
      expect(find.text(l10n.toolsPdfToImagePagesSectionTitle), findsNothing);
      expect(find.byType(OutputFilePicker), findsNothing);
      expect(find.byType(ToolActionBar), findsNothing);
    });

    testWidgets('renders configuration sections when input file is selected', (
      tester,
    ) async {
      final viewModel = createViewModel(inputFilePath: '/documents/input.pdf');

      await pumpApp(tester, PdfToImageDesktopLayout(viewModel: viewModel));

      expect(find.text(l10n.toolsPdfToImageFormatSectionTitle), findsOneWidget);
      expect(find.text(l10n.toolsPdfToImageColorSectionTitle), findsOneWidget);
      expect(
        find.text(l10n.toolsPdfToImageResolutionSectionTitle),
        findsOneWidget,
      );
      expect(find.text(l10n.toolsPdfToImagePagesSectionTitle), findsOneWidget);
      expect(find.byType(OutputFilePicker), findsOneWidget);
      expect(find.byType(ToolActionBar), findsOneWidget);
    });

    testWidgets('treats a whitespace-only input path as no input file', (
      tester,
    ) async {
      final viewModel = createViewModel(inputFilePath: '   ');

      await pumpApp(tester, PdfToImageDesktopLayout(viewModel: viewModel));

      expect(find.text(l10n.toolsPdfToImageFormatSectionTitle), findsNothing);
      expect(find.byType(OutputFilePicker), findsNothing);
      expect(find.byType(ToolActionBar), findsNothing);
    });

    testWidgets('passes input file to source picker', (tester) async {
      final viewModel = createViewModel(inputFilePath: '/documents/input.pdf');

      await pumpApp(tester, PdfToImageDesktopLayout(viewModel: viewModel));

      final picker = tester.widget<SingleFilePicker>(
        find.byType(SingleFilePicker),
      );

      expect(picker.filePath, '/documents/input.pdf');
    });

    testWidgets('passes format to FormatSelector', (tester) async {
      final viewModel = createViewModel(
        inputFilePath: '/documents/input.pdf',
        format: PdfImageFormat.jpeg,
      );

      await pumpApp(tester, PdfToImageDesktopLayout(viewModel: viewModel));

      final selector = tester.widget<FormatSelector>(
        find.byType(FormatSelector),
      );

      expect(selector.format, PdfImageFormat.jpeg);
    });

    testWidgets('passes color mode to ColorModeSelector', (tester) async {
      final viewModel = createViewModel(
        inputFilePath: '/documents/input.pdf',
        colorMode: PdfImageColorMode.grayscale,
      );

      await pumpApp(tester, PdfToImageDesktopLayout(viewModel: viewModel));

      final selector = tester.widget<ColorModeSelector>(
        find.byType(ColorModeSelector),
      );

      expect(selector.colorMode, PdfImageColorMode.grayscale);
    });

    testWidgets('passes resolution values to ResolutionEditor', (tester) async {
      final viewModel = createViewModel(
        inputFilePath: '/documents/input.pdf',
        dpi: 300,
        quality: 75,
        supportsQuality: true,
      );

      await pumpApp(tester, PdfToImageDesktopLayout(viewModel: viewModel));

      final editor = tester.widget<ResolutionEditor>(
        find.byType(ResolutionEditor),
      );

      expect(editor.dpi, 300);
      expect(editor.quality, 75);
      expect(editor.supportsQuality, isTrue);
    });

    testWidgets('passes page configuration to PageScopeEditor', (tester) async {
      final viewModel = createViewModel(
        inputFilePath: '/documents/input.pdf',
        scope: PdfToImagePageScope.selectedPages,
        selection: '1-5, last',
      );

      await pumpApp(tester, PdfToImageDesktopLayout(viewModel: viewModel));

      final editor = tester.widget<PageScopeEditor<PdfToImagePageScope>>(
        find.byType(PageScopeEditor<PdfToImagePageScope>),
      );

      expect(editor.scope, PdfToImagePageScope.selectedPages);
      expect(editor.selection, '1-5, last');
      expect(editor.requiresSelection, isTrue);
    });

    testWidgets('passes output directory to OutputFilePicker', (tester) async {
      final viewModel = createViewModel(
        inputFilePath: '/documents/input.pdf',
        outputDirectory: '/documents/output',
      );

      await pumpApp(tester, PdfToImageDesktopLayout(viewModel: viewModel));

      final picker = tester.widget<OutputFilePicker>(
        find.byType(OutputFilePicker),
      );

      expect(picker.directoryPath, '/documents/output');
      expect(picker.fileName, '');
      expect(picker.showFileName, isFalse);
    });

    testWidgets('passes action state to ToolActionBar', (tester) async {
      final viewModel = createViewModel(
        inputFilePath: '/documents/input.pdf',
        isSubmitting: true,
        canConvert: false,
      );

      await pumpApp(tester, PdfToImageDesktopLayout(viewModel: viewModel));

      final actionBar = tester.widget<ToolActionBar>(
        find.byType(ToolActionBar),
      );

      expect(actionBar.isSubmitting, isTrue);
      expect(actionBar.canAction, isFalse);
      expect(actionBar.submittingText, l10n.toolsPdfToImageSubmitting);
      expect(actionBar.label, l10n.toolsPdfToImageButton);
    });

    testWidgets('forwards source picker callback', (tester) async {
      var called = false;

      final viewModel = createViewModel(
        onPickFile: () {
          called = true;
        },
      );

      await pumpApp(tester, PdfToImageDesktopLayout(viewModel: viewModel));

      final picker = tester.widget<SingleFilePicker>(
        find.byType(SingleFilePicker),
      );

      picker.onPickFile();

      expect(called, isTrue);
    });

    testWidgets('forwards output folder callback', (tester) async {
      var called = false;

      final viewModel = createViewModel(
        inputFilePath: '/documents/input.pdf',
        onChooseOutputFolder: () {
          called = true;
        },
      );

      await pumpApp(tester, PdfToImageDesktopLayout(viewModel: viewModel));

      final picker = tester.widget<OutputFilePicker>(
        find.byType(OutputFilePicker),
      );

      picker.onChooseFolder();

      expect(called, isTrue);
    });

    testWidgets('forwards convert callback', (tester) async {
      var called = false;

      final viewModel = createViewModel(
        inputFilePath: '/documents/input.pdf',
        canConvert: true,
        onConvert: () {
          called = true;
        },
      );

      await pumpApp(tester, PdfToImageDesktopLayout(viewModel: viewModel));

      final actionBar = tester.widget<ToolActionBar>(
        find.byType(ToolActionBar),
      );

      actionBar.onAction();

      expect(called, isTrue);
    });

    testWidgets('forwards back callback to ToolScaffold', (tester) async {
      var called = false;

      final viewModel = createViewModel(
        onBack: () {
          called = true;
        },
      );

      await pumpApp(tester, PdfToImageDesktopLayout(viewModel: viewModel));

      final scaffold = tester.widget<ToolScaffold>(find.byType(ToolScaffold));

      scaffold.onBack?.call();

      expect(called, isTrue);
    });
  });
}
