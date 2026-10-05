import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/widgets/widgets.dart';

class CompressPdfView extends StatelessWidget {
  const CompressPdfView({super.key, required this.viewModel});

  final CompressPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      desktop: CompressPdfDesktopLayout(viewModel: viewModel),
      mobilePortrait: CompressPdfMobileLayout(viewModel: viewModel),
    );
  }
}
