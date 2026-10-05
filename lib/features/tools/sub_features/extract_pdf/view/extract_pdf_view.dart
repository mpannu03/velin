import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/widgets/widgets.dart';

class ExtractPdfView extends StatelessWidget {
  const ExtractPdfView({super.key, required this.viewModel});

  final ExtractPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      desktop: ExtractPdfDesktopLayout(viewModel: viewModel),
      mobilePortrait: ExtractPdfMobileLayout(viewModel: viewModel),
    );
  }
}
