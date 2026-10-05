import 'package:flutter_test/flutter_test.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('AddWatermarkDesktopLayout', () {
    testWidgets('always renders source section', (tester) async {
      final viewModel = AddWatermarkViewModel(
        inputFilePath: null,
        type: WatermarkType.text,
        text: 'Draft',
        imageFilePath: null,
        fontName: null,
        fontSize: 24,
        colorHex: '#000000',
        imageWidthPercent: 50,
        opacity: 0.5,
        rotation: 0,
        position: WatermarkPosition.center,
        xOffset: 0,
        yOffset: 0,
        layer: WatermarkLayer.foreground,
        scope: WatermarkPageScope.allPages,
        selection: '',
        outputFileName: 'watermarked.pdf',
        outputDirectory: '/output',
        isSubmitting: false,
        canApplyWatermark: false,
        onBack: () {},
        onPickFile: () {},
        onTypeChanged: (_) {},
        onTextChanged: (_) {},
        onFontNameChanged: (_) {},
        onFontSizeChanged: (_) {},
        onColorHexChanged: (_) {},
        onPickWatermarkImage: () {},
        onClearWatermarkImage: () {},
        onImageWidthPercentChanged: (_) {},
        onOpacityChanged: (_) {},
        onRotationChanged: (_) {},
        onPositionChanged: (_) {},
        onXOffsetChanged: (_) {},
        onYOffsetChanged: (_) {},
        onLayerChanged: (_) {},
        onScopeChanged: (_) {},
        onSelectionChanged: (_) {},
        onOutputFileNameChanged: (_) {},
        onChooseOutputFolder: () {},
        onApplyWatermark: () {},
      );

      await pumpApp(tester, AddWatermarkDesktopLayout(viewModel: viewModel));

      final context = tester.element(find.byType(AddWatermarkDesktopLayout));
      final l10n = context.l10n;

      expect(find.byType(SingleFilePicker), findsOneWidget);
      expect(find.text(l10n.toolsWatermarkSourceSectionTitle), findsOneWidget);
    });

    testWidgets('hides remaining sections when there is no input file', (
      tester,
    ) async {
      final viewModel = AddWatermarkViewModel(
        inputFilePath: null,
        type: WatermarkType.text,
        text: 'Draft',
        imageFilePath: null,
        fontName: null,
        fontSize: 24,
        colorHex: '#000000',
        imageWidthPercent: 50,
        opacity: 0.5,
        rotation: 0,
        position: WatermarkPosition.center,
        xOffset: 0,
        yOffset: 0,
        layer: WatermarkLayer.foreground,
        scope: WatermarkPageScope.allPages,
        selection: '',
        outputFileName: 'watermarked.pdf',
        outputDirectory: '/output',
        isSubmitting: false,
        canApplyWatermark: false,
        onBack: () {},
        onPickFile: () {},
        onTypeChanged: (_) {},
        onTextChanged: (_) {},
        onFontNameChanged: (_) {},
        onFontSizeChanged: (_) {},
        onColorHexChanged: (_) {},
        onPickWatermarkImage: () {},
        onClearWatermarkImage: () {},
        onImageWidthPercentChanged: (_) {},
        onOpacityChanged: (_) {},
        onRotationChanged: (_) {},
        onPositionChanged: (_) {},
        onXOffsetChanged: (_) {},
        onYOffsetChanged: (_) {},
        onLayerChanged: (_) {},
        onScopeChanged: (_) {},
        onSelectionChanged: (_) {},
        onOutputFileNameChanged: (_) {},
        onChooseOutputFolder: () {},
        onApplyWatermark: () {},
      );

      await pumpApp(tester, AddWatermarkDesktopLayout(viewModel: viewModel));

      expect(find.byType(WatermarkContentEditor), findsNothing);
      expect(find.byType(StyleEditor), findsNothing);
      expect(find.byType(PageScopeEditor<WatermarkPageScope>), findsNothing);
      expect(find.byType(OutputFilePicker), findsNothing);
      expect(find.byType(ToolActionBar), findsNothing);
    });

    testWidgets('treats whitespace-only input path as missing', (tester) async {
      final viewModel = AddWatermarkViewModel(
        inputFilePath: '   ',
        type: WatermarkType.text,
        text: 'Draft',
        imageFilePath: null,
        fontName: null,
        fontSize: 24,
        colorHex: '#000000',
        imageWidthPercent: 50,
        opacity: 0.5,
        rotation: 0,
        position: WatermarkPosition.center,
        xOffset: 0,
        yOffset: 0,
        layer: WatermarkLayer.foreground,
        scope: WatermarkPageScope.allPages,
        selection: '',
        outputFileName: 'watermarked.pdf',
        outputDirectory: '/output',
        isSubmitting: false,
        canApplyWatermark: false,
        onBack: () {},
        onPickFile: () {},
        onTypeChanged: (_) {},
        onTextChanged: (_) {},
        onFontNameChanged: (_) {},
        onFontSizeChanged: (_) {},
        onColorHexChanged: (_) {},
        onPickWatermarkImage: () {},
        onClearWatermarkImage: () {},
        onImageWidthPercentChanged: (_) {},
        onOpacityChanged: (_) {},
        onRotationChanged: (_) {},
        onPositionChanged: (_) {},
        onXOffsetChanged: (_) {},
        onYOffsetChanged: (_) {},
        onLayerChanged: (_) {},
        onScopeChanged: (_) {},
        onSelectionChanged: (_) {},
        onOutputFileNameChanged: (_) {},
        onChooseOutputFolder: () {},
        onApplyWatermark: () {},
      );

      await pumpApp(tester, AddWatermarkDesktopLayout(viewModel: viewModel));

      expect(find.byType(WatermarkContentEditor), findsNothing);
      expect(find.byType(StyleEditor), findsNothing);
      expect(find.byType(OutputFilePicker), findsNothing);
      expect(find.byType(ToolActionBar), findsNothing);
    });

    testWidgets('renders all editing sections when input file exists', (
      tester,
    ) async {
      final viewModel = AddWatermarkViewModel(
        inputFilePath: '/input/source.pdf',
        type: WatermarkType.text,
        text: 'Draft',
        imageFilePath: null,
        fontName: null,
        fontSize: 24,
        colorHex: '#FF0000',
        imageWidthPercent: 50,
        opacity: 0.5,
        rotation: 15,
        position: WatermarkPosition.center,
        xOffset: 10,
        yOffset: 20,
        layer: WatermarkLayer.foreground,
        scope: WatermarkPageScope.allPages,
        selection: '',
        outputFileName: 'watermarked.pdf',
        outputDirectory: '/output',
        isSubmitting: false,
        canApplyWatermark: true,
        onBack: () {},
        onPickFile: () {},
        onTypeChanged: (_) {},
        onTextChanged: (_) {},
        onFontNameChanged: (_) {},
        onFontSizeChanged: (_) {},
        onColorHexChanged: (_) {},
        onPickWatermarkImage: () {},
        onClearWatermarkImage: () {},
        onImageWidthPercentChanged: (_) {},
        onOpacityChanged: (_) {},
        onRotationChanged: (_) {},
        onPositionChanged: (_) {},
        onXOffsetChanged: (_) {},
        onYOffsetChanged: (_) {},
        onLayerChanged: (_) {},
        onScopeChanged: (_) {},
        onSelectionChanged: (_) {},
        onOutputFileNameChanged: (_) {},
        onChooseOutputFolder: () {},
        onApplyWatermark: () {},
      );

      await pumpApp(tester, AddWatermarkDesktopLayout(viewModel: viewModel));

      expect(find.byType(SingleFilePicker), findsOneWidget);
      expect(find.byType(WatermarkContentEditor), findsOneWidget);
      expect(find.byType(StyleEditor), findsOneWidget);
      expect(find.byType(PageScopeEditor<WatermarkPageScope>), findsOneWidget);
      expect(find.byType(OutputFilePicker), findsOneWidget);
      expect(find.byType(ToolActionBar), findsOneWidget);
    });

    testWidgets('forwards view model values to child editors', (tester) async {
      final viewModel = AddWatermarkViewModel(
        inputFilePath: '/input/source.pdf',
        type: WatermarkType.image,
        text: 'Confidential',
        imageFilePath: '/input/logo.png',
        fontName: 'Helvetica',
        fontSize: 36,
        colorHex: '#00FF00',
        imageWidthPercent: 65,
        opacity: 0.75,
        rotation: 45,
        position: WatermarkPosition.bottomRight,
        xOffset: 12,
        yOffset: 18,
        layer: WatermarkLayer.background,
        scope: WatermarkPageScope.selectedPages,
        selection: '1-3',
        outputFileName: 'result.pdf',
        outputDirectory: '/output',
        isSubmitting: true,
        canApplyWatermark: false,
        onBack: () {},
        onPickFile: () {},
        onTypeChanged: (_) {},
        onTextChanged: (_) {},
        onFontNameChanged: (_) {},
        onFontSizeChanged: (_) {},
        onColorHexChanged: (_) {},
        onPickWatermarkImage: () {},
        onClearWatermarkImage: () {},
        onImageWidthPercentChanged: (_) {},
        onOpacityChanged: (_) {},
        onRotationChanged: (_) {},
        onPositionChanged: (_) {},
        onXOffsetChanged: (_) {},
        onYOffsetChanged: (_) {},
        onLayerChanged: (_) {},
        onScopeChanged: (_) {},
        onSelectionChanged: (_) {},
        onOutputFileNameChanged: (_) {},
        onChooseOutputFolder: () {},
        onApplyWatermark: () {},
      );

      await pumpApp(tester, AddWatermarkDesktopLayout(viewModel: viewModel));

      final contentEditor = tester.widget<WatermarkContentEditor>(
        find.byType(WatermarkContentEditor),
      );

      expect(contentEditor.type, WatermarkType.image);
      expect(contentEditor.text, 'Confidential');
      expect(contentEditor.imageFilePath, '/input/logo.png');
      expect(contentEditor.fontName, 'Helvetica');
      expect(contentEditor.fontSize, 36);
      expect(contentEditor.colorHex, '#00FF00');
      expect(contentEditor.imageWidthPercent, 65);

      final styleEditor = tester.widget<StyleEditor>(find.byType(StyleEditor));

      expect(styleEditor.opacity, 0.75);
      expect(styleEditor.rotation, 45);
      expect(styleEditor.position, WatermarkPosition.bottomRight);
      expect(styleEditor.xOffset, 12);
      expect(styleEditor.yOffset, 18);
      expect(styleEditor.layer, WatermarkLayer.background);

      final pageScopeEditor = tester
          .widget<PageScopeEditor<WatermarkPageScope>>(
            find.byType(PageScopeEditor<WatermarkPageScope>),
          );

      expect(pageScopeEditor.scope, WatermarkPageScope.selectedPages);
      expect(pageScopeEditor.selection, '1-3');
    });
  });
}
