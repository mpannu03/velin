import 'package:flutter_test/flutter_test.dart';
import 'package:velin/engine/engine.dart';

import 'package:velin/features/tools/sub_features/encrypt_pdf/encrypt_pdf.dart';

void main() {
  late EncryptPdfToolInput input;

  setUp(() {
    input = EncryptPdfToolInput(
      filePath: '/documents/input.pdf',
      outputFilePath: '/documents/protected.pdf',
    );
  });

  group('EncryptPdfToolInput', () {
    test('uses expected defaults', () {
      expect(input.userPassword, '');
      expect(input.ownerPassword, '');
      expect(input.level, EncryptPdfEncryptionLevel.aes256);
      expect(input.permissions, EncryptPdfPermissionPreset.all);
    });

    group('hasEffect', () {
      test('is false when no password or restricted permissions are set', () {
        expect(input.hasEffect, isFalse);
      });

      test('is true when user password is set', () {
        expect(input.copyWith(userPassword: 'user-secret').hasEffect, isTrue);
      });

      test('is true when owner password is set', () {
        expect(input.copyWith(ownerPassword: 'owner-secret').hasEffect, isTrue);
      });

      test('is true when permissions are restricted', () {
        expect(
          input
              .copyWith(permissions: EncryptPdfPermissionPreset.readOnly)
              .hasEffect,
          isTrue,
        );
      });
    });

    group('hasDuplicatePasswords', () {
      test('is false when owner password is empty', () {
        final value = input.copyWith(userPassword: 'secret');

        expect(value.hasDuplicatePasswords, isFalse);
      });

      test('is false when passwords are different', () {
        final value = input.copyWith(
          userPassword: 'user-secret',
          ownerPassword: 'owner-secret',
        );

        expect(value.hasDuplicatePasswords, isFalse);
      });

      test('is true when both passwords are identical', () {
        final value = input.copyWith(
          userPassword: 'same-secret',
          ownerPassword: 'same-secret',
        );

        expect(value.hasDuplicatePasswords, isTrue);
      });

      test('is false when both passwords are empty', () {
        expect(input.hasDuplicatePasswords, isFalse);
      });
    });

    test('copyWith updates only the requested values', () {
      const original = EncryptPdfToolInput(
        filePath: '/documents/input.pdf',
        outputFilePath: '/documents/protected.pdf',
        userPassword: 'user-secret',
        ownerPassword: 'owner-secret',
        level: EncryptPdfEncryptionLevel.aes128,
        permissions: EncryptPdfPermissionPreset.readOnly,
      );

      final result = original.copyWith(
        userPassword: 'new-user-secret',
        level: EncryptPdfEncryptionLevel.rc4,
      );

      expect(
        result,
        const EncryptPdfToolInput(
          filePath: '/documents/input.pdf',
          outputFilePath: '/documents/protected.pdf',
          userPassword: 'new-user-secret',
          ownerPassword: 'owner-secret',
          level: EncryptPdfEncryptionLevel.rc4,
          permissions: EncryptPdfPermissionPreset.readOnly,
        ),
      );
    });

    test('supports equality and hashCode', () {
      const first = EncryptPdfToolInput(
        filePath: '/documents/input.pdf',
        outputFilePath: '/documents/protected.pdf',
        userPassword: 'user-secret',
        ownerPassword: 'owner-secret',
        level: EncryptPdfEncryptionLevel.aes128,
        permissions: EncryptPdfPermissionPreset.readOnly,
      );

      const second = EncryptPdfToolInput(
        filePath: '/documents/input.pdf',
        outputFilePath: '/documents/protected.pdf',
        userPassword: 'user-secret',
        ownerPassword: 'owner-secret',
        level: EncryptPdfEncryptionLevel.aes128,
        permissions: EncryptPdfPermissionPreset.readOnly,
      );

      expect(first, equals(second));
      expect(first.hashCode, equals(second.hashCode));
    });

    test('different values are not equal', () {
      const first = EncryptPdfToolInput(
        filePath: '/documents/input.pdf',
        outputFilePath: '/documents/protected.pdf',
      );

      const second = EncryptPdfToolInput(
        filePath: '/documents/input.pdf',
        outputFilePath: '/documents/protected.pdf',
        userPassword: 'secret',
      );

      expect(first, isNot(equals(second)));
    });
  });

  group('EncryptPdfEncryptionLevel', () {
    test('maps each UI level to the corresponding engine level', () {
      expect(EncryptPdfEncryptionLevel.aes256.level, PdfEncryptionLevel.aes256);
      expect(EncryptPdfEncryptionLevel.aes128.level, PdfEncryptionLevel.aes128);
      expect(EncryptPdfEncryptionLevel.rc4.level, PdfEncryptionLevel.rc4);
    });
  });

  group('EncryptPdfPermissionPreset', () {
    test('maps each UI preset to the corresponding engine permissions', () {
      expect(EncryptPdfPermissionPreset.all.permissions, PdfPermissions.all());
      expect(
        EncryptPdfPermissionPreset.readOnly.permissions,
        PdfPermissions.readOnly(),
      );
      expect(
        EncryptPdfPermissionPreset.none.permissions,
        PdfPermissions.none(),
      );
    });
  });

  group('EncryptPdfMapper', () {
    test('maps paths, passwords, permissions, and level', () {
      const input = EncryptPdfToolInput(
        filePath: '/documents/input.pdf',
        outputFilePath: '/documents/protected.pdf',
        userPassword: 'user-secret',
        ownerPassword: 'owner-secret',
        level: EncryptPdfEncryptionLevel.aes128,
        permissions: EncryptPdfPermissionPreset.readOnly,
      );

      final result = input.toEncryptPdfInput();

      expect(result.inputFile.path, '/documents/input.pdf');
      expect(result.outputFile.path, '/documents/protected.pdf');
      expect(result.userPassword, 'user-secret');
      expect(result.ownerPassword, 'owner-secret');
      expect(result.permissions, PdfPermissions.readOnly());
      expect(result.level, PdfEncryptionLevel.aes128);
    });

    test('generates an owner password when owner password is empty', () {
      final result = input.toEncryptPdfInput();

      expect(result.ownerPassword, isNotEmpty);
      expect(result.ownerPassword.length, 32);
      expect(result.ownerPassword, matches(RegExp(r'^[\x21-\x7E]{32}$')));
    });

    test('generates a fresh owner password for each mapping', () {
      final first = input.toEncryptPdfInput();
      final second = input.toEncryptPdfInput();

      expect(first.ownerPassword, isNot(second.ownerPassword));
    });

    test('preserves an explicit owner password', () {
      const value = EncryptPdfToolInput(
        filePath: '/documents/input.pdf',
        outputFilePath: '/documents/protected.pdf',
        ownerPassword: 'owner-secret',
      );

      final result = value.toEncryptPdfInput();

      expect(result.ownerPassword, 'owner-secret');
    });
  });
}
