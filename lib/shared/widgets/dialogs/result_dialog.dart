import 'package:material_ui/material_ui.dart';
import 'package:velin/shared/extensions/extensions.dart';

Future<T?> showResultDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  required T? Function(BuildContext context) onSubmit,
  String? cancelText,
  String? submitText,
}) {
  return showDialog<T>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: content,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: Text(cancelText ?? context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(
              onSubmit(dialogContext),
            ),
            child: Text(submitText ?? context.l10n.commonSubmit),
          ),
        ],
      );
    },
  );
}