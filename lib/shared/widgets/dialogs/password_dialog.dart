import 'package:material_ui/material_ui.dart';
import 'package:velin/shared/extensions/extensions.dart';

import 'result_dialog.dart';

Future<String?> showPasswordDialog({required BuildContext context}) {
  return showResultDialog<String?>(
    context: context,
    title: context.l10n.dialogEnterPassword,
    content: TextField(
      obscureText: true,
      decoration: InputDecoration(labelText: context.l10n.commonPassword),
    ),
    onSubmit: (context) {
      return null;
    },
  );
}
