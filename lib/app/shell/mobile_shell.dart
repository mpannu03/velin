import 'package:material_ui/material_ui.dart';

class MobileShell extends StatelessWidget {
  const MobileShell({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}