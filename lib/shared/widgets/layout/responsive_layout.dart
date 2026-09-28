import 'package:material_ui/material_ui.dart';
import 'package:velin/core/platform/platform.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.desktop,
    required this.mobilePortrait,
    this.mobileLandscape,
    super.key,
  });

  final Widget desktop;
  final Widget mobilePortrait;
  final Widget? mobileLandscape;

  @override
  Widget build(BuildContext context) {
    if (appPlatform == AppPlatform.desktop) {
      return desktop;
    }

    final size = MediaQuery.sizeOf(context);

    if (size.width > size.height && mobileLandscape != null) {
      return mobileLandscape!;
    }

    return mobilePortrait;
  }
}