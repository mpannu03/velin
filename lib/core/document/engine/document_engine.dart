import 'package:flutter/widgets.dart';
import 'package:velin/core/document/document.dart';

import 'document_engine_actions.dart';
import 'document_engine_capabilities.dart';
import 'document_engine_config.dart';
import 'document_engine_listener.dart';
import 'document_engine_snapshot.dart';

abstract interface class DocumentEngine {
  Document get document;

  DocumentEngineCapabilities get capabilities;

  DocumentEngineSnapshot get snapshot;

  DocumentEngineActions get actions;

  DocumentEngineListener? get listener;

  set listener(DocumentEngineListener? listener);

  Widget buildViewer({
    required DocumentEngineConfig config,
  });
}