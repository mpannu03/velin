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
