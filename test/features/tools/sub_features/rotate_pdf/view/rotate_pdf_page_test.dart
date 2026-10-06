import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/features/tools/sub_features/rotate_pdf/rotate_pdf.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../../../helpers/helpers.dart';

class MockRotatePdfCubit extends MockCubit<RotatePdfState>
    implements RotatePdfCubit {}

void main() {
  late MockRotatePdfCubit cubit;

  setUp(() {
    cubit = MockRotatePdfCubit();

    getIt.registerFactoryParam<RotatePdfCubit, AppLocalizations, void>(
      (l10n, _) => cubit,
    );
  });

  tearDown(() {
    getIt.reset();
  });

  group('RotatePdfPage', () {
    testWidgets('renders the rotate pdf view', (tester) async {
      when(() => cubit.state).thenReturn(const RotatePdfState());

      await pumpApp(tester, const RotatePdfPage());

      expect(find.byType(RotatePdfView), findsOneWidget);
    });
  });
}
