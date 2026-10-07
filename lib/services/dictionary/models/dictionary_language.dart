import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'models.dart';

class DictionaryLanguage {
  const DictionaryLanguage({
    required this.code,
    required this.name,
    required this.partsOfSpeech,
  });

  /// ISO language code returned by Wiktionary, e.g. `en`.
  final String code;

  /// Human-readable language name, e.g. `English`.
  final String name;

  final List<DictionaryPartOfSpeech> partsOfSpeech;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'code': code,
      'name': name,
      'partsOfSpeech': partsOfSpeech.map((x) => x.toMap()).toList(),
    };
  }

  factory DictionaryLanguage.fromMap(Map<String, dynamic> map) {
    return DictionaryLanguage(
      code: map['code'] as String,
      name: map['name'] as String,
      partsOfSpeech: List<DictionaryPartOfSpeech>.from(
        (map['partsOfSpeech'] as List<int>).map<DictionaryPartOfSpeech>(
          (x) => DictionaryPartOfSpeech.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory DictionaryLanguage.fromJson(String source) =>
      DictionaryLanguage.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'DictionaryLanguage(code: $code, name: $name, partsOfSpeech: $partsOfSpeech)';

  @override
  bool operator ==(covariant DictionaryLanguage other) {
    if (identical(this, other)) return true;

    return other.code == code &&
        other.name == name &&
        listEquals(other.partsOfSpeech, partsOfSpeech);
  }

  @override
  int get hashCode => code.hashCode ^ name.hashCode ^ partsOfSpeech.hashCode;
}
