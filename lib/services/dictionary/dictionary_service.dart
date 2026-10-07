import 'package:velin/core/result/result.dart';

import 'dictionary.dart';

abstract interface class DictionaryService {
  Future<Result<DictionaryEntry>> lookup(String word);
}
