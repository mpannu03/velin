import 'package:flutter/widgets.dart';
import 'package:velin/core/document/document.dart';

import 'document_engine_capabilities.dart';
import 'document_engine_controller.dart';

abstract interface class DocumentEngine {
  Document get document;

  DocumentEngineCapabilities get capabilities;

  DocumentEngineController get controller;

  Widget buildViewer({
    required Color backgroundColor,
  });
}