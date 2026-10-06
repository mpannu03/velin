import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/core/di/injection.dart';

import 'package:velin/features/tools/sub_features/encrypt_pdf/encrypt_pdf.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../../../helpers/helpers.dart';

class MockEncryptPdfCubit extends MockCubit<EncryptPdfState>
    implements EncryptPdfCubit {}

void main() {
  late MockEncryptPdfCubit cubit;

  setUp(() {
    cubit = MockEncryptPdfCubit();

    getIt.registerFactoryParam<EncryptPdfCubit, AppLocalizations, void>(
      (l10n, _) => cubit,
    );
  });

  tearDown(() {
    getIt.reset();
  });

  group('EncryptPdfPage', () {
    testWidgets('renders the encrypt PDF view', (tester) async {
      when(() => cubit.state).thenReturn(const EncryptPdfState());

      await pumpApp(tester, const EncryptPdfPage());

      expect(find.byType(EncryptPdfView), findsOneWidget);
    });
  });
}
