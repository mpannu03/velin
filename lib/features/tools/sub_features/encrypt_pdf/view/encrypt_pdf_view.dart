import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/widgets/widgets.dart';

class EncryptPdfView extends StatelessWidget {
  const EncryptPdfView({super.key, required this.viewModel});

  final EncryptPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      desktop: EncryptPdfDesktopLayout(viewModel: viewModel),
      mobilePortrait: EncryptPdfMobileLayout(viewModel: viewModel),
    );
  }
}
