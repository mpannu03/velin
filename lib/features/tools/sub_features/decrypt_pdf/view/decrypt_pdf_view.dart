import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/widgets/widgets.dart';

class DecryptPdfView extends StatelessWidget {
  const DecryptPdfView({super.key, required this.viewModel});

  final DecryptPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      desktop: DecryptPdfDesktopLayout(viewModel: viewModel),
      mobilePortrait: DecryptPdfMobileLayout(viewModel: viewModel),
    );
  }
}
