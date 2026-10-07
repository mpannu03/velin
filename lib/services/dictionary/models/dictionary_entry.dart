// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'models.dart';

class DictionaryEntry {
  const DictionaryEntry({required this.word, required this.languages});

  final String word;
  final List<DictionaryLanguage> languages;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'word': word,
      'languages': languages.map((x) => x.toMap()).toList(),
    };
  }

  factory DictionaryEntry.fromMap(Map<String, dynamic> map) {
    return DictionaryEntry(
      word: map['word'] as String,
      languages: List<DictionaryLanguage>.from(
        (map['languages'] as List<int>).map<DictionaryLanguage>(
          (x) => DictionaryLanguage.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory DictionaryEntry.fromJson(String source) =>
      DictionaryEntry.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'DictionaryEntry(word: $word, languages: $languages)';

  @override
  bool operator ==(covariant DictionaryEntry other) {
    if (identical(this, other)) return true;

    return other.word == word && listEquals(other.languages, languages);
  }

  @override
  int get hashCode => word.hashCode ^ languages.hashCode;
}
