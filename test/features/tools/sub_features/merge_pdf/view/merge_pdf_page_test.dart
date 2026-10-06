import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/features/tools/sub_features/merge_pdf/merge_pdf.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../../../helpers/helpers.dart';

class MockMergePdfCubit extends MockCubit<MergePdfState>
    implements MergePdfCubit {}

void main() {
  late MockMergePdfCubit cubit;

  setUp(() {
    cubit = MockMergePdfCubit();

    getIt.registerFactoryParam<MergePdfCubit, AppLocalizations, void>(
      (l10n, _) => cubit,
    );
  });

  tearDown(() {
    getIt.reset();
  });

  group('MergePdfPage', () {
    testWidgets('renders the merge PDF view', (tester) async {
      when(() => cubit.state).thenReturn(const MergePdfState());

      await pumpApp(tester, const MergePdfPage());

      expect(find.byType(MergePdfView), findsOneWidget);
    });
  });
}
