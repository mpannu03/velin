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
  /// **'Open a file to start reading.'**
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

  /// Label for the Dictionary panel.
  ///
  /// In en, this message translates to:
  /// **'Dictionary'**
  String get panelDictionary;

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

  /// Message displayed when the bookmarks panel is empty.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks'**
  String get panelBookmarkEmpty;

  /// Label for the Merge PDF tool.
  ///
  /// In en, this message translates to:
  /// **'Merge PDF'**
  String get toolsMergePdf;

  /// Label for the Split PDF tool.
  ///
  /// In en, this message translates to:
  /// **'Split PDF'**
  String get toolsSplitPdf;

  /// Label for the Extract Pages tool.
  ///
  /// In en, this message translates to:
  /// **'Extract Pages'**
  String get toolsExtractPdf;

  /// Label for the Compress PDF tool.
  ///
  /// In en, this message translates to:
  /// **'Compress PDF'**
  String get toolsCompressPdf;

  /// Label for the PDF to Image tool.
  ///
  /// In en, this message translates to:
  /// **'PDF to Image'**
  String get toolsPdfToImage;

  /// Label for the Image to PDF tool.
  ///
  /// In en, this message translates to:
  /// **'Image to PDF'**
  String get toolsImageToPdf;

  /// Label for the Rotate PDF tool.
  ///
  /// In en, this message translates to:
  /// **'Rotate PDF'**
  String get toolsRotatePdf;

  /// Label for the Protect PDF tool.
  ///
  /// In en, this message translates to:
  /// **'Protect PDF'**
  String get toolsProtectPdf;

  /// Label for the Unlock PDF tool.
  ///
  /// In en, this message translates to:
  /// **'Unlock PDF'**
  String get toolsUnlockPdf;

  /// Label for the Watermark tool.
  ///
  /// In en, this message translates to:
  /// **'Watermark'**
  String get toolsWatermark;

  /// Label for the Edit category.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get toolsCategoryEdit;

  /// Label for the Convert category.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get toolsCategoryConvert;

  /// Label for the Optimize category.
  ///
  /// In en, this message translates to:
  /// **'Optimize'**
  String get toolsCategoryOptimize;

  /// Label for the Security category.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get toolsCategorySecurity;

  /// Label for the filter option that shows tools from every category.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get toolsCategoryAll;

  /// Introductory description shown on the Tools screen.
  ///
  /// In en, this message translates to:
  /// **'Combine, split, convert, optimize and secure your PDFs — all processed locally on your device.'**
  String get toolsIntro;

  /// Short description for the Merge PDF tool.
  ///
  /// In en, this message translates to:
  /// **'Combine multiple PDF files into one document.'**
  String get toolsMergePdfDescription;

  /// Short description for the Split PDF tool.
  ///
  /// In en, this message translates to:
  /// **'Divide a PDF into multiple separate documents.'**
  String get toolsSplitPdfDescription;

  /// Short description for the Extract Pages tool.
  ///
  /// In en, this message translates to:
  /// **'Pull selected pages out into a new PDF.'**
  String get toolsExtractPdfDescription;

  /// Short description for the Compress PDF tool.
  ///
  /// In en, this message translates to:
  /// **'Reduce file size while keeping quality.'**
  String get toolsCompressPdfDescription;

  /// Short description for the PDF to Image tool.
  ///
  /// In en, this message translates to:
  /// **'Convert each PDF page into an image file.'**
  String get toolsPdfToImageDescription;

  /// Short description for the Image to PDF tool.
  ///
  /// In en, this message translates to:
  /// **'Turn one or more images into a PDF.'**
  String get toolsImageToPdfDescription;

  /// Short description for the Rotate PDF tool.
  ///
  /// In en, this message translates to:
  /// **'Rotate individual pages or a whole document.'**
  String get toolsRotatePdfDescription;

  /// Short description for the Protect PDF tool.
  ///
  /// In en, this message translates to:
  /// **'Add a password so only intended viewers can open it.'**
  String get toolsProtectPdfDescription;

  /// Short description for the Unlock PDF tool.
  ///
  /// In en, this message translates to:
  /// **'Remove a password from a protected PDF.'**
  String get toolsUnlockPdfDescription;

  /// Short description for the Watermark tool.
  ///
  /// In en, this message translates to:
  /// **'Stamp your pages with text or an image mark.'**
  String get toolsWatermarkDescription;

  /// Introductory description for the Merge PDF tool page.
  ///
  /// In en, this message translates to:
  /// **'Combine multiple PDF files into one document.'**
  String get toolsMergeIntro;

  /// Heading for the input files section on a PDF tool page.
  ///
  /// In en, this message translates to:
  /// **'Input PDFs'**
  String get toolsInputSectionTitle;

  /// Label for the button that adds more input PDF files.
  ///
  /// In en, this message translates to:
  /// **'Add files'**
  String get toolsAddFiles;

  /// Empty state title shown before any input files are added.
  ///
  /// In en, this message translates to:
  /// **'No files added'**
  String get toolsNoFilesTitle;

  /// Empty state description for the input files section.
  ///
  /// In en, this message translates to:
  /// **'Add one or more PDF files to combine them.'**
  String get toolsMergeNoFilesDescription;

  /// Heading for the output settings section on a PDF tool page.
  ///
  /// In en, this message translates to:
  /// **'Output'**
  String get toolsOutputSectionTitle;

  /// Label for the output file name field.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get toolsOutputFileNameLabel;

  /// Label for the button that lets the user choose where to save the result.
  ///
  /// In en, this message translates to:
  /// **'Choose folder'**
  String get toolsChooseFolder;

  /// Hint shown when no output folder has been selected yet.
  ///
  /// In en, this message translates to:
  /// **'Choose an output folder'**
  String get toolsChooseOutputFolder;

  /// Helper text shown when no output folder is selected.
  ///
  /// In en, this message translates to:
  /// **'Select where the output files should be saved.'**
  String get toolsOutputPathHint;

  /// Shows the full path of the file that will be created.
  ///
  /// In en, this message translates to:
  /// **'Will save as {path}'**
  String toolsWillSaveAs(String path);

  /// Label for the primary merge action button.
  ///
  /// In en, this message translates to:
  /// **'Merge PDF'**
  String get toolsMergeButton;

  /// Label shown on the merge button while merging is in progress.
  ///
  /// In en, this message translates to:
  /// **'Merging…'**
  String get toolsMergeSubmitting;

  /// Tooltip shown when the merge action cannot run yet.
  ///
  /// In en, this message translates to:
  /// **'Add files and choose an output location to continue.'**
  String get toolsMergeButtonDisabledHint;

  /// Tooltip for removing an input file from a tool list.
  ///
  /// In en, this message translates to:
  /// **'Remove file'**
  String get toolsRemoveFile;

  /// Label for the optional page range selection field.
  ///
  /// In en, this message translates to:
  /// **'Page Selection'**
  String get toolsPagesLabel;

  /// Placeholder example for the page range field.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1-5, 8, last'**
  String get toolsPagesHint;

  /// Count of selected input files shown next to the section heading.
  ///
  /// In en, this message translates to:
  /// **'{count} files'**
  String toolsFileCount(int count);

  /// Warning shown when the user tries to merge with no input files.
  ///
  /// In en, this message translates to:
  /// **'Add at least one PDF file to merge.'**
  String get toolsMergeWarningNoFiles;

  /// Warning shown when the user tries to merge without an output folder.
  ///
  /// In en, this message translates to:
  /// **'Choose an output folder.'**
  String get toolsMergeWarningNoFolder;

  /// Warning shown when the output file name is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter an output file name.'**
  String get toolsMergeWarningNoFileName;

  /// Notification shown when merging completes successfully.
  ///
  /// In en, this message translates to:
  /// **'PDF merged successfully.'**
  String get toolsMergeSuccess;

  /// Notification shown when merging fails.
  ///
  /// In en, this message translates to:
  /// **'Could not merge the PDFs.'**
  String get toolsMergeFailed;

  /// Notification shown when a page range is invalid.
  ///
  /// In en, this message translates to:
  /// **'Check the page selection for {file}.'**
  String toolsMergePageSelectionInvalid(String file);

  /// Label for the button to select a source file.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get toolsChooseFile;

  /// Label for the button to replace an already selected source file.
  ///
  /// In en, this message translates to:
  /// **'Replace file'**
  String get toolsReplaceFile;

  /// Placeholder shown when no source file has been selected.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get toolsNoFileSelected;

  /// Helper text shown under an empty source file picker.
  ///
  /// In en, this message translates to:
  /// **'Choose a file to get started'**
  String get toolsChooseFileHint;

  /// Introductory description for the Split PDF tool page.
  ///
  /// In en, this message translates to:
  /// **'Divide a PDF into multiple separate documents.'**
  String get toolsSplitIntro;

  /// Heading for the source file section on the Split PDF page.
  ///
  /// In en, this message translates to:
  /// **'Source PDF'**
  String get toolsSplitSourceSectionTitle;

  /// Heading for the split mode selector section.
  ///
  /// In en, this message translates to:
  /// **'Split mode'**
  String get toolsSplitModeSectionTitle;

  /// Label for the mode that splits a PDF every N pages.
  ///
  /// In en, this message translates to:
  /// **'By page count'**
  String get toolsSplitModeByPageCount;

  /// Label for the mode that splits a PDF into the given page groups.
  ///
  /// In en, this message translates to:
  /// **'By selection'**
  String get toolsSplitModeBySelection;

  /// Label for the mode that saves every page as its own PDF.
  ///
  /// In en, this message translates to:
  /// **'Extract all pages'**
  String get toolsSplitModeExtractAll;

  /// Label for the number of pages in each output PDF.
  ///
  /// In en, this message translates to:
  /// **'Pages per file'**
  String get toolsSplitPagesPerFileLabel;

  /// Placeholder example for the pages-per-file field.
  ///
  /// In en, this message translates to:
  /// **'e.g. 5'**
  String get toolsSplitPagesPerFileHint;

  /// Label for the button that adds another page selection group.
  ///
  /// In en, this message translates to:
  /// **'Add pages'**
  String get toolsSplitSelectionAdd;

  /// Helper text shown when no page selection groups are added yet.
  ///
  /// In en, this message translates to:
  /// **'Add groups of pages — each group becomes its own PDF.'**
  String get toolsSplitSelectionHint;

  /// Tooltip for removing a page selection group.
  ///
  /// In en, this message translates to:
  /// **'Remove pages'**
  String get toolsSplitSelectionRemove;

  /// Info text shown for the extract-all-pages split mode.
  ///
  /// In en, this message translates to:
  /// **'Every page will be saved as its own separate PDF file.'**
  String get toolsSplitExtractAllInfo;

  /// Label for the primary split action button.
  ///
  /// In en, this message translates to:
  /// **'Split PDF'**
  String get toolsSplitButton;

  /// Label shown on the split button while splitting is in progress.
  ///
  /// In en, this message translates to:
  /// **'Splitting…'**
  String get toolsSplitSubmitting;

  /// Tooltip shown when the split action cannot run yet.
  ///
  /// In en, this message translates to:
  /// **'Choose a file, a split option and an output location to continue.'**
  String get toolsSplitButtonDisabledHint;

  /// Warning shown when trying to split with no source file.
  ///
  /// In en, this message translates to:
  /// **'Choose a PDF file to split.'**
  String get toolsSplitWarningNoFile;

  /// Warning shown when trying to split without an output folder.
  ///
  /// In en, this message translates to:
  /// **'Choose an output folder.'**
  String get toolsSplitWarningNoFolder;

  /// Warning shown when the pages-per-file value is invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a page count greater than zero.'**
  String get toolsSplitWarningPagesPerFile;

  /// Warning shown when trying to split without page selections.
  ///
  /// In en, this message translates to:
  /// **'Add at least one page selection.'**
  String get toolsSplitWarningNoSelection;

  /// Notification shown when splitting completes successfully.
  ///
  /// In en, this message translates to:
  /// **'PDF split into {count} files.'**
  String toolsSplitSuccess(int count);

  /// Notification shown when splitting fails.
  ///
  /// In en, this message translates to:
  /// **'Could not split the PDF.'**
  String get toolsSplitFailed;

  /// Notification shown when a page selection group is invalid.
  ///
  /// In en, this message translates to:
  /// **'Check your page selections.'**
  String get toolsSplitSelectionInvalid;
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
