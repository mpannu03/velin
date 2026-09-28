import 'package:material_ui/material_ui.dart';

class ReaderEmptyState extends StatelessWidget {
  const ReaderEmptyState({
    required this.onOpenDocument,
    super.key,
  });

  final VoidCallback onOpenDocument;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('No documents open'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onOpenDocument,
            child: const Text('Open document'),
          ),
        ],
      ),
    );
  }
}