import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class ExtractPdfDesktopLayout extends StatelessWidget {
  const ExtractPdfDesktopLayout({
    super.key, 
    required this.viewModel,
  });

  static const _maxContentWidth = 1000.0;

  final ExtractPdfViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ToolScaffold(
      title: l10n.toolsExtractPdf,
      description: l10n.toolsExtractIntro,
      onBack: viewModel.onBack,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildContent(context),
                const SizedBox(height: AppSpacing.xl),
                _SplitActionBar(viewModel: viewModel),
              ],
            ),
          ),
        ),
      ),
    );
  }
}