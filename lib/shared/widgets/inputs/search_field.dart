import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';

/// A compact filled search box for filtering a page's content; outlined in
/// the accent colour while focused.
class SearchField extends StatelessWidget {
  const SearchField({
    required this.hintText,
    required this.onChanged,
    this.width = 260,
    super.key,
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppRadius.md);

    return SizedBox(
      width: width,
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search, size: 16),
          prefixIconConstraints: const BoxConstraints(minWidth: 32),
          filled: true,
          fillColor: colors.surfaceContainer,
          border: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: colors.primary),
          ),
        ),
      ),
    );
  }
}
