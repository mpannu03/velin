import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/tools.dart';

class ToolCard extends StatelessWidget {
  const ToolCard({
    required this.tool,
    required this.onTap,
    super.key,
  });

  final ToolDefinition tool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                tool.icon,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                tool.title(context),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}