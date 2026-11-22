import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/shared/extensions/extensions.dart';

/// The frame of a tool page on desktop.
///
/// The left side holds the title and what the tool works on ([child]:
/// the file pickers), using the window's width. The right side is a
/// settings pane: the [settings] sections stacked with hairlines between
/// them, and the [action] pinned at the bottom so it is always in reach.
class ToolScaffold extends StatelessWidget {
  const ToolScaffold({
    required this.title,
    required this.child,
    this.description,
    this.onBack,
    this.settings = const [],
    this.action,
    super.key,
  });

  final String title;
  final String? description;
  final VoidCallback? onBack;

  /// The input of the tool, e.g. the file picker.
  final Widget child;

  /// Option sections shown in the settings pane, top to bottom.
  final List<Widget> settings;

  /// The tool's action bar, pinned to the bottom of the settings pane.
  final Widget? action;

  static const settingsPaneWidth = 380.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TitleBlock(
                  title: title,
                  description: description,
                  onBack: onBack,
                ),
                const SizedBox(height: AppSpacing.xl),
                child,
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        SizedBox(
          width: settingsPaneWidth,
          child: _SettingsPane(settings: settings, action: action),
        ),
      ],
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.title, this.description, this.onBack});

  final String title;
  final String? description;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // A "← Tools" link above the title, at the normal button size.
        // Shifted by the theme's button padding so the arrow sits on the
        // title's edge.
        Transform.translate(
          offset: const Offset(-AppSpacing.md, 0),
          child: TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, size: 18),
            label: Text(context.l10n.navigationTools),
            style: TextButton.styleFrom(
              foregroundColor: colors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            description!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _SettingsPane extends StatelessWidget {
  const _SettingsPane({required this.settings, required this.action});

  final List<Widget> settings;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ColoredBox(
      color: colors.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: settings.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Text(
                        context.l10n.toolsSettingsEmpty,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (index, section) in settings.indexed) ...[
                          if (index > 0)
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.lg,
                              ),
                              child: Divider(),
                            ),
                          section,
                        ],
                      ],
                    ),
                  ),
          ),
          if (action != null) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: action,
            ),
          ],
        ],
      ),
    );
  }
}
