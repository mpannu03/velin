import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:velin/core/document/engine/engine.dart';
import 'package:velin/engine/engine.dart';

class MockPdfTextSearcher extends Mock implements PdfTextSearcher {}

void main() {
  late MockPdfTextSearcher textSearcher;
  late PdfTextSearchCapability capability;

  setUp(() {
    textSearcher = MockPdfTextSearcher();
    capability = PdfTextSearchCapability(textSearcher);
  });

  test('clears the text search', () async {
    await capability.clear();

    verify(() => textSearcher.resetTextSearch()).called(1);
  });

  test('selects a search result', () async {
    const result = TextSearchResult(
      index: 2,
      pageNumber: 3,
      text: 'hello',
    );

    when(
      () => textSearcher.goToMatchOfIndex(2),
    ).thenAnswer((_) async => 1);

    await capability.selectResult(result);

    verify(
      () => textSearcher.goToMatchOfIndex(2),
    ).called(1);
  });

  test('starts a text search with the provided query and case sensitivity', () {
    late void Function() listener;

    when(() => textSearcher.addListener(any())).thenAnswer((invocation) {
      listener = invocation.positionalArguments.first as void Function();
      return () {};
    });

    when(() => textSearcher.matches).thenReturn([]);
    when(() => textSearcher.isSearching).thenReturn(false);

    final stream = capability.search('hello', true);

    expect(stream, isA<Stream<List<TextSearchResult>>>());

    verify(
      () => textSearcher.resetTextSearch(),
    ).called(1);

    verify(
      () => textSearcher.startTextSearch(
        'hello',
        caseInsensitive: true,
      ),
    ).called(1);

    listener();
  });

  test('cancels the search when the stream subscription is cancelled',
      () async {
    late void Function() listener;

    when(() => textSearcher.isSearching).thenReturn(true);

    when(() => textSearcher.addListener(any())).thenAnswer((invocation) {
      listener = invocation.positionalArguments.first as void Function();
      return () {};
    });

    final stream = capability.search('hello', false);

    final subscription = stream.listen((_) {});

    await subscription.cancel();

    verify(
      () => textSearcher.removeListener(listener),
    ).called(1);

    verify(
      () => textSearcher.resetTextSearch(),
    ).called(greaterThanOrEqualTo(1));
  });
}