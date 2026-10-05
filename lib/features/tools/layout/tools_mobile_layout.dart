import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/tools.dart';

class ToolsMobileLayout extends StatelessWidget {
  const ToolsMobileLayout({required this.onToolTap, super.key});

  final ValueChanged<ToolDefinition> onToolTap;

  @override
  Widget build(BuildContext context) {
    return Text('Mobile Tools Layout');
  }
}
