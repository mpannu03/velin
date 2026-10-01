import 'package:flutter/widgets.dart';
import 'package:velin/core/document/document.dart';
import 'package:velin/core/document/engine/engine.dart';

abstract interface class DocumentEngine {
  Document get document;

  DocumentEngineCapabilities get capabilities;

  DocumentEngineSnapshot get snapshot;

  DocumentEngineActions get actions;

  DocumentEngineListener? get listener;

  TextSearchCapability? get textSearch;

  BookmarkCapability? get bookmark;

  AnnotationCapability? get annotation;

  set listener(DocumentEngineListener? listener);

  Widget buildViewer({
    required DocumentEngineConfig config,
  });
}