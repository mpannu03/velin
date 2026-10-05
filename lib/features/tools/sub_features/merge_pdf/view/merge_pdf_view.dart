import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/widgets/widgets.dart';

class MergePdfView extends StatelessWidget {
  const MergePdfView({super.key, required this.viewModel});

  final MergePdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      desktop: MergePdfDesktopLayout(viewModel: viewModel),
      mobilePortrait: MergePdfMobileLayout(viewModel: viewModel),
    );
  }
}
