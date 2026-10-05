import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../../../helpers/helpers.dart';

class MockAddWatermarkCubit extends MockCubit<AddWatermarkState>
    implements AddWatermarkCubit {}

void main() {
  late MockAddWatermarkCubit cubit;

  setUpAll(() {
    registerFallbackValue(WatermarkType.text);
    registerFallbackValue(WatermarkPosition.center);
    registerFallbackValue(WatermarkLayer.foreground);
    registerFallbackValue(WatermarkPageScope.allPages);
  });

  setUp(() {
    cubit = MockAddWatermarkCubit();

    getIt.registerFactoryParam<AddWatermarkCubit, AppLocalizations, void>(
      (l10n, _) => cubit,
    );
  });

  tearDown(() async {
    if (getIt.isRegistered<AddWatermarkCubit>()) {
      await getIt.unregister<AddWatermarkCubit>();
    }
  });

  AddWatermarkState buildState({
    String? inputFilePath = '/input/source.pdf',
    String outputFileName = 'watermarked.pdf',
    String? outputDirectory = '/output',
    WatermarkType type = WatermarkType.text,
    String text = 'Confidential',
    String? imageFilePath,
    String? fontName,
    double fontSize = 24,
    String colorHex = '#000000',
    double opacity = 0.5,
    double rotation = 0,
    WatermarkPosition position = WatermarkPosition.center,
    double xOffset = 0,
    double yOffset = 0,
    double imageWidthPercent = 50,
    WatermarkLayer layer = WatermarkLayer.foreground,
    WatermarkPageScope scope = WatermarkPageScope.allPages,
    String selection = '',
    bool isSubmitting = false,
  }) {
    return AddWatermarkState(
      inputFilePath: inputFilePath,
      outputFileName: outputFileName,
      outputDirectory: outputDirectory,
      type: type,
      text: text,
      imageFilePath: imageFilePath,
      fontName: fontName,
      fontSize: fontSize,
      colorHex: colorHex,
      opacity: opacity,
      rotation: rotation,
      position: position,
      xOffset: xOffset,
      yOffset: yOffset,
      imageWidthPercent: imageWidthPercent,
      layer: layer,
      scope: scope,
      selection: selection,
      isSubmitting: isSubmitting,
    );
  }

  testWidgets('provides cubit and renders AddWatermarkView', (tester) async {
    when(() => cubit.state).thenReturn(buildState());
    whenListen(
      cubit,
      const Stream<AddWatermarkState>.empty(),
      initialState: buildState(),
    );

    await pumpApp(tester, const AddWatermarkPage());

    expect(find.byType(AddWatermarkView), findsOneWidget);
  });

  testWidgets('maps state values to the AddWatermarkViewModel', (tester) async {
    final state = buildState(
      inputFilePath: '/documents/input.pdf',
      outputFileName: 'result.pdf',
      outputDirectory: '/documents/output',
      type: WatermarkType.image,
      text: 'Confidential',
      imageFilePath: '/documents/logo.png',
      fontName: 'Helvetica',
      fontSize: 36,
      colorHex: '#FF0000',
      opacity: 0.75,
      rotation: 45,
      position: WatermarkPosition.bottomRight,
      xOffset: 12,
      yOffset: 18,
      imageWidthPercent: 65,
      layer: WatermarkLayer.background,
      scope: WatermarkPageScope.selectedPages,
      selection: '1-3',
      isSubmitting: true,
    );

    when(() => cubit.state).thenReturn(state);
    whenListen(
      cubit,
      const Stream<AddWatermarkState>.empty(),
      initialState: state,
    );

    await pumpApp(tester, const AddWatermarkPage());

    final view = tester.widget<AddWatermarkView>(find.byType(AddWatermarkView));

    expect(view.viewModel.inputFilePath, '/documents/input.pdf');
    expect(view.viewModel.outputFileName, 'result.pdf');
    expect(view.viewModel.outputDirectory, '/documents/output');
    expect(view.viewModel.type, WatermarkType.image);
    expect(view.viewModel.text, 'Confidential');
    expect(view.viewModel.imageFilePath, '/documents/logo.png');
    expect(view.viewModel.fontName, 'Helvetica');
    expect(view.viewModel.fontSize, 36);
    expect(view.viewModel.colorHex, '#FF0000');
    expect(view.viewModel.opacity, 0.75);
    expect(view.viewModel.rotation, 45);
    expect(view.viewModel.position, WatermarkPosition.bottomRight);
    expect(view.viewModel.xOffset, 12);
    expect(view.viewModel.yOffset, 18);
    expect(view.viewModel.imageWidthPercent, 65);
    expect(view.viewModel.layer, WatermarkLayer.background);
    expect(view.viewModel.scope, WatermarkPageScope.selectedPages);
    expect(view.viewModel.selection, '1-3');
    expect(view.viewModel.isSubmitting, true);
    expect(view.viewModel.canApplyWatermark, false);
  });

  testWidgets('wires view model actions to cubit methods', (tester) async {
    final state = buildState();

    when(() => cubit.state).thenReturn(state);
    when(() => cubit.pickFile()).thenAnswer((_) async {});
    when(() => cubit.pickOutputDirectory()).thenAnswer((_) async {});
    when(() => cubit.applyWatermark()).thenAnswer((_) async {});
    when(() => cubit.pickWatermarkImage()).thenAnswer((_) async {});
    when(() => cubit.clearWatermarkImage()).thenAnswer((_) async {});
    when(() => cubit.changeType(any())).thenAnswer((_) async {});
    when(() => cubit.updateText(any())).thenAnswer((_) async {});
    when(() => cubit.changeFontName(any())).thenAnswer((_) async {});
    when(() => cubit.changeFontSize(any())).thenAnswer((_) async {});
    when(() => cubit.changeColorHex(any())).thenAnswer((_) async {});
    when(() => cubit.changeOpacity(any())).thenAnswer((_) async {});
    when(() => cubit.changeRotation(any())).thenAnswer((_) async {});
    when(() => cubit.changePosition(any())).thenAnswer((_) async {});
    when(() => cubit.changeXOffset(any())).thenAnswer((_) async {});
    when(() => cubit.changeYOffset(any())).thenAnswer((_) async {});
    when(() => cubit.changeImageWidthPercent(any())).thenAnswer((_) async {});
    when(() => cubit.changeLayer(any())).thenAnswer((_) async {});
    when(() => cubit.changeScope(any())).thenAnswer((_) async {});
    when(() => cubit.updateSelection(any())).thenAnswer((_) async {});

    whenListen(
      cubit,
      const Stream<AddWatermarkState>.empty(),
      initialState: state,
    );

    await pumpApp(tester, const AddWatermarkPage());

    final view = tester.widget<AddWatermarkView>(find.byType(AddWatermarkView));

    view.viewModel.onPickFile();
    verify(() => cubit.pickFile()).called(1);

    view.viewModel.onPickWatermarkImage();
    verify(() => cubit.pickWatermarkImage()).called(1);

    view.viewModel.onClearWatermarkImage();
    verify(() => cubit.clearWatermarkImage()).called(1);

    view.viewModel.onTypeChanged(WatermarkType.image);
    verify(() => cubit.changeType(WatermarkType.image)).called(1);

    view.viewModel.onTextChanged('New text');
    verify(() => cubit.updateText('New text')).called(1);

    view.viewModel.onFontNameChanged('Helvetica');
    verify(() => cubit.changeFontName('Helvetica')).called(1);

    view.viewModel.onFontSizeChanged(36);
    verify(() => cubit.changeFontSize(36)).called(1);

    view.viewModel.onColorHexChanged('#FF0000');
    verify(() => cubit.changeColorHex('#FF0000')).called(1);

    view.viewModel.onOpacityChanged(0.75);
    verify(() => cubit.changeOpacity(0.75)).called(1);

    view.viewModel.onRotationChanged(45);
    verify(() => cubit.changeRotation(45)).called(1);

    view.viewModel.onPositionChanged(WatermarkPosition.bottomRight);
    verify(() => cubit.changePosition(WatermarkPosition.bottomRight)).called(1);

    view.viewModel.onXOffsetChanged(10);
    verify(() => cubit.changeXOffset(10)).called(1);

    view.viewModel.onYOffsetChanged(20);
    verify(() => cubit.changeYOffset(20)).called(1);

    view.viewModel.onImageWidthPercentChanged(60);
    verify(() => cubit.changeImageWidthPercent(60)).called(1);

    view.viewModel.onLayerChanged(WatermarkLayer.background);
    verify(() => cubit.changeLayer(WatermarkLayer.background)).called(1);

    view.viewModel.onScopeChanged(WatermarkPageScope.selectedPages);
    verify(() => cubit.changeScope(WatermarkPageScope.selectedPages)).called(1);

    view.viewModel.onSelectionChanged('1-5');
    verify(() => cubit.updateSelection('1-5')).called(1);

    view.viewModel.onOutputFileNameChanged('result.pdf');
    verify(() => cubit.updateOutputFileName('result.pdf')).called(1);

    view.viewModel.onChooseOutputFolder();
    verify(() => cubit.pickOutputDirectory()).called(1);

    view.viewModel.onApplyWatermark();
    verify(() => cubit.applyWatermark()).called(1);
  });
}
