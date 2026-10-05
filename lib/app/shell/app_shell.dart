import 'package:material_ui/material_ui.dart';
import 'package:velin/core/platform/platform.dart';

import 'desktop_shell.dart';
import 'mobile_shell.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: switch (appPlatform) {
        AppPlatform.desktop => DesktopShell(child: child),
        AppPlatform.mobile => MobileShell(child: child),
      },
    );
  }
}
