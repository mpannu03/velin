import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:velin/features/home/view/home_view_model.dart';

/// Rounded cover image for a recent document with graceful fallback.
/// Dumb: receives a loader callback, never touches repositories directly.
class RecentThumbnail extends StatelessWidget {
  const RecentThumbnail({
    required this.path,
    required this.loader,
    this.borderRadius = 8,
    this.fit = BoxFit.fitHeight,
    super.key,
  });

  final String path;
  final RecentThumbnailLoader loader;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: FutureBuilder<File?>(
        future: loader(path),
        builder: (context, snapshot) {
          final file = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ColoredBox(
              color: colors.surfaceContainerHighest,
              child: const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          if (file == null) {
            return ColoredBox(
              color: colors.surfaceContainerHighest,
              child: Icon(
                Icons.picture_as_pdf_outlined,
                size: 28,
                color: colors.onSurfaceVariant,
              ),
            );
          }
          return Image.file(
            file,
            fit: fit,
            errorBuilder: (_, _, _) => ColoredBox(
              color: colors.surfaceContainerHighest,
              child: Icon(
                Icons.picture_as_pdf_outlined,
                size: 28,
                color: colors.onSurfaceVariant,
              ),
            ),
          );
        },
      ),
    );
  }
}
