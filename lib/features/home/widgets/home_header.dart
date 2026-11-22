import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/shared/extensions/extensions.dart';

/// A section heading with the Home actions on the right: open a document
/// and, optionally, go to the tools.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.title,
    required this.isOpening,
    required this.onOpenDocument,
    this.onBrowseTools,
    super.key,
  });

  final String title;
  final bool isOpening;
  final VoidCallback onOpenDocument;

  /// Shows a "Browse tools" button when set; left out when the tools are
  /// already on the page.
  final VoidCallback? onBrowseTools;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(child: HomeSectionTitle(title)),
        if (onBrowseTools != null) ...[
          TextButton.icon(
            onPressed: onBrowseTools,
            icon: const Icon(Icons.build_outlined, size: 18),
            label: Text(l10n.homeBrowseTools),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        HomeOpenButton(isOpening: isOpening, onPressed: onOpenDocument),
      ],
    );
  }
}

/// The primary "Open…" button; shows progress while a file is opening.
class HomeOpenButton extends StatelessWidget {
  const HomeOpenButton({
    required this.isOpening,
    required this.onPressed,
    super.key,
  });

  final bool isOpening;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FilledButton.icon(
      onPressed: isOpening ? null : onPressed,
      icon: isOpening
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.folder_open_outlined, size: 18),
      label: Text(isOpening ? l10n.homeOpening : l10n.homeOpenDocument),
    );
  }
}

/// Heading of a Home section, with an optional muted [trailing] count.
class HomeSectionTitle extends StatelessWidget {
  const HomeSectionTitle(this.title, {this.count, super.key});

  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$count',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
