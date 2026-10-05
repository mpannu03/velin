import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/widgets/widgets.dart';

class SplitPdfView extends StatelessWidget {
  const SplitPdfView({super.key, required this.viewModel});

  final SplitPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      desktop: SplitPdfDesktopLayout(viewModel: viewModel),
      mobilePortrait: SplitPdfMobileLayout(viewModel: viewModel),
    );
  }
}
