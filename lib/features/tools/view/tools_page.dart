import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/widgets/widgets.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    void onToolTap(ToolDefinition tool) => context.push(tool.route);

    return ResponsiveLayout(
      desktop: ToolsDesktopLayout(onToolTap: onToolTap),
      mobilePortrait: ToolsMobileLayout(onToolTap: onToolTap),
    );
  }
}
