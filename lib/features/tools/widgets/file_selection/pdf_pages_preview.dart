import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/engine/rendering/rendering.dart';
import 'package:velin/shared/extensions/extensions.dart';

/// A grid of the first pages of the PDF at [filePath], so the user can see
/// what a tool is about to work on.
///
/// Only the first [maxPages] pages are rendered, small, to keep memory low
/// on long documents; the rest are summed up in a "+N more pages" line.
class PdfPagesPreview extends StatefulWidget {
  const PdfPagesPreview({required this.filePath, super.key});

  final String filePath;

  static const maxPages = 24;
  static const pageWidth = 112.0;

  @override
  State<PdfPagesPreview> createState() => _PdfPagesPreviewState();
}

class _PdfPagesPreviewState extends State<PdfPagesPreview> {
  PdfPreviewDocument? _document;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _open();
  }

  @override
  void didUpdateWidget(PdfPagesPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filePath != widget.filePath) {
      _close();
      _failed = false;
      _open();
    }
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  Future<void> _open() async {
    final path = widget.filePath;

    final result = await getIt<PdfPageRenderer>().openPreview(path);
    if (!mounted || path != widget.filePath) {
      if (result case Success(:final data)) await data.dispose();
      return;
    }

    setState(() {
      switch (result) {
        case Success(:final data):
          _document = data;
        case Failure():
          _failed = true;
      }
    });
  }

  void _close() {
    _document?.dispose();
    _document = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;
    final document = _document;
    final mutedStyle = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
    );

    if (_failed) {
      return Text(l10n.toolsPreviewUnavailable, style: mutedStyle);
    }

    if (document == null) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final pageCount = document.pageCount;
    final shown = pageCount.clamp(0, PdfPagesPreview.maxPages);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.toolsPreviewPageCount(pageCount), style: mutedStyle),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.lg,
          children: [
            for (var page = 1; page <= shown; page++)
              _PageThumbnail(
                key: ValueKey((widget.filePath, page)),
                document: document,
                page: page,
              ),
          ],
        ),
        if (pageCount > shown) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.toolsPreviewMorePages(pageCount - shown),
            style: mutedStyle,
          ),
        ],
      ],
    );
  }
}

class _PageThumbnail extends StatefulWidget {
  const _PageThumbnail({required this.document, required this.page, super.key});

  final PdfPreviewDocument document;
  final int page;

  @override
  State<_PageThumbnail> createState() => _PageThumbnailState();
}

class _PageThumbnailState extends State<_PageThumbnail> {
  ui.Image? _image;
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requested) return;
    _requested = true;

    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final width = (PdfPagesPreview.pageWidth * pixelRatio).ceil();
    widget.document.renderPage(widget.page, width: width).then((image) {
      if (!mounted) {
        image?.dispose();
        return;
      }
      setState(() => _image = image);
    }, onError: (Object _) {});
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final image = _image;

    return Semantics(
      label: context.l10n.toolsPreviewPageLabel(widget.page),
      child: SizedBox(
        width: PdfPagesPreview.pageWidth,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: widget.document.aspectRatio(widget.page),
              child: DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: image == null
                    ? ColoredBox(color: colors.surfaceContainerLow)
                    : RawImage(image: image, fit: BoxFit.fill),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ExcludeSemantics(
              child: Text(
                '${widget.page}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
