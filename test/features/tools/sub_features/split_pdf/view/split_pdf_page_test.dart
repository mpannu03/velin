import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/features/tools/bloc/tool_task_runner.dart';
import 'package:velin/features/tools/sub_features/split_pdf/split_pdf.dart';

import '../../../../../helpers/helpers.dart';

class MockSplitPdfCubit extends MockCubit<SplitPdfState>
    implements SplitPdfCubit {}

void main() {
  late MockSplitPdfCubit cubit;

  setUp(() {
    cubit = MockSplitPdfCubit();
    when(() => cubit.task).thenReturn(ToolTaskHandle());

    getIt.registerFactory<SplitPdfCubit>(() => cubit);
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
