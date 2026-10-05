import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/widgets/widgets.dart';

class PdfToImageView extends StatelessWidget {
  const PdfToImageView({super.key, required this.viewModel});

  final PdfToImageViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      desktop: PdfToImageDesktopLayout(viewModel: viewModel),
      mobilePortrait: PdfToImageMobileLayout(viewModel: viewModel),
    );
  }
}
