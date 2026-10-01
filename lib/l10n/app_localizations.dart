import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The name of the application.
  ///
  /// In en, this message translates to:
  /// **'Velin'**
  String get appName;

  /// Label for the Home section in the main application navigation.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationHome;

  /// Label for the Reader section in the main application navigation.
  ///
  /// In en, this message translates to:
  /// **'Reader'**
  String get navigationReader;

  /// Label for the Edit section in the main application navigation.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get navigationEdit;

  /// Label for the Tools section in the main application navigation.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get navigationTools;

  /// Generic action to open a document or file.
  ///
  /// In en, this message translates to:
  /// **'Open Document'**
  String get commonOpenDocument;

  /// Generic action to close something.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// Generic action to cancel an operation.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Generic action to save changes.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Message displayed in the Reader when no document is currently open.
  ///
  /// In en, this message translates to:
  /// **'No document open'**
  String get readerNoDocumentOpen;

  /// Description for the message displayed in the Reader when no document is currently open.
  ///
  /// In en, this message translates to:
  /// **'Open a file to start reading'**
  String get readerNoDocumentOpenDescription;

  /// Label for the File menu in the application.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get menuFile;

  /// Label for the Edit menu in the application.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get menuEdit;

  /// Label for the View menu in the application.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get menuView;

  /// Label for the Select action.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get toolSelect;

  /// Label for the Dictionary action.
  ///
  /// In en, this message translates to:
  /// **'Dictionary'**
  String get toolDictionary;

  /// Label for the Comments panel.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get panelComments;

  /// Label for the Bookmarks panel.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get panelBookmarks;

  /// Label for the Search panel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get panelSearch;

  /// Label for the Zoom In action.
  ///
  /// In en, this message translates to:
  /// **'Zoom In'**
  String get toolZoomIn;

  /// Label for the Zoom Out action.
  ///
  /// In en, this message translates to:
  /// **'Zoom Out'**
  String get toolZoomOut;

  /// Displays the current page number and total number of pages in the PDF.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String toolPageOf(int current, int total);

  /// Label for the search functionality within the document.
  ///
  /// In en, this message translates to:
  /// **'Search in Document...'**
  String get panelSearchInDocument;

  /// Label for the clear search action.
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get panelSearchClear;

  /// Label for the toggle case sensitivity action.
  ///
  /// In en, this message translates to:
  /// **'Toggle Case Sensitivity'**
  String get panelSearchToggleCaseSensitivity;

  /// Placeholder text for the search input field.
  ///
  /// In en, this message translates to:
  /// **'Enter text to search'**
  String get panelSearchEnterText;

  /// Message displayed when no search results are found.
  ///
  /// In en, this message translates to:
  /// **'No match found'**
  String get panelSearchNoMatchFound;

  /// Displays the number of search results found.
  ///
  /// In en, this message translates to:
  /// **'{count} results found'**
  String panelSearchResultCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
