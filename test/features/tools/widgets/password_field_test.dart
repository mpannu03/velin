import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:velin/features/tools/widgets/password_field.dart';
import 'package:velin/l10n/app_localizations.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('PasswordField', () {
    testWidgets('initializes with supplied value', (tester) async {
      await pumpApp(
        tester,
        const PasswordField(
          fieldKey: ValueKey('password'),
          value: 'secret',
          labelText: 'Password',
          helperText: 'Enter the PDF password.',
          onChanged: _noop,
        ),
      );

      final field = tester.widget<TextField>(
        find.byKey(const ValueKey('password')),
      );

      expect(field.controller?.text, 'secret');
    });

    testWidgets('obscures the password', (tester) async {
      await pumpApp(
        tester,
        const PasswordField(
          fieldKey: ValueKey('password'),
          value: 'secret',
          labelText: 'Password',
          helperText: 'Enter the PDF password.',
          onChanged: _noop,
        ),
      );

      final field = tester.widget<TextField>(
        find.byKey(const ValueKey('password')),
      );

      expect(field.obscureText, isTrue);
    });

    testWidgets('renders label and helper text', (tester) async {
      await pumpApp(
        tester,
        const PasswordField(
          fieldKey: ValueKey('password'),
          value: '',
          labelText: 'PDF password',
          helperText: 'Required for encrypted documents.',
          onChanged: _noop,
        ),
      );

      expect(find.text('PDF password'), findsOneWidget);
      expect(find.text('Required for encrypted documents.'), findsOneWidget);
    });

    testWidgets('uses supplied field key', (tester) async {
      const key = ValueKey('decrypt-password');

      await pumpApp(
        tester,
        const PasswordField(
          fieldKey: key,
          value: '',
          labelText: 'Password',
          helperText: 'Enter password.',
          onChanged: _noop,
        ),
      );

      expect(find.byKey(key), findsOneWidget);
    });

    testWidgets('commits current value when submitted', (tester) async {
      String? submittedValue;

      await pumpApp(
        tester,
        PasswordField(
          fieldKey: const ValueKey('password'),
          value: 'old-password',
          labelText: 'Password',
          helperText: 'Enter password.',
          onChanged: (value) => submittedValue = value,
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('password')),
        'new-password',
      );

      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(submittedValue, 'new-password');
    });

    testWidgets('commits current value when tapping outside', (tester) async {
      String? committedValue;

      await pumpApp(
        tester,
        Scaffold(
          body: Column(
            children: [
              PasswordField(
                fieldKey: const ValueKey('password'),
                value: 'old-password',
                labelText: 'Password',
                helperText: 'Enter password.',
                onChanged: (value) => committedValue = value,
              ),
              const Expanded(
                child: SizedBox.expand(key: ValueKey('outside-area')),
              ),
            ],
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('password')),
        'new-password',
      );
      await tester.pump();

      await tester.tap(
        find.byKey(const ValueKey('outside-area')),
        warnIfMissed: false,
      );
      await tester.pump();

      expect(committedValue, 'new-password');
    });

    testWidgets('commits initial value when submitted without editing', (
      tester,
    ) async {
      String? submittedValue;

      await pumpApp(
        tester,
        PasswordField(
          fieldKey: const ValueKey('password'),
          value: 'secret',
          labelText: 'Password',
          helperText: 'Enter password.',
          onChanged: (value) => submittedValue = value,
        ),
      );

      await tester.showKeyboard(find.byKey(const ValueKey('password')));
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submittedValue, 'secret');
    });

    testWidgets('updates controller when value changes externally', (
      tester,
    ) async {
      await pumpApp(
        tester,
        const PasswordField(
          fieldKey: ValueKey('password'),
          value: 'old-password',
          labelText: 'Password',
          helperText: 'Enter password.',
          onChanged: _noop,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(
            body: PasswordField(
              fieldKey: ValueKey('password'),
              value: 'new-password',
              labelText: 'Password',
              helperText: 'Enter password.',
              onChanged: _noop,
            ),
          ),
        ),
      );

      final field = tester.widget<TextField>(
        find.byKey(const ValueKey('password')),
      );

      expect(field.controller?.text, 'new-password');
    });

    testWidgets(
      'preserves current controller value when parent value is unchanged',
      (tester) async {
        await pumpApp(
          tester,
          const PasswordField(
            fieldKey: ValueKey('password'),
            value: 'secret',
            labelText: 'Password',
            helperText: 'Enter password.',
            onChanged: _noop,
          ),
        );

        await tester.enterText(
          find.byKey(const ValueKey('password')),
          'changed-secret',
        );

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const Scaffold(
              body: PasswordField(
                fieldKey: ValueKey('password'),
                value: 'secret',
                labelText: 'Password',
                helperText: 'Enter password.',
                onChanged: _noop,
              ),
            ),
          ),
        );

        final field = tester.widget<TextField>(
          find.byKey(const ValueKey('password')),
        );

        expect(field.controller?.text, 'changed-secret');
      },
    );

    testWidgets('does not expose password as plain text input', (tester) async {
      await pumpApp(
        tester,
        const PasswordField(
          fieldKey: ValueKey('password'),
          value: 'secret',
          labelText: 'Password',
          helperText: 'Enter password.',
          onChanged: _noop,
        ),
      );

      final field = tester.widget<TextField>(
        find.byKey(const ValueKey('password')),
      );

      expect(field.obscureText, isTrue);
      expect(field.controller?.text, 'secret');
    });
  });
}

void _noop(String value) {}
