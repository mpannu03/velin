import 'package:material_ui/material_ui.dart';
import 'package:velin/shared/extensions/extensions.dart';

class ByPageCountEditor extends StatelessWidget {
  const ByPageCountEditor({
    super.key,
    required this.pageCount,
    required this.onPageCountChanged,
  });

  final String pageCount;
  final ValueChanged<String> onPageCountChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SizedBox(
      width: 220,
      child: TextField(
        key: const ValueKey('split-pages-per-file'),
        controller: TextEditingController(text: pageCount),
        keyboardType: TextInputType.number,
        onChanged: onPageCountChanged,
        decoration: InputDecoration(
          labelText: l10n.toolsSplitPagesPerFileLabel,
          hintText: l10n.toolsSplitPagesPerFileHint,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}