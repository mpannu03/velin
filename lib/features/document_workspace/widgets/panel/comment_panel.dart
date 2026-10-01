import 'package:material_ui/material_ui.dart';
import 'package:velin/core/document/engine/engine.dart';

class CommentPanel extends StatelessWidget {
  const CommentPanel({
    super.key,
    required this.annotations,
    required this.onAnnotationSelected,
  });

  final List<Annotation> annotations;
  final ValueChanged<Annotation> onAnnotationSelected;

  @override
  Widget build(BuildContext context) {
    if (annotations.isEmpty) {
      return const Center(child: Text('No comments'));
    }

    // Group by page, preserving page order.
    final grouped = <int, List<Annotation>>{};
    for (final a in annotations) {
      grouped.putIfAbsent(a.pageNumber, () => []).add(a);
    }
    final pages = grouped.keys.toList()..sort();

    return ListView.builder(
      itemCount: pages.length,
      itemBuilder: (context, index) {
        final pageNumber = pages[index];
        final items = grouped[pageNumber]!;

        return _PageGroup(
          pageNumber: pageNumber,
          annotations: items,
          onAnnotationSelected: onAnnotationSelected,
        );
      },
    );
  }
}

class _PageGroup extends StatelessWidget {
  const _PageGroup({
    required this.pageNumber,
    required this.annotations,
    required this.onAnnotationSelected,
  });

  final int pageNumber;
  final List<Annotation> annotations;
  final ValueChanged<Annotation> onAnnotationSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Page $pageNumber',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...annotations.map((a) => _AnnotationTile(
              annotation: a,
              onClick: () => onAnnotationSelected(a),
            )),
      ],
    );
  }
}

class _AnnotationTile extends StatelessWidget {
  const _AnnotationTile({
    required this.annotation,
    required this.onClick,
  });

  final Annotation annotation;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subject = annotation.subject;
    final content = annotation.content;
    final title = annotation.title;
    final date = _formatDate(annotation.creationDate);

    // Highlights often have no content — fall back to subject or nothing.
    final body = content?.trim().isNotEmpty == true
        ? content!.trim()
        : null;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onClick,
      leading: _TypeBadge(subject: subject),
      title: body != null
          ? Text(
              body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            )
          : Text(
              subject ?? 'Annotation',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
      subtitle: _Subtitle(title: title, date: date),
    );
  }

  String? _formatDate(String? pdfDate) {
    if (pdfDate == null || pdfDate.isEmpty) return null;
    // pdfrx returns PDF date strings like: D:20220228160344+05'30'
    // Keep it simple: show the raw prefix if we can't parse.
    final match = RegExp(r'^D:(\d{4})(\d{2})(\d{2})').firstMatch(pdfDate);
    if (match == null) return pdfDate;
    return '${match.group(1)}-${match.group(2)}-${match.group(3)}';
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({required this.title, required this.date});

  final String? title;
  final String? date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts = <String>[
      if (title != null && title!.isNotEmpty) title!,
      if (date != null) date!,
    ];
    if (parts.isEmpty) return const SizedBox.shrink();

    return Text(
      parts.join('  ·  '),
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.subject});

  final String? subject;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconFor(subject);

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }

  (IconData, Color) _iconFor(String? subject) {
    final s = subject?.toLowerCase() ?? '';
    if (s.contains('highlight')) return (Icons.brush, Colors.amber);
    if (s.contains('strike') || s.contains('strikethrough')) {
      return (Icons.strikethrough_s, Colors.red);
    }
    if (s.contains('underline')) return (Icons.format_underline, Colors.blue);
    if (s.contains('note') || s.contains('comment')) {
      return (Icons.sticky_note_2_outlined, Colors.orange);
    }
    if (s.contains('ink') || s.contains('draw')) {
      return (Icons.gesture, Colors.purple);
    }
    if (s.contains('stamp')) return (Icons.approval, Colors.teal);
    if (s.contains('link')) return (Icons.link, Colors.blueGrey);
    return (Icons.comment_outlined, Colors.grey);
  }
}