import 'package:material_ui/material_ui.dart';

import 'tool_definition.dart';

abstract final class ToolRegistry {
  static const mergePdf = ToolDefinition(
    id: ToolId.mergePdf,
    category: ToolCategory.edit,
    icon: Icons.merge_type,
    route: '/tools/merge-pdf',
  );

  static const all = [
    mergePdf,
  ];
}