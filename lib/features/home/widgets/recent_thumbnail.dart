import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:velin/features/home/view/home_view_model.dart';

/// Cover image of a recent document, with a plain placeholder while it
/// loads or when there is none.
///
/// The image is requested once per [path], so hover and other rebuilds of
/// the parent do not reload it.
class RecentThumbnail extends StatefulWidget {
  const RecentThumbnail({
    required this.path,
    required this.loader,
    this.borderRadius = 0,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.topCenter,
    super.key,
  });

  final String path;
  final RecentThumbnailLoader loader;
  final double borderRadius;
  final BoxFit fit;
  final Alignment alignment;

  @override
  State<RecentThumbnail> createState() => _RecentThumbnailState();
}

class _RecentThumbnailState extends State<RecentThumbnail> {
  late Future<File?> _image = widget.loader(widget.path);

  @override
  void didUpdateWidget(RecentThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _image = widget.loader(widget.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final placeholder = ColoredBox(
      color: colors.surfaceContainerHigh,
      child: Center(
        child: Icon(
          Icons.description_outlined,
          size: 28,
          color: colors.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: FutureBuilder<File?>(
        future: _image,
        builder: (context, snapshot) {
          final file = snapshot.data;
          if (file == null) {
            // Loading or missing: the same quiet placeholder, no spinner.
            return placeholder;
          }
          return Image.file(
            file,
            fit: widget.fit,
            alignment: widget.alignment,
            errorBuilder: (_, _, _) => placeholder,
          );
        },
      ),
    );
  }
}
