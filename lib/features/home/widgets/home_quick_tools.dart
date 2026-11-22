import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/home/widgets/home_header.dart';
import 'package:velin/features/tools/registry/registry.dart';
import 'package:velin/features/tools/widgets/tool_card.dart';
import 'package:velin/shared/extensions/extensions.dart';

/// The most used tools, one click away from Home, with a link to the rest.
class HomeQuickTools extends StatelessWidget {
  const HomeQuickTools({
    required this.onToolSelected,
    required this.onBrowseTools,
    super.key,
  });

  final ValueChanged<ToolDefinition> onToolSelected;
  final VoidCallback onBrowseTools;

  static const tools = [
    ToolRegistry.mergePdf,
    ToolRegistry.splitPdf,
    ToolRegistry.compressPdf,
    ToolRegistry.rotatePdf,
    ToolRegistry.extractPdf,
    ToolRegistry.pdfToImage,
    ToolRegistry.protectPdf,
    ToolRegistry.watermark,
  ];

  static const _tileWidth = 240.0;
  static const _tileHeight = 40.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: HomeSectionTitle(l10n.homeQuickTools)),
            TextButton(
              onPressed: onBrowseTools,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.homeAllTools),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: _tileWidth,
            mainAxisExtent: _tileHeight,
            crossAxisSpacing: AppSpacing.sm,
          ),
          children: [
            for (final tool in tools)
              _QuickToolTile(tool: tool, onTap: () => onToolSelected(tool)),
          ],
        ),
      ],
    );
  }
}

/// The quick tools as a side pane next to the documents on wide windows:
/// each tool with its description, and the link to all tools at the end.
class HomeToolsPane extends StatelessWidget {
  const HomeToolsPane({
    required this.onToolSelected,
    required this.onBrowseTools,
    super.key,
  });

  final ValueChanged<ToolDefinition> onToolSelected;
  final VoidCallback onBrowseTools;

  static const width = 320.0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return ColoredBox(
      color: colors.surfaceContainerLowest,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              // Lines the heading up with the tool icons below it.
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: SizedBox(
                height: 36,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: HomeSectionTitle(l10n.homeQuickTools),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final tool in HomeQuickTools.tools)
              ToolCard(tool: tool, onTap: () => onToolSelected(tool)),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onBrowseTools,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.homeAllTools),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickToolTile extends StatelessWidget {
  const _QuickToolTile({required this.tool, required this.onTap});

  final ToolDefinition tool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Tooltip(
      message: tool.description(context),
      waitDuration: const Duration(milliseconds: 600),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          hoverColor: colors.surfaceContainer,
          focusColor: colors.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: [
                Icon(tool.icon, size: 20, color: colors.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    tool.title(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
