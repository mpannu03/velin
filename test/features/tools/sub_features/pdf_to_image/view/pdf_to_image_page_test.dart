import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/features/tools/sub_features/pdf_to_image/pdf_to_image.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../../../helpers/helpers.dart';

class MockPdfToImageCubit extends MockCubit<PdfToImageState>
    implements PdfToImageCubit {}

void main() {
  late MockPdfToImageCubit cubit;

  setUp(() {
    cubit = MockPdfToImageCubit();

    getIt.registerFactoryParam<PdfToImageCubit, AppLocalizations, void>(
      (l10n, _) => cubit,
    );
  });

  tearDown(() {
    getIt.reset();
  });

  group('PdfToImagePage', () {
    testWidgets('renders the pdf to image view', (tester) async {
      when(() => cubit.state).thenReturn(const PdfToImageState());

      await pumpApp(tester, const PdfToImagePage());

      expect(find.byType(PdfToImageView), findsOneWidget);
    });
  });
}
