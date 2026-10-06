import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/tools.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('SecurityEditor', () {
    testWidgets('renders encryption and permissions controls', (tester) async {
      await pumpApp(
        tester,
        SecurityEditor(
          level: EncryptPdfEncryptionLevel.aes256,
          permissions: EncryptPdfPermissionPreset.all,
          onLevelChanged: (_) {},
          onPermissionsChanged: (_) {},
        ),
      );

      expect(find.byKey(const ValueKey('encrypt-level')), findsOneWidget);
      expect(find.byKey(const ValueKey('encrypt-permissions')), findsOneWidget);
    });

    testWidgets('passes selected values to segmented buttons', (tester) async {
      await pumpApp(
        tester,
        SecurityEditor(
          level: EncryptPdfEncryptionLevel.aes128,
          permissions: EncryptPdfPermissionPreset.readOnly,
          onLevelChanged: (_) {},
          onPermissionsChanged: (_) {},
        ),
      );

      final levelButton = tester
          .widget<SegmentedButton<EncryptPdfEncryptionLevel>>(
            find.byKey(const ValueKey('encrypt-level')),
          );

      final permissionsButton = tester
          .widget<SegmentedButton<EncryptPdfPermissionPreset>>(
            find.byKey(const ValueKey('encrypt-permissions')),
          );

      expect(levelButton.selected, {EncryptPdfEncryptionLevel.aes128});
      expect(permissionsButton.selected, {EncryptPdfPermissionPreset.readOnly});
    });

    testWidgets('forwards encryption level changes', (tester) async {
      EncryptPdfEncryptionLevel? selectedLevel;

      await pumpApp(
        tester,
        SecurityEditor(
          level: EncryptPdfEncryptionLevel.aes256,
          permissions: EncryptPdfPermissionPreset.all,
          onLevelChanged: (value) => selectedLevel = value,
          onPermissionsChanged: (_) {},
        ),
      );

      final button = tester.widget<SegmentedButton<EncryptPdfEncryptionLevel>>(
        find.byKey(const ValueKey('encrypt-level')),
      );

      button.onSelectionChanged?.call({EncryptPdfEncryptionLevel.rc4});

      expect(selectedLevel, EncryptPdfEncryptionLevel.rc4);
    });

    testWidgets('forwards permission changes', (tester) async {
      EncryptPdfPermissionPreset? selectedPermissions;

      await pumpApp(
        tester,
        SecurityEditor(
          level: EncryptPdfEncryptionLevel.aes256,
          permissions: EncryptPdfPermissionPreset.all,
          onLevelChanged: (_) {},
          onPermissionsChanged: (value) => selectedPermissions = value,
        ),
      );

      final button = tester.widget<SegmentedButton<EncryptPdfPermissionPreset>>(
        find.byKey(const ValueKey('encrypt-permissions')),
      );

      button.onSelectionChanged?.call({EncryptPdfPermissionPreset.none});

      expect(selectedPermissions, EncryptPdfPermissionPreset.none);
    });
  });
}
