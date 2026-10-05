import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/widgets/widgets.dart';

class ImageToPdfView extends StatelessWidget {
  const ImageToPdfView({super.key, required this.viewModel});

  final ImageToPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      desktop: ImageToPdfDesktopLayout(viewModel: viewModel),
      mobilePortrait: ImageToPdfMobileLayout(viewModel: viewModel),
    );
  }
}
