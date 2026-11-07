import 'package:velin/core/error/error.dart';
import 'package:velin/core/page_selection/page_selection_error.dart';
import 'package:velin/l10n/app_localizations.dart';

extension AppFailureMessage on AppFailure {
  /// The message shown to the user for this failure.
  ///
  /// The switch is exhaustive over the sealed [AppFailure] hierarchy, so a new
  /// failure type cannot be added without giving it a message.
  String message(AppLocalizations l10n) {
    return switch (this) {
      FileNotFoundFailure() => l10n.errorFileNotFound,
      FileAccessDeniedFailure() => l10n.errorFileAccessDenied,
      FileInUseFailure() => l10n.errorFileInUse,
      DiskFullFailure() => l10n.errorDiskFull,
      FileSystemFailure() => l10n.errorFileSystem,
      OutputSameAsInputFailure() => l10n.errorOutputSameAsInput,
      UnsupportedFileTypeFailure() => l10n.errorUnsupportedFileType,
      PasswordRequiredFailure() => l10n.errorPasswordRequired,
      WrongPasswordFailure() => l10n.errorWrongPassword,
      CorruptDocumentFailure() => l10n.errorCorruptDocument,
      UnsupportedDocumentFeatureFailure() =>
        l10n.errorUnsupportedDocumentFeature,
      DocumentNotEncryptedFailure() => l10n.toolsUnlockNotEncrypted,
      InvalidImageFailure() => l10n.errorInvalidImage,
      InvalidPageSelectionFailure(:final error) => error.localizedMessage(l10n),
      NetworkFailure(isTimeout: true) => l10n.errorNetworkTimeout,
      NetworkFailure() => l10n.errorNetwork,
      ServerFailure() => l10n.errorServer,
      DictionaryEntryNotFoundFailure(:final word) =>
        l10n.errorDictionaryNotFound(word),
      CancelledFailure() || UnexpectedFailure() => l10n.errorUnexpected,
    };
  }
}

extension AppFailureUserMessage on AppFailure {
  /// Like [AppFailureMessage.message], but shows [fallback] (typically the
  /// operation's own "could not ..." text) for unexpected failures, whose
  /// specific cause means nothing to the user.
  String userMessage(
    AppLocalizations l10n, {
    String Function(AppLocalizations l10n)? fallback,
  }) {
    if (isUnexpected && fallback != null) return fallback(l10n);
    return message(l10n);
  }
}

extension PageSelectionErrorMessage on PageSelectionError {
  String localizedMessage(AppLocalizations l10n) {
    return switch (this) {
      EmptyPageSelectionError() => l10n.errorPageSelectionEmpty,
      InvalidPageSelectionTokenError(:final token) =>
        l10n.errorPageSelectionToken(token),
      InvalidPageSelectionRangeError(:final range) =>
        l10n.errorPageSelectionRange(range),
      InvalidPageSelectionNumberError(:final number) =>
        l10n.errorPageSelectionNumber(number),
      PageSelectionOutOfBoundsError(:final page, :final totalPages) =>
        l10n.errorPageSelectionOutOfBounds(page, totalPages),
    };
  }
}
