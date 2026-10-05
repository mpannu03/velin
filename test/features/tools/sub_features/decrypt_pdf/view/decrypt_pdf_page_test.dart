import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/core/di/injection.dart';

import 'package:velin/features/tools/sub_features/decrypt_pdf/decrypt_pdf.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../../../helpers/helpers.dart';

class MockDecryptPdfCubit extends MockCubit<DecryptPdfState>
    implements DecryptPdfCubit {}

void main() {
  late MockDecryptPdfCubit cubit;

  setUp(() {
    cubit = MockDecryptPdfCubit();

    getIt.registerFactoryParam<DecryptPdfCubit, AppLocalizations, void>(
      (l10n, _) => cubit,
    );
  });

  tearDown(() {
    getIt.reset();
  });

  group('DecryptPdfPage', () {
    testWidgets('renders the decrypt PDF view', (tester) async {
      when(() => cubit.state).thenReturn(const DecryptPdfState());

      await pumpApp(tester, const DecryptPdfPage());

      expect(find.byType(DecryptPdfView), findsOneWidget);
    });
  });
}
