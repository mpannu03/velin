import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';

class ToolScaffold extends StatelessWidget {
  const ToolScaffold({
    required this.title,
    required this.child,
    this.description,
    this.onBack,
    super.key,
  });

  final String title;
  final String? description;
  final VoidCallback? onBack;
  final Widget child;

  static const _maxContentWidth = 1000.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: onBack,
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: _maxContentWidth),
              child: Expanded(child: child)
            ),
          ),
        ),
      ],
    );
  }
}
