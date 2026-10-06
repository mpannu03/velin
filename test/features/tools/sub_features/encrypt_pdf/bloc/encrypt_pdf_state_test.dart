import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:velin/features/tools/sub_features/encrypt_pdf/encrypt_pdf.dart';

void main() {
  group('EncryptPdfState', () {
    test('uses expected defaults', () {
      const state = EncryptPdfState();

      expect(state.inputFilePath, isNull);
      expect(state.outputDirectory, isNull);
      expect(state.outputFileName, isNull);
      expect(state.userPassword, '');
      expect(state.ownerPassword, '');
      expect(state.level, EncryptPdfEncryptionLevel.aes256);
      expect(state.permissions, EncryptPdfPermissionPreset.all);
      expect(state.isSubmitting, isFalse);
    });

    group('hasInputFile', () {
      test('is false when input file is null', () {
        expect(const EncryptPdfState().hasInputFile, isFalse);
      });

      test('is false when input file is empty', () {
        expect(const EncryptPdfState(inputFilePath: '').hasInputFile, isFalse);
      });

      test('is false when input file contains only whitespace', () {
        expect(
          const EncryptPdfState(inputFilePath: '   ').hasInputFile,
          isFalse,
        );
      });

      test('is true when input file is provided', () {
        expect(
          const EncryptPdfState(inputFilePath: '/documents/input.pdf')
              .hasInputFile,
          isTrue,
        );
      });
    });

    group('hasValidOutputDirectory', () {
      test('is false when directory is null', () {
        expect(const EncryptPdfState().hasValidOutputDirectory, isFalse);
      });

      test('is false when directory is empty', () {
        expect(
          const EncryptPdfState(outputDirectory: '').hasValidOutputDirectory,
          isFalse,
        );
      });

      test('is false when directory contains only whitespace', () {
        expect(
          const EncryptPdfState(outputDirectory: '   ').hasValidOutputDirectory,
          isFalse,
        );
      });

      test('is true when directory is provided', () {
        expect(
          const EncryptPdfState(outputDirectory: '/documents')
              .hasValidOutputDirectory,
          isTrue,
        );
      });
    });

    group('hasValidOutputFileName', () {
      test('is false when filename is null', () {
        expect(const EncryptPdfState().hasValidOutputFileName, isFalse);
      });

      test('is false when filename is empty', () {
        expect(
          const EncryptPdfState(outputFileName: '').hasValidOutputFileName,
          isFalse,
        );
      });

      test('is false when filename contains only whitespace', () {
        expect(
          const EncryptPdfState(outputFileName: '   ').hasValidOutputFileName,
          isFalse,
        );
      });

      test('is true when filename is provided', () {
        expect(
          const EncryptPdfState(outputFileName: 'protected.pdf')
              .hasValidOutputFileName,
          isTrue,
        );
      });
    });

    group('hasDuplicatePasswords', () {
      test('is false when owner password is empty', () {
        const state = EncryptPdfState(userPassword: 'secret');

        expect(state.hasDuplicatePasswords, isFalse);
      });

      test('is false when passwords are different', () {
        const state = EncryptPdfState(
          userPassword: 'user-secret',
          ownerPassword: 'owner-secret',
        );

        expect(state.hasDuplicatePasswords, isFalse);
      });

      test('is true when both passwords are identical', () {
        const state = EncryptPdfState(
          userPassword: 'same-secret',
          ownerPassword: 'same-secret',
        );

        expect(state.hasDuplicatePasswords, isTrue);
      });

      test('is false when both passwords are empty', () {
        expect(const EncryptPdfState().hasDuplicatePasswords, isFalse);
      });
    });

    group('hasProtection', () {
      test('is false when no password or restrictions are set', () {
        expect(const EncryptPdfState().hasProtection, isFalse);
      });

      test('is true when user password is set', () {
        expect(
          const EncryptPdfState(userPassword: 'user-secret').hasProtection,
          isTrue,
        );
      });

      test('is true when owner password is set', () {
        expect(
          const EncryptPdfState(ownerPassword: 'owner-secret').hasProtection,
          isTrue,
        );
      });

      test('is true when permissions are restricted', () {
        expect(
          const EncryptPdfState(
            permissions: EncryptPdfPermissionPreset.readOnly,
          ).hasProtection,
          isTrue,
        );
      });
    });

    group('canProtect', () {
      const validState = EncryptPdfState(
        inputFilePath: '/documents/input.pdf',
        outputDirectory: '/documents/output',
        outputFileName: 'protected.pdf',
        userPassword: 'user-secret',
      );

      test('is true for a valid state', () {
        expect(validState.canProtect, isTrue);
      });

      test('is false without an input file', () {
        expect(validState.copyWith(inputFilePath: null).canProtect, isFalse);
      });

      test('is false without an output directory', () {
        expect(validState.copyWith(outputDirectory: null).canProtect, isFalse);
      });

      test('is false without an output filename', () {
        expect(validState.copyWith(outputFileName: null).canProtect, isFalse);
      });

      test('is false when there is no protection to apply', () {
        const state = EncryptPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents/output',
          outputFileName: 'protected.pdf',
        );

        expect(state.canProtect, isFalse);
      });

      test('is false when passwords are identical', () {
        const state = EncryptPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents/output',
          outputFileName: 'protected.pdf',
          userPassword: 'same-secret',
          ownerPassword: 'same-secret',
        );

        expect(state.canProtect, isFalse);
      });

      test('is false while submitting', () {
        expect(validState.copyWith(isSubmitting: true).canProtect, isFalse);
      });
    });

    group('toolInput', () {
      test('maps state to tool input', () {
        const state = EncryptPdfState(
          inputFilePath: ' /documents/input.pdf ',
          outputDirectory: ' /documents/output/ ',
          outputFileName: ' protected.pdf ',
          userPassword: 'user-secret',
          ownerPassword: 'owner-secret',
          level: EncryptPdfEncryptionLevel.aes128,
          permissions: EncryptPdfPermissionPreset.readOnly,
        );

        final result = state.toolInput;

        expect(result.filePath, '/documents/input.pdf');
        expect(
          result.outputFilePath,
          '/documents/output${Platform.pathSeparator}protected.pdf',
        );
        expect(result.userPassword, 'user-secret');
        expect(result.ownerPassword, 'owner-secret');
        expect(result.level, EncryptPdfEncryptionLevel.aes128);
        expect(result.permissions, EncryptPdfPermissionPreset.readOnly);
      });
    });

    group('copyWith', () {
      const original = EncryptPdfState(
        inputFilePath: '/documents/input.pdf',
        outputDirectory: '/documents/output',
        outputFileName: 'protected.pdf',
        userPassword: 'user-secret',
        ownerPassword: 'owner-secret',
        level: EncryptPdfEncryptionLevel.aes128,
        permissions: EncryptPdfPermissionPreset.readOnly,
        isSubmitting: true,
      );

      test('updates requested values', () {
        final result = original.copyWith(
          inputFilePath: '/documents/new.pdf',
          outputDirectory: '/documents/new-output',
          outputFileName: 'new.pdf',
          userPassword: 'new-user',
          ownerPassword: 'new-owner',
          level: EncryptPdfEncryptionLevel.rc4,
          permissions: EncryptPdfPermissionPreset.none,
          isSubmitting: false,
        );

        expect(
          result,
          const EncryptPdfState(
            inputFilePath: '/documents/new.pdf',
            outputDirectory: '/documents/new-output',
            outputFileName: 'new.pdf',
            userPassword: 'new-user',
            ownerPassword: 'new-owner',
            level: EncryptPdfEncryptionLevel.rc4,
            permissions: EncryptPdfPermissionPreset.none,
            isSubmitting: false,
          ),
        );
      });

      test('preserves unspecified values', () {
        final result = original.copyWith(userPassword: 'new-user');

        expect(
          result,
          const EncryptPdfState(
            inputFilePath: '/documents/input.pdf',
            outputDirectory: '/documents/output',
            outputFileName: 'protected.pdf',
            userPassword: 'new-user',
            ownerPassword: 'owner-secret',
            level: EncryptPdfEncryptionLevel.aes128,
            permissions: EncryptPdfPermissionPreset.readOnly,
            isSubmitting: true,
          ),
        );
      });

      test('can explicitly clear nullable values', () {
        final result = original.copyWith(
          inputFilePath: null,
          outputDirectory: null,
          outputFileName: null,
        );

        expect(result.inputFilePath, isNull);
        expect(result.outputDirectory, isNull);
        expect(result.outputFileName, isNull);
      });
    });

    group('equality', () {
      test('equal states are equal and have the same hash code', () {
        const first = EncryptPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents/output',
          outputFileName: 'protected.pdf',
          userPassword: 'user-secret',
          ownerPassword: 'owner-secret',
          level: EncryptPdfEncryptionLevel.aes128,
          permissions: EncryptPdfPermissionPreset.readOnly,
          isSubmitting: true,
        );

        const second = EncryptPdfState(
          inputFilePath: '/documents/input.pdf',
          outputDirectory: '/documents/output',
          outputFileName: 'protected.pdf',
          userPassword: 'user-secret',
          ownerPassword: 'owner-secret',
          level: EncryptPdfEncryptionLevel.aes128,
          permissions: EncryptPdfPermissionPreset.readOnly,
          isSubmitting: true,
        );

        expect(first, equals(second));
        expect(first.hashCode, equals(second.hashCode));
      });

      test('different states are not equal', () {
        const first = EncryptPdfState();

        const second = EncryptPdfState(userPassword: 'secret');

        expect(first, isNot(equals(second)));
      });
    });
  });
}
