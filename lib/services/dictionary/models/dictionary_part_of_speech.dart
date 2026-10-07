// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'models.dart';

class DictionaryPartOfSpeech {
  const DictionaryPartOfSpeech({required this.name, required this.definitions});

  /// e.g. `Noun`, `Verb`, `Adjective`.
  final String name;

  final List<DictionaryDefinition> definitions;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'definitions': definitions.map((x) => x.toMap()).toList(),
    };
  }

  factory DictionaryPartOfSpeech.fromMap(Map<String, dynamic> map) {
    return DictionaryPartOfSpeech(
      name: map['name'] as String,
      definitions: List<DictionaryDefinition>.from(
        (map['definitions'] as List<int>).map<DictionaryDefinition>(
          (x) => DictionaryDefinition.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory DictionaryPartOfSpeech.fromJson(String source) =>
      DictionaryPartOfSpeech.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  String toString() =>
      'DictionaryPartOfSpeech(name: $name, definitions: $definitions)';

  @override
  bool operator ==(covariant DictionaryPartOfSpeech other) {
    if (identical(this, other)) return true;

    return other.name == name && listEquals(other.definitions, definitions);
  }

  @override
  int get hashCode => name.hashCode ^ definitions.hashCode;
}
