import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/l10n/app_localizations.dart';

/// English localizations, for resolving [LocalizedMessage]s in tests.
final testL10n = lookupAppLocalizations(const Locale('en'));

/// Matches a [LocalizedMessage] that resolves to [expected] in English.
///
/// Use with mocktail: `message: any(named: 'message', that: localizes(...))`.
Matcher localizes(String expected) => isA<LocalizedMessage>().having(
  (message) => message(testL10n),
  'resolved message',
  expected,
);

/// Lets mocktail's `any()` match [LocalizedMessage] arguments.
void registerLocalizedMessageFallback() {
  registerFallbackValue((AppLocalizations _) => '');
}
