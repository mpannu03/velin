import 'package:intl/intl.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/l10n/app_localizations.dart';
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

/// Short, localized "how long ago", e.g. "5m ago" or "Yesterday"; a date
/// for anything older than a month.
String relativeTime(DateTime time, AppLocalizations l10n, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(time);
  if (diff.isNegative || diff.inMinutes < 1) return l10n.timeJustNow;
  if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
  if (diff.inDays == 1) return l10n.timeYesterday;
  if (diff.inDays < 7) return l10n.timeDaysAgo(diff.inDays);
  final weeks = diff.inDays ~/ 7;
  if (weeks < 5) return l10n.timeWeeksAgo(weeks);
  return DateFormat.yMMMd(l10n.localeName).format(time);
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
