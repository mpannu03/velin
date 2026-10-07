import 'package:material_ui/material_ui.dart';

import '../home.dart';

class HomeDesktopLayout extends StatelessWidget {
  const HomeDesktopLayout({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Text('Home Desktop Layout');
  }
}
