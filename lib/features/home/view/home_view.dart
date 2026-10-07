import 'package:material_ui/material_ui.dart';
import 'package:velin/shared/widgets/widgets.dart';

import '../home.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      desktop: HomeDesktopLayout(viewModel: viewModel),
      mobilePortrait: HomeMobileLayout(),
    );
  }
}
