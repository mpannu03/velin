import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/core/di/injection.dart';

import 'package:velin/features/tools/sub_features/extract_pdf/extract_pdf.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../../../helpers/helpers.dart';

class MockExtractPdfCubit extends MockCubit<ExtractPdfState>
    implements ExtractPdfCubit {}

void main() {
  late MockExtractPdfCubit cubit;

  setUp(() {
    cubit = MockExtractPdfCubit();

    getIt.registerFactoryParam<ExtractPdfCubit, AppLocalizations, void>(
      (l10n, _) => cubit,
    );
  });

  tearDown(() {
    getIt.reset();
  });

  group('ExtractPdfPage', () {
    testWidgets('renders the extract PDF view', (tester) async {
      when(() => cubit.state).thenReturn(const ExtractPdfState());

      await pumpApp(tester, const ExtractPdfPage());

      expect(find.byType(ExtractPdfView), findsOneWidget);
    });
  });
}
