import 'package:material_ui/material_ui.dart';
import 'package:velin/shared/extensions/extensions.dart';

class ToolDefinition {
  const ToolDefinition({
    required this.id,
    required this.category,
    required this.icon,
    required this.route,
  });

  final ToolId id;
  final ToolCategory category;
  final IconData icon;
  final String route;
}

enum ToolId {
  mergePdf,
}

enum ToolCategory {
  edit,
  convert,
  optimize,
  security,
}

extension ToolDefinitionX on ToolDefinition {
  String title(BuildContext context) {
    return switch (id) {
      ToolId.mergePdf => context.l10n.toolsMergePdf,
    };
  }

  String categoryLabel(BuildContext context) {
    return switch (category) {
      ToolCategory.edit => context.l10n.toolsCategoryEdit,
      ToolCategory.convert => context.l10n.toolsCategoryConvert,
      ToolCategory.optimize => context.l10n.toolsCategoryOptimize,
      ToolCategory.security => context.l10n.toolsCategorySecurity,
    };
  }
}