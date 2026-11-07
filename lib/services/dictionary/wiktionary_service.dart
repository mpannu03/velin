import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:velin/core/error/error.dart';
import 'package:velin/core/result/result.dart';

import 'dictionary.dart';

class WiktionaryService implements DictionaryService {
  WiktionaryService({required this._client});

  static const _baseUrl = 'https://en.wiktionary.org/api/rest_v1';

  static const _timeout = Duration(seconds: 10);

  /// Wikimedia asks API clients to identify themselves with a descriptive
  /// User-Agent including a way to reach the maintainer:
  /// https://meta.wikimedia.org/wiki/User-Agent_policy
  static const _userAgent = 'Velin/1.0 (https://github.com/mpannu03/velin)';

  final http.Client _client;

  @override
  Future<Result<DictionaryEntry>> lookup(String word) async {
    final normalizedWord = word.trim();

    if (normalizedWord.isEmpty) {
      return Failure(DictionaryEntryNotFoundFailure(normalizedWord));
    }

    final encodedWord = Uri.encodeComponent(normalizedWord);

    final uri = Uri.parse('$_baseUrl/page/definition/$encodedWord');

    final http.Response response;

    try {
      response = await _client
          .get(
            uri,
            headers: const {
              'Accept': 'application/json',
              'User-Agent': _userAgent,
            },
          )
          .timeout(_timeout);
    } catch (error, stackTrace) {
      return Failure(mapError(error, stackTrace));
    }

    if (response.statusCode == 404) {
      return Failure(DictionaryEntryNotFoundFailure(normalizedWord));
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return Failure(ServerFailure(statusCode: response.statusCode));
    }

    try {
      final json = jsonDecode(response.body);

      if (json is! Map<String, dynamic>) {
        return Failure(
          ServerFailure(
            statusCode: response.statusCode,
            cause: const FormatException('Expected a JSON object.'),
          ),
        );
      }

      return Success(_parseEntry(normalizedWord, json));
    } on FormatException catch (error, stackTrace) {
      return Failure(
        ServerFailure(
          statusCode: response.statusCode,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } catch (error, stackTrace) {
      return Failure(mapError(error, stackTrace));
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
                  'definitions': item['definitions'],
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
