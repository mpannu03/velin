import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/features/home/view/home_view_model.dart';
import 'package:velin/features/home/widgets/recent_grid_card.dart';

class RecentGrid extends StatelessWidget {
  const RecentGrid({
    required this.documents,
    required this.viewModel,
    super.key,
  });

  final List<RecentDocument> documents;
  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const minCardWidth = 240.0;
        final columns = (width / minCardWidth).floor().clamp(1, 4);
        const gap = AppSpacing.lg;
        final itemWidth = (width - (gap * (columns - 1))) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final doc in documents)
              SizedBox(
                width: itemWidth,
                child: RecentGridCard(document: doc, viewModel: viewModel),
              ),
          ],
        );
      },
    );
  }
}
