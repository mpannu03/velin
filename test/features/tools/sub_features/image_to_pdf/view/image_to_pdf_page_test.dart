import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/features/tools/sub_features/image_to_pdf/image_to_pdf.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../../../helpers/helpers.dart';

class MockImageToPdfCubit extends MockCubit<ImageToPdfState>
    implements ImageToPdfCubit {}

void main() {
  late MockImageToPdfCubit cubit;

  setUp(() {
    cubit = MockImageToPdfCubit();

    getIt.registerFactoryParam<ImageToPdfCubit, AppLocalizations, void>(
      (l10n, _) => cubit,
    );
  });

  tearDown(() {
    getIt.reset();
  });

  group('ImageToPdfPage', () {
    testWidgets('renders the image to PDF view', (tester) async {
      when(() => cubit.state).thenReturn(const ImageToPdfState());

      await pumpApp(tester, const ImageToPdfPage());

      expect(find.byType(ImageToPdfView), findsOneWidget);
    });
  });
}
