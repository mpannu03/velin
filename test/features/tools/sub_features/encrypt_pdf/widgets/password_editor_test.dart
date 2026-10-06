import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/tools.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('PasswordEditor', () {
    testWidgets('renders user and owner password fields', (tester) async {
      await pumpApp(
        tester,
        PasswordEditor(
          userPassword: 'user-secret',
          ownerPassword: 'owner-secret',
          onUserPasswordChanged: (_) {},
          onOwnerPasswordChanged: (_) {},
        ),
      );

      expect(
        find.byKey(const ValueKey('encrypt-user-password')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('encrypt-owner-password')),
        findsOneWidget,
      );
    });

    testWidgets('passes password values to the fields', (tester) async {
      await pumpApp(
        tester,
        PasswordEditor(
          userPassword: 'user-secret',
          ownerPassword: 'owner-secret',
          onUserPasswordChanged: (_) {},
          onOwnerPasswordChanged: (_) {},
        ),
      );

      final userField = tester.widget<TextField>(
        find.byKey(const ValueKey('encrypt-user-password')),
      );
      final ownerField = tester.widget<TextField>(
        find.byKey(const ValueKey('encrypt-owner-password')),
      );

      expect(userField.controller?.text, 'user-secret');
      expect(ownerField.controller?.text, 'owner-secret');
    });

    testWidgets('forwards password change callbacks', (tester) async {
      String? userPassword;
      String? ownerPassword;

      await pumpApp(
        tester,
        PasswordEditor(
          userPassword: 'user-secret',
          ownerPassword: 'owner-secret',
          onUserPasswordChanged: (value) => userPassword = value,
          onOwnerPasswordChanged: (value) => ownerPassword = value,
        ),
      );

      final userFinder = find.byKey(const ValueKey('encrypt-user-password'));
      final ownerFinder = find.byKey(const ValueKey('encrypt-owner-password'));

      // Focus each field and submit.
      await tester.showKeyboard(userFinder);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      await tester.showKeyboard(ownerFinder);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(userPassword, 'user-secret');
      expect(ownerPassword, 'owner-secret');
    });
  });
}
