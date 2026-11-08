import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Version information about the running build.
class AppInfo {
  const AppInfo({required this.version, required this.buildNumber});

  static const unknown = AppInfo(version: 'unknown', buildNumber: '');

  /// Reads the version from the platform. Never throws: an unknown version
  /// must not stop the app from starting.
  static Future<AppInfo> load() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return AppInfo(version: info.version, buildNumber: info.buildNumber);
    } catch (error, stackTrace) {
      Logger('velin.app_info')
          .warning('Could not read the app version', error, stackTrace);
      return unknown;
    }
  }

  /// `pubspec.yaml` version without the build number, e.g. `0.5.0`.
  final String version;

  final String buildNumber;

  /// e.g. `0.5.0 (1)`.
  String get displayVersion =>
      buildNumber.isEmpty ? version : '$version ($buildNumber)';
}
