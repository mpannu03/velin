import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/features/home/view/home_view_model.dart';
import 'package:velin/features/home/widgets/recent_list_row.dart';

class RecentList extends StatelessWidget {
  const RecentList({
    required this.documents,
    required this.viewModel,
    super.key,
  });

  final List<RecentDocument> documents;
  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < documents.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          RecentListRow(document: documents[i], viewModel: viewModel),
        ],
      ],
    );
  }
}
