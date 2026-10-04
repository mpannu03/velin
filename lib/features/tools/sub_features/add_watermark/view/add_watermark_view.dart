import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/widgets/widgets.dart';

class AddWatermarkView extends StatelessWidget {
  const AddWatermarkView({
    super.key,
    required this.viewModel,
  });

  final AddWatermarkViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      desktop: AddWatermarkDesktopLayout(viewModel: viewModel),
      mobilePortrait: AddWatermarkMobileLayout(viewModel: viewModel),
    );
  }
}