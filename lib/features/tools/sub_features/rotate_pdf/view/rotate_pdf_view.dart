import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/widgets/widgets.dart';

class RotatePdfView extends StatelessWidget {
  const RotatePdfView({
    super.key,
    required this.viewModel,
  });

  final RotatePdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      desktop: RotatePdfDesktopLayout(viewModel: viewModel),
      mobilePortrait: RotatePdfMobileLayout(viewModel: viewModel),
    );
  }
}