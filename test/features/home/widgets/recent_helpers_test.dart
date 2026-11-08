import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:velin/features/home/widgets/recent_helpers.dart';

import '../../../helpers/helpers.dart';

void main() {
  // The app gets date data through flutter_localizations; load it here.
  setUpAll(() => initializeDateFormatting('en'));

  group('relativeTime', () {
    final now = DateTime(2026, 11, 8, 12);

    String ago(Duration duration) =>
        relativeTime(now.subtract(duration), testL10n, now: now);

    test('uses short relative forms for recent times', () {
      expect(ago(const Duration(seconds: 20)), 'Just now');
      expect(ago(const Duration(minutes: 5)), '5m ago');
      expect(ago(const Duration(hours: 3)), '3h ago');
      expect(ago(const Duration(days: 1)), 'Yesterday');
      expect(ago(const Duration(days: 4)), '4d ago');
      expect(ago(const Duration(days: 15)), '2w ago');
    });

    test('treats future times as just now', () {
      expect(
        relativeTime(now.add(const Duration(hours: 1)), testL10n, now: now),
        'Just now',
      );
    });

    test('shows a localized date for older times', () {
      expect(ago(const Duration(days: 60)), 'Sep 9, 2026');
    });
  });
}
