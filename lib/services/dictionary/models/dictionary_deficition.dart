import 'dart:convert';

import 'package:flutter/foundation.dart';

class DictionaryDefinition {
  const DictionaryDefinition({
    required this.definition,
    required this.examples,
  });

  final String definition;
  final List<String> examples;

  @override
  bool operator ==(covariant DictionaryDefinition other) {
    if (identical(this, other)) return true;

    return other.definition == definition &&
        listEquals(other.examples, examples);
  }

  @override
  int get hashCode => definition.hashCode ^ examples.hashCode;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'definition': definition, 'examples': examples};
  }

  factory DictionaryDefinition.fromMap(Map<String, dynamic> map) {
    return DictionaryDefinition(
      definition: map['definition'] as String,
      examples: List<String>.from((map['examples'] as List<String>)),
    );
  }

  String toJson() => json.encode(toMap());

  factory DictionaryDefinition.fromJson(String source) =>
      DictionaryDefinition.fromMap(json.decode(source) as Map<String, dynamic>);
}
