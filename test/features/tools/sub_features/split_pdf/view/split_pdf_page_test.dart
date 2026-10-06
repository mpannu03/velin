import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/features/tools/sub_features/split_pdf/split_pdf.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../../../helpers/helpers.dart';

class MockSplitPdfCubit extends MockCubit<SplitPdfState>
    implements SplitPdfCubit {}

void main() {
  late MockSplitPdfCubit cubit;

  setUp(() {
    cubit = MockSplitPdfCubit();

    getIt.registerFactoryParam<SplitPdfCubit, AppLocalizations, void>(
      (l10n, _) => cubit,
    );
  });

  tearDown(() {
    getIt.reset();
  });

  group('SplitPdfPage', () {
    testWidgets('renders the split pdf view', (tester) async {
      when(() => cubit.state).thenReturn(const SplitPdfState());

      await pumpApp(tester, const SplitPdfPage());

      expect(find.byType(SplitPdfView), findsOneWidget);
    });
  });
}
