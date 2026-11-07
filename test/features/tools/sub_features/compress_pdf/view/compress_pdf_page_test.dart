import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/features/tools/bloc/tool_task_runner.dart';
import 'package:velin/features/tools/sub_features/compress_pdf/compress_pdf.dart';

import '../../../../../helpers/helpers.dart';

class MockCompressPdfCubit extends MockCubit<CompressPdfState>
    implements CompressPdfCubit {}

void main() {
  late MockCompressPdfCubit cubit;

  setUp(() {
    cubit = MockCompressPdfCubit();
    when(() => cubit.task).thenReturn(ToolTaskHandle());

    getIt.registerFactory<CompressPdfCubit>(() => cubit);
  });

  tearDown(() async {
    getIt.reset();
  });

  group('CompressPdfPage', () {
    testWidgets('renders the compress PDF view', (tester) async {
      when(() => cubit.state).thenReturn(CompressPdfState());

      await pumpApp(tester, const CompressPdfPage());

      expect(find.byType(CompressPdfView), findsOneWidget);
    });
  });
}
