import 'package:velin/core/recent/recent.dart';
import 'package:velin/shared/utils/utils.dart';

/// How recents are laid out in the desktop home section.
enum RecentViewMode { list, grid }

/// Sort order for the recents section. Pure view preference.
enum RecentSortMode { lastOpened, progress, name }

double recentProgress(RecentDocument doc) {
  if (doc.pageCount <= 0) return 0;
  final current = doc.currentPage.clamp(1, doc.pageCount);
  return (current / doc.pageCount).clamp(0.0, 1.0);
}

int pagesLeft(RecentDocument doc) {
  if (doc.pageCount <= 0) return 0;
  return (doc.pageCount - doc.currentPage.clamp(1, doc.pageCount)).clamp(
    0,
    doc.pageCount,
  );
}

String recentFileName(String path) => fileNameFromPath(path);

String recentDirectory(String path) {
  final dir = directoryWithTrailingSeparator(path);
  if (dir.isEmpty) return '';
  // Trim trailing separator for a cleaner subtitle.
  if (dir.endsWith('/') || dir.endsWith(r'\')) {
    return dir.substring(0, dir.length - 1);
  }
  return dir;
}

String relativeTime(DateTime time) {
  final now = DateTime.now();
  final diff = now.difference(time);
  if (diff.isNegative) return 'Just now';
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  final weeks = (diff.inDays / 7).floor();
  if (weeks < 5) return '${weeks}w ago';
  return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';
}

List<RecentDocument> sortRecents(
  List<RecentDocument> docs,
  RecentSortMode mode,
) {
  final sorted = [...docs];
  switch (mode) {
    case RecentSortMode.lastOpened:
      sorted.sort((a, b) => b.lastOpenedAt.compareTo(a.lastOpenedAt));
    case RecentSortMode.progress:
      sorted.sort((a, b) => recentProgress(b).compareTo(recentProgress(a)));
    case RecentSortMode.name:
      sorted.sort(
        (a, b) =>
            recentFileName(a.path)
                .toLowerCase()
                .compareTo(recentFileName(b.path).toLowerCase()),
      );
  }
  return sorted;
}

List<RecentDocument> filterRecents(List<RecentDocument> docs, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return docs;
  return docs
      .where(
        (d) =>
            recentFileName(d.path).toLowerCase().contains(q) ||
            recentDirectory(d.path).toLowerCase().contains(q),
      )
      .toList();
}
