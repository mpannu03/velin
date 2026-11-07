import 'package:path/path.dart' as p;

String getPercentagefromDouble(double value) {
  return "${(value * 100).toStringAsFixed(0)}%";
}

bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) {
    return b == null;
  }
  if (b == null || a.length != b.length) {
    return false;
  }
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

String normalizePdfFileName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '';
  return trimmed.toLowerCase().endsWith('.pdf') ? trimmed : '$trimmed.pdf';
}

String directoryWithTrailingSeparator(String filePath) {
  if (filePath.isEmpty) return '';

  final isWindows =
      filePath.contains(r'\') &&
      !filePath.startsWith('/') &&
      !filePath.startsWith('\\');
  final sep = isWindows ? r'\' : '/';

  final idx = filePath.lastIndexOf(sep);
  if (idx < 0) return '';

  final dir = filePath.substring(0, idx + 1);
  return dir;
}

String fileNameFromPath(String filePath) {
  if (filePath.isEmpty) return '';

  final isWindows =
      filePath.contains(r'\') &&
      !filePath.startsWith('/') &&
      !filePath.startsWith('\\');
  final sep = isWindows ? r'\' : '/';

  final idx = filePath.lastIndexOf(sep);
  final name = idx < 0 ? filePath : filePath.substring(idx + 1);

  final dot = name.lastIndexOf('.');
  if (dot <= 0) return name;
  return name.substring(0, dot);
}

/// Joins an output folder and file name with the platform separator.
///
/// Trailing separators on [directory] are stripped first, so a folder picked
/// as `C:\out\` never produces a doubled separator.
String joinOutputPath(String directory, String fileName) {
  final trimmed = directory.trim().replaceFirst(RegExp(r'[/\\]+$'), '');
  return p.join(trimmed, fileName.trim());
}
