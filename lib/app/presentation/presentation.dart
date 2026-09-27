import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';

enum AppPresentation {
  mobile,
  touch,
  desktop,
}

extension AppPresentationContext on BuildContext {
  AppPresentation get presentation => AppPresentation.desktop;
}

extension AppPresentationDimensions on AppPresentation {
  double get controlHeight {
    return switch (this) {
      AppPresentation.mobile => AppDimensions.mobileControlHeight,
      AppPresentation.touch => AppDimensions.touchControlHeight,
      AppPresentation.desktop => AppDimensions.desktopControlHeight,
    };
  }

  double get iconButtonSize {
    return switch (this) {
      AppPresentation.mobile => AppDimensions.mobileIconButtonSize,
      AppPresentation.touch => AppDimensions.touchIconButtonSize,
      AppPresentation.desktop => AppDimensions.desktopIconButtonSize,
    };
  }
}