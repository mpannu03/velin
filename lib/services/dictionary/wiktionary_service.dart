import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:velin/core/result/result.dart';

import 'dictionary.dart';

class WiktionaryService implements DictionaryService {
  WiktionaryService({required this._client});

  static const _baseUrl = 'https://en.wiktionary.org/api/rest_v1';

  final http.Client _client;

  @override
  Future<Result<DictionaryEntry>> lookup(String word) async {
    final normalizedWord = word.trim();

    if (normalizedWord.isEmpty) {
      return Failure<DictionaryEntry>(
        ArgumentError('Word cannot be empty.'),
        StackTrace.current,
      );
    }

    final encodedWord = Uri.encodeComponent(normalizedWord);

    final uri = Uri.parse('$_baseUrl/page/definition/$encodedWord');

    try {
      final response = await _client.get(
        uri,
        headers: const {'Accept': 'application/json'},
      );

      if (response.statusCode == 404) {
        return Failure<DictionaryEntry>(
          DictionaryNotFoundException(normalizedWord),
          StackTrace.current,
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return Failure<DictionaryEntry>(
          DictionaryHttpException(
            statusCode: response.statusCode,
            word: normalizedWord,
          ),
          StackTrace.current,
        );
      }

      final json = jsonDecode(response.body);

      if (json is! Map<String, dynamic>) {
        return Failure<DictionaryEntry>(
          const DictionaryResponseException('Unexpected response format.'),
          StackTrace.current,
        );
      }

      return Success(_parseEntry(normalizedWord, json));
    } catch (error, stackTrace) {
      return Failure<DictionaryEntry>(error, stackTrace);
    }
  }

  DictionaryEntry _parseEntry(String word, Map<String, dynamic> response) {
    final languages = response.entries
        .map((entry) {
          final items = entry.value;

          if (items is! List) {
            return null;
          }

          final maps = items
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList(growable: false);

          if (maps.isEmpty) {
            return null;
          }

          final language = maps.first['language'];

          final partsOfSpeech = maps
              .where(
                (item) =>
                    item['partOfSpeech'] is String &&
                    item['definitions'] is List,
              )
              .map(
                (item) => DictionaryPartOfSpeech.fromMap({
                  'name': item['partOfSpeech'],
                  'definitions': (item['definitions'] as List)
                      .whereType<Map>()
                      .map(
                        (definition) => DictionaryDefinition.fromMap(
                          Map<String, dynamic>.from(definition),
                        ),
                      )
                      .toList(growable: false),
                }),
              )
              .toList(growable: false);

          if (partsOfSpeech.isEmpty) {
            return null;
          }

          return DictionaryLanguage(
            code: entry.key,
            name: language is String ? language : entry.key,
            partsOfSpeech: partsOfSpeech,
          );
        })
        .whereType<DictionaryLanguage>()
        .toList(growable: false);

    return DictionaryEntry(word: word, languages: languages);
  }
}
