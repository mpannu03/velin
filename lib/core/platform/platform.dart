import 'package:flutter/foundation.dart';

enum AppPlatform {
  mobile,
  desktop,
}

AppPlatform get appPlatform {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
      return AppPlatform.mobile;

    case TargetPlatform.windows:
    case TargetPlatform.macOS:
    case TargetPlatform.linux:
    case TargetPlatform.fuchsia:
      return AppPlatform.desktop;
  }
}