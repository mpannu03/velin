import 'package:material_ui/material_ui.dart';
import 'package:velin/shared/widgets/widgets.dart';

import '../layout/layout.dart';
import 'reader_view_model.dart';

class ReaderView extends StatelessWidget {
  const ReaderView({required this.viewModel, super.key});

  final ReaderViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      desktop: ReaderDesktopLayout(viewModel: viewModel),
      mobilePortrait: ReaderMobileLayout(viewModel: viewModel),
    );
  }
}
