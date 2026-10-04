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

  /// Warning shown when the user tries to extract with no input file.
  ///
  /// In en, this message translates to:
  /// **'Choose a pdf file to extract.'**
  String get toolsExtractWarningNoFile;

  /// Warning shown when the user tries to extract without an output folder.
  ///
  /// In en, this message translates to:
  /// **'Choose an output folder.'**
  String get toolsExtractWarningNoFolder;

  /// Warning shown when the output file name is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter an output file name.'**
  String get toolsExtractWarningNoFileName;

  /// Notification shown when extraction completes successfully.
  ///
  /// In en, this message translates to:
  /// **'PDF extracted successfully.'**
  String get toolsExtractSuccess;

  /// Notification shown when pdf extraction fails.
  ///
  /// In en, this message translates to:
  /// **'Could not extract from the PDF.'**
  String get toolsExtractFailed;

  /// Label for the primary extract action button.
  ///
  /// In en, this message translates to:
  /// **'Extract PDF'**
  String get toolsExtractButton;

  /// Intro description shown at the top of the Extract Pages page.
  ///
  /// In en, this message translates to:
  /// **'Pull selected pages out into a new PDF.'**
  String get toolsExtractIntro;

  /// Heading for the source file section on the Extract Pages page.
  ///
  /// In en, this message translates to:
  /// **'Source PDF'**
  String get toolsExtractSourceSectionTitle;

  /// Heading for the page selection section on the Extract Pages page.
  ///
  /// In en, this message translates to:
  /// **'Pages to extract'**
  String get toolsExtractSelectionSectionTitle;

  /// Hint text for the page selection field.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1-5, 8, last'**
  String get toolsExtractSelectionHint;

  /// Label shown on the extract button while extraction is running.
  ///
  /// In en, this message translates to:
  /// **'Extracting…'**
  String get toolsExtractSubmitting;

  /// Tooltip explaining why the extract button is disabled.
  ///
  /// In en, this message translates to:
  /// **'Choose a file, pages and an output location to continue.'**
  String get toolsExtractButtonDisabledHint;

  /// Warning shown when the page selection cannot be parsed.
  ///
  /// In en, this message translates to:
  /// **'Check the pages you want to extract.'**
  String get toolsExtractSelectionInvalid;

  /// Introductory description shown at the top of the Rotate PDF page.
  ///
  /// In en, this message translates to:
  /// **'Turn pages a quarter, half or three quarters of the way around.'**
  String get toolsRotateIntro;

  /// Heading for the source file section on the Rotate PDF page.
  ///
  /// In en, this message translates to:
  /// **'Source PDF'**
  String get toolsRotateSourceSectionTitle;

  /// Heading for the rotation direction selector on the Rotate PDF page.
  ///
  /// In en, this message translates to:
  /// **'Rotation'**
  String get toolsRotateDirectionSectionTitle;

  /// Label for the 90 degree clockwise rotation option.
  ///
  /// In en, this message translates to:
  /// **'90° clockwise'**
  String get toolsRotateDirection90;

  /// Label for the 180 degree (upside down) rotation option.
  ///
  /// In en, this message translates to:
  /// **'180°'**
  String get toolsRotateDirection180;

  /// Label for the 90 degree counter-clockwise rotation option.
  ///
  /// In en, this message translates to:
  /// **'90° counter-clockwise'**
  String get toolsRotateDirection270;

  /// Heading for the page scope selector on the Rotate PDF page.
  ///
  /// In en, this message translates to:
  /// **'Pages to rotate'**
  String get toolsRotatePagesSectionTitle;

  /// Option to rotate every page of the document.
  ///
  /// In en, this message translates to:
  /// **'All pages'**
  String get toolsRotateScopeAll;

  /// Option to rotate only the pages entered in the selection field.
  ///
  /// In en, this message translates to:
  /// **'Selected pages'**
  String get toolsRotateScopeSelected;

  /// Hint text for the rotation page selection field.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1-5, 8, last'**
  String get toolsRotateSelectionHint;

  /// Helper text explaining the effect of a partial page selection.
  ///
  /// In en, this message translates to:
  /// **'Only the pages you pick are turned. Everything else stays as it is.'**
  String get toolsRotateSelectionHelper;

  /// Warning shown when the rotation page selection cannot be parsed.
  ///
  /// In en, this message translates to:
  /// **'Check the pages you want to rotate.'**
  String get toolsRotateSelectionInvalid;

  /// Warning shown when the user tries to rotate with no input file.
  ///
  /// In en, this message translates to:
  /// **'Choose a pdf file to rotate.'**
  String get toolsRotateWarningNoFile;

  /// Warning shown when the user tries to rotate without an output folder.
  ///
  /// In en, this message translates to:
  /// **'Choose an output folder.'**
  String get toolsRotateWarningNoFolder;

  /// Warning shown when the output file name is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter an output file name.'**
  String get toolsRotateWarningNoFileName;

  /// Warning shown when the page scope requires a selection but none was given.
  ///
  /// In en, this message translates to:
  /// **'Enter the pages you want to rotate.'**
  String get toolsRotateWarningNoSelection;

  /// Notification shown when rotation completes successfully.
  ///
  /// In en, this message translates to:
  /// **'PDF rotated successfully.'**
  String get toolsRotateSuccess;

  /// Notification shown when rotation fails.
  ///
  /// In en, this message translates to:
  /// **'Could not rotate the PDF.'**
  String get toolsRotateFailed;

  /// Label for the primary rotate action button.
  ///
  /// In en, this message translates to:
  /// **'Rotate PDF'**
  String get toolsRotateButton;

  /// Label shown on the rotate button while rotation is running.
  ///
  /// In en, this message translates to:
  /// **'Rotating…'**
  String get toolsRotateSubmitting;

  /// Tooltip explaining why the rotate button is disabled.
  ///
  /// In en, this message translates to:
  /// **'Choose a file, a rotation and an output location to continue.'**
  String get toolsRotateButtonDisabledHint;

  /// Introductory description for the PDF to Image tool page.
  ///
  /// In en, this message translates to:
  /// **'Convert the pages of a PDF into image files.'**
  String get toolsPdfToImageIntro;

  /// Heading for the source file section on the PDF to Image page.
  ///
  /// In en, this message translates to:
  /// **'Source PDF'**
  String get toolsPdfToImageSourceSectionTitle;

  /// Heading for the image format selector on the PDF to Image page.
  ///
  /// In en, this message translates to:
  /// **'Image format'**
  String get toolsPdfToImageFormatSectionTitle;

  /// Label for the PNG image format option.
  ///
  /// In en, this message translates to:
  /// **'PNG'**
  String get toolsPdfToImageFormatPng;

  /// Label for the JPEG image format option.
  ///
  /// In en, this message translates to:
  /// **'JPEG'**
  String get toolsPdfToImageFormatJpeg;

  /// Label for the WebP image format option.
  ///
  /// In en, this message translates to:
  /// **'WebP'**
  String get toolsPdfToImageFormatWebp;

  /// Helper text explaining the differences between the supported image formats.
  ///
  /// In en, this message translates to:
  /// **'PNG keeps every detail but produces larger files. JPEG and WebP are smaller thanks to the quality setting.'**
  String get toolsPdfToImageFormatHelper;

  /// Heading for the colour mode selector on the PDF to Image page.
  ///
  /// In en, this message translates to:
  /// **'Colour mode'**
  String get toolsPdfToImageColorSectionTitle;

  /// Option to render the pages in full colour.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get toolsPdfToImageColorModeColor;

  /// Option to render the pages in greyscale.
  ///
  /// In en, this message translates to:
  /// **'Greyscale'**
  String get toolsPdfToImageColorModeGreyscale;

  /// Heading for the resolution and quality settings on the PDF to Image page.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get toolsPdfToImageResolutionSectionTitle;

  /// Label for the resolution selector on the PDF to Image page.
  ///
  /// In en, this message translates to:
  /// **'Resolution (DPI)'**
  String get toolsPdfToImageDpiLabel;

  /// Helper text explaining the effect of the resolution setting.
  ///
  /// In en, this message translates to:
  /// **'Higher resolutions look sharper but take longer and use more disk space.'**
  String get toolsPdfToImageDpiHelper;

  /// Label for the image quality slider on the PDF to Image page.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get toolsPdfToImageQualityLabel;

  /// Helper text explaining that quality does not apply to PNG.
  ///
  /// In en, this message translates to:
  /// **'Applies to JPEG and WebP only. PNG is always lossless.'**
  String get toolsPdfToImageQualityHelper;

  /// Heading for the page scope selector on the PDF to Image page.
  ///
  /// In en, this message translates to:
  /// **'Pages to convert'**
  String get toolsPdfToImagePagesSectionTitle;

  /// Option to convert every page of the document.
  ///
  /// In en, this message translates to:
  /// **'All pages'**
  String get toolsPdfToImageScopeAll;

  /// Option to convert only the pages entered in the selection field.
  ///
  /// In en, this message translates to:
  /// **'Selected pages'**
  String get toolsPdfToImageScopeSelected;

  /// Hint text for the PDF to Image page selection field.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1-5, 8, last'**
  String get toolsPdfToImageSelectionHint;

  /// Helper text explaining that every page becomes a separate image file.
  ///
  /// In en, this message translates to:
  /// **'Each selected page is written as its own image file.'**
  String get toolsPdfToImageSelectionHelper;

  /// Warning shown when the PDF to Image page selection cannot be parsed.
  ///
  /// In en, this message translates to:
  /// **'Check the pages you want to convert.'**
  String get toolsPdfToImageSelectionInvalid;

  /// Warning shown when the user tries to convert with no input file.
  ///
  /// In en, this message translates to:
  /// **'Choose a pdf file to convert.'**
  String get toolsPdfToImageWarningNoFile;

  /// Warning shown when the user tries to convert without an output folder.
  ///
  /// In en, this message translates to:
  /// **'Choose an output folder.'**
  String get toolsPdfToImageWarningNoFolder;

  /// Warning shown when the page scope requires a selection but none was given.
  ///
  /// In en, this message translates to:
  /// **'Enter the pages you want to convert.'**
  String get toolsPdfToImageWarningNoSelection;

  /// Notification shown when the conversion completes successfully.
  ///
  /// In en, this message translates to:
  /// **'Created {count} image files.'**
  String toolsPdfToImageSuccess(int count);

  /// Notification shown when the conversion fails.
  ///
  /// In en, this message translates to:
  /// **'Could not convert the PDF to images.'**
  String get toolsPdfToImageFailed;

  /// Label for the primary convert action button.
  ///
  /// In en, this message translates to:
  /// **'Convert to Images'**
  String get toolsPdfToImageButton;

  /// Label shown on the convert button while the conversion is running.
  ///
  /// In en, this message translates to:
  /// **'Converting…'**
  String get toolsPdfToImageSubmitting;

  /// Tooltip explaining why the convert button is disabled.
  ///
  /// In en, this message translates to:
  /// **'Choose a file and an output location to continue.'**
  String get toolsPdfToImageButtonDisabledHint;

  /// Intro text shown at the top of the Image to PDF tool page.
  ///
  /// In en, this message translates to:
  /// **'Combine images into a single PDF document.'**
  String get toolsImageToPdfIntro;

  /// Heading for the image selection section on the Image to PDF tool page.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get toolsImageToPdfSourceSectionTitle;

  /// Tool-specific copy shown when no image has been added yet.
  ///
  /// In en, this message translates to:
  /// **'Add one or more images to combine them into a PDF.'**
  String get toolsImageToPdfNoImagesDescription;

  /// Accessibility label for the list/grid view mode toggle.
  ///
  /// In en, this message translates to:
  /// **'View mode'**
  String get toolsImageToPdfViewModeLabel;

  /// Tooltip for switching the selected images to list view.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get toolsImageToPdfViewModeList;

  /// Tooltip for switching the selected images to grid view.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get toolsImageToPdfViewModeGrid;

  /// Heading for the page setup section on the Image to PDF tool page.
  ///
  /// In en, this message translates to:
  /// **'Page setup'**
  String get toolsImageToPdfPageSetupSectionTitle;

  /// Label for the page size selector.
  ///
  /// In en, this message translates to:
  /// **'Page size'**
  String get toolsImageToPdfPageSizeLabel;

  /// Page size option that matches each image to the page.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get toolsImageToPdfPageSizeAuto;

  /// A4 page size option.
  ///
  /// In en, this message translates to:
  /// **'A4'**
  String get toolsImageToPdfPageSizeA4;

  /// Letter page size option.
  ///
  /// In en, this message translates to:
  /// **'Letter'**
  String get toolsImageToPdfPageSizeLetter;

  /// Helper text explaining the page size options.
  ///
  /// In en, this message translates to:
  /// **'Auto sizes every page to match its image. A4 and Letter give every page the same size.'**
  String get toolsImageToPdfPageSizeHelper;

  /// Label for the orientation selector.
  ///
  /// In en, this message translates to:
  /// **'Orientation'**
  String get toolsImageToPdfOrientationLabel;

  /// Orientation option that follows the shape of each image.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get toolsImageToPdfOrientationAuto;

  /// Portrait orientation option.
  ///
  /// In en, this message translates to:
  /// **'Portrait'**
  String get toolsImageToPdfOrientationPortrait;

  /// Landscape orientation option.
  ///
  /// In en, this message translates to:
  /// **'Landscape'**
  String get toolsImageToPdfOrientationLandscape;

  /// Helper text explaining the orientation options.
  ///
  /// In en, this message translates to:
  /// **'Auto turns each page to match its image. Portrait and landscape force the same direction for every page.'**
  String get toolsImageToPdfOrientationHelper;

  /// Label for the image fit selector.
  ///
  /// In en, this message translates to:
  /// **'Image fit'**
  String get toolsImageToPdfFitLabel;

  /// Image fit option that scales the whole image onto the page.
  ///
  /// In en, this message translates to:
  /// **'Fit page'**
  String get toolsImageToPdfFitContain;

  /// Image fit option that fills the page and crops the overflow.
  ///
  /// In en, this message translates to:
  /// **'Fill page'**
  String get toolsImageToPdfFitCover;

  /// Image fit option that stretches the image to the page.
  ///
  /// In en, this message translates to:
  /// **'Stretch'**
  String get toolsImageToPdfFitStretch;

  /// Helper text explaining the image fit options.
  ///
  /// In en, this message translates to:
  /// **'Fit page keeps the whole image visible, fill page crops it, and stretch distorts it to fill the page.'**
  String get toolsImageToPdfFitHelper;

  /// Warning shown when the user tries to convert with no images.
  ///
  /// In en, this message translates to:
  /// **'Add at least one image to convert.'**
  String get toolsImageToPdfWarningNoImages;

  /// Warning shown when the user tries to convert with no output folder.
  ///
  /// In en, this message translates to:
  /// **'Choose an output folder.'**
  String get toolsImageToPdfWarningNoFolder;

  /// Warning shown when the user tries to convert with no output file name.
  ///
  /// In en, this message translates to:
  /// **'Enter an output file name.'**
  String get toolsImageToPdfWarningNoFileName;

  /// Success message shown once the images have been converted. {count} is the number of images.
  ///
  /// In en, this message translates to:
  /// **'Created a PDF from {count} images.'**
  String toolsImageToPdfSuccess(int count);

  /// Error shown when the conversion fails.
  ///
  /// In en, this message translates to:
  /// **'Could not convert the images to a PDF.'**
  String get toolsImageToPdfFailed;

  /// Label for the main action button of the Image to PDF tool.
  ///
  /// In en, this message translates to:
  /// **'Create PDF'**
  String get toolsImageToPdfButton;

  /// Label shown while the images are being converted.
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get toolsImageToPdfSubmitting;

  /// Tooltip explaining why the create button is disabled.
  ///
  /// In en, this message translates to:
  /// **'Add images and choose an output location to continue.'**
  String get toolsImageToPdfButtonDisabledHint;

  /// Introductory description shown at the top of the Protect PDF page.
  ///
  /// In en, this message translates to:
  /// **'Add a password and choose what viewers are allowed to do.'**
  String get toolsProtectIntro;

  /// Heading for the source file section on the Protect PDF page.
  ///
  /// In en, this message translates to:
  /// **'Source PDF'**
  String get toolsProtectSourceSectionTitle;

  /// Tool-specific copy shown in the Protect PDF empty state.
  ///
  /// In en, this message translates to:
  /// **'Choose a PDF that is not password protected yet.'**
  String get toolsProtectAlreadyProtectedDescription;

  /// Heading for the password section on the Protect PDF page.
  ///
  /// In en, this message translates to:
  /// **'Passwords'**
  String get toolsProtectPasswordSectionTitle;

  /// Label for the field holding the password required to open the document.
  ///
  /// In en, this message translates to:
  /// **'Password to open'**
  String get toolsProtectUserPasswordLabel;

  /// Helper text explaining that an empty open password only restricts permissions.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to let anyone open the document, while the permissions below still apply.'**
  String get toolsProtectUserPasswordHelper;

  /// Label for the field holding the password that lifts the restrictions.
  ///
  /// In en, this message translates to:
  /// **'Owner password'**
  String get toolsProtectOwnerPasswordLabel;

  /// Helper text explaining the random owner password default.
  ///
  /// In en, this message translates to:
  /// **'Optional. Leave empty and a random owner password is generated, so nobody can lift the restrictions.'**
  String get toolsProtectOwnerPasswordHelper;

  /// Heading for the protection settings section on the Protect PDF page.
  ///
  /// In en, this message translates to:
  /// **'Protection'**
  String get toolsProtectSecuritySectionTitle;

  /// Label for the encryption level selector.
  ///
  /// In en, this message translates to:
  /// **'Encryption'**
  String get toolsProtectEncryptionLabel;

  /// Label for the AES-256 encryption level option.
  ///
  /// In en, this message translates to:
  /// **'AES-256'**
  String get toolsProtectEncryptionAes256;

  /// Label for the AES-128 encryption level option.
  ///
  /// In en, this message translates to:
  /// **'AES-128'**
  String get toolsProtectEncryptionAes128;

  /// Label for the RC4 128 bit encryption level option.
  ///
  /// In en, this message translates to:
  /// **'RC4-128'**
  String get toolsProtectEncryptionRc4;

  /// Helper text explaining the differences between the encryption levels.
  ///
  /// In en, this message translates to:
  /// **'AES-256 is what every current reader supports. Choose an older level only for software that cannot manage it.'**
  String get toolsProtectEncryptionHelper;

  /// Label for the permissions preset selector.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get toolsProtectPermissionsLabel;

  /// Permission preset that grants every capability.
  ///
  /// In en, this message translates to:
  /// **'Allow everything'**
  String get toolsProtectPermissionsAll;

  /// Permission preset that allows printing but no editing.
  ///
  /// In en, this message translates to:
  /// **'Allow printing'**
  String get toolsProtectPermissionsReadOnly;

  /// Permission preset that allows viewing only.
  ///
  /// In en, this message translates to:
  /// **'Allow nothing'**
  String get toolsProtectPermissionsNone;

  /// Helper text explaining how permissions are enforced.
  ///
  /// In en, this message translates to:
  /// **'Permissions are enforced by the viewer, not by the file. Anyone holding the owner password is unaffected.'**
  String get toolsProtectPermissionsHelper;

  /// Warning shown when the user tries to protect with no input file.
  ///
  /// In en, this message translates to:
  /// **'Choose a pdf file to protect.'**
  String get toolsProtectWarningNoFile;

  /// Warning shown when the user tries to protect without an output folder.
  ///
  /// In en, this message translates to:
  /// **'Choose an output folder.'**
  String get toolsProtectWarningNoFolder;

  /// Warning shown when the output file name is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter an output file name.'**
  String get toolsProtectWarningNoFileName;

  /// Warning shown when the chosen settings would not protect anything.
  ///
  /// In en, this message translates to:
  /// **'Choose a password or restrict what viewers can do.'**
  String get toolsProtectWarningNoProtection;

  /// Warning shown when the open and owner passwords are identical.
  ///
  /// In en, this message translates to:
  /// **'The two passwords are the same. Use different ones, or leave the owner password empty.'**
  String get toolsProtectWarningPasswordsMatch;

  /// Notification shown when the source document already carries an /Encrypt entry.
  ///
  /// In en, this message translates to:
  /// **'That document is already protected. Remove its password first.'**
  String get toolsProtectAlreadyEncrypted;

  /// Notification shown when protection completes successfully.
  ///
  /// In en, this message translates to:
  /// **'PDF protected successfully.'**
  String get toolsProtectSuccess;

  /// Notification shown when protection fails.
  ///
  /// In en, this message translates to:
  /// **'Could not protect the PDF.'**
  String get toolsProtectFailed;

  /// Label for the primary protect action button.
  ///
  /// In en, this message translates to:
  /// **'Protect PDF'**
  String get toolsProtectButton;

  /// Label shown on the protect button while protection is running.
  ///
  /// In en, this message translates to:
  /// **'Protecting…'**
  String get toolsProtectSubmitting;

  /// Tooltip explaining why the protect button is disabled.
  ///
  /// In en, this message translates to:
  /// **'Choose a file and an output location to continue.'**
  String get toolsProtectButtonDisabledHint;

  /// Introductory description shown at the top of the Unlock PDF page.
  ///
  /// In en, this message translates to:
  /// **'Remove the password and the restrictions from a protected PDF.'**
  String get toolsUnlockIntro;

  /// Heading for the source file section on the Unlock PDF page.
  ///
  /// In en, this message translates to:
  /// **'Source PDF'**
  String get toolsUnlockSourceSectionTitle;

  /// Tool-specific copy shown in the Unlock PDF empty state.
  ///
  /// In en, this message translates to:
  /// **'Choose a PDF that is password protected.'**
  String get toolsUnlockAlreadyProtectedDescription;

  /// Heading for the password section on the Unlock PDF page.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get toolsUnlockPasswordSectionTitle;

  /// Label for the field holding the current document password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get toolsUnlockPasswordLabel;

  /// Helper text explaining that the password may be empty for permission-only documents.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for documents that are restricted but open without a password.'**
  String get toolsUnlockPasswordHelper;

  /// Warning shown when the user tries to unlock with no input file.
  ///
  /// In en, this message translates to:
  /// **'Choose a pdf file to unlock.'**
  String get toolsUnlockWarningNoFile;

  /// Warning shown when the user tries to unlock without an output folder.
  ///
  /// In en, this message translates to:
  /// **'Choose an output folder.'**
  String get toolsUnlockWarningNoFolder;

  /// Warning shown when the output file name is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter an output file name.'**
  String get toolsUnlockWarningNoFileName;

  /// Notification shown when the supplied password fails authentication.
  ///
  /// In en, this message translates to:
  /// **'That password does not open this document.'**
  String get toolsUnlockWrongPassword;

  /// Notification shown when the source document has no /Encrypt entry.
  ///
  /// In en, this message translates to:
  /// **'That document is not password protected.'**
  String get toolsUnlockNotEncrypted;

  /// Notification shown when unlocking completes successfully.
  ///
  /// In en, this message translates to:
  /// **'PDF unlocked successfully.'**
  String get toolsUnlockSuccess;

  /// Notification shown when unlocking fails.
  ///
  /// In en, this message translates to:
  /// **'Could not unlock the PDF.'**
  String get toolsUnlockFailed;

  /// Label for the primary unlock action button.
  ///
  /// In en, this message translates to:
  /// **'Unlock PDF'**
  String get toolsUnlockButton;

  /// Label shown on the unlock button while unlocking is running.
  ///
  /// In en, this message translates to:
  /// **'Unlocking…'**
  String get toolsUnlockSubmitting;

  /// Tooltip explaining why the unlock button is disabled.
  ///
  /// In en, this message translates to:
  /// **'Choose a file and an output location to continue.'**
  String get toolsUnlockButtonDisabledHint;

  /// Tooltip explaining why the compress button is disabled.
  ///
  /// In en, this message translates to:
  /// **'Choose a file and an output location to continue.'**
  String get toolsCompressButtonDisabledHint;

  /// Introductory description shown at the top of the Compress PDF tool.
  ///
  /// In en, this message translates to:
  /// **'Reduce the file size of a PDF while keeping its quality.'**
  String get toolsCompressIntro;

  /// Section title for the source file picker.
  ///
  /// In en, this message translates to:
  /// **'Source PDF'**
  String get toolsCompressSourceSectionTitle;

  /// Empty state description for the source file picker.
  ///
  /// In en, this message translates to:
  /// **'Choose a PDF to compress.'**
  String get toolsCompressSourceDescription;

  /// Section title for the quality slider.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get toolsCompressQualitySectionTitle;

  /// Label next to the quality slider.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get toolsCompressQualityLabel;

  /// Helper text explaining what the quality setting does.
  ///
  /// In en, this message translates to:
  /// **'A lower quality compresses more. Text stays sharp either way.'**
  String get toolsCompressQualityHelper;

  /// Warning shown when no input file has been chosen.
  ///
  /// In en, this message translates to:
  /// **'Choose a pdf file to compress.'**
  String get toolsCompressWarningNoFile;

  /// Warning shown when no output folder has been chosen.
  ///
  /// In en, this message translates to:
  /// **'Choose an output folder.'**
  String get toolsCompressWarningNoFolder;

  /// Warning shown when the output file name is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter an output file name.'**
  String get toolsCompressWarningNoFileName;

  /// Warning shown when the source document is encrypted.
  ///
  /// In en, this message translates to:
  /// **'Password protected PDFs cannot be compressed.'**
  String get toolsCompressEncrypted;

  /// Notification shown when compressing completes successfully.
  ///
  /// In en, this message translates to:
  /// **'PDF compressed successfully.'**
  String get toolsCompressSuccess;

  /// Notification shown when compressing fails.
  ///
  /// In en, this message translates to:
  /// **'Could not compress the PDF.'**
  String get toolsCompressFailed;

  /// Label for the primary compress action button.
  ///
  /// In en, this message translates to:
  /// **'Compress PDF'**
  String get toolsCompressButton;

  /// Label shown on the compress button while compressing is running.
  ///
  /// In en, this message translates to:
  /// **'Compressing…'**
  String get toolsCompressSubmitting;

  /// Introductory description shown at the top of the Watermark tool.
  ///
  /// In en, this message translates to:
  /// **'Stamp text or an image over the pages of a PDF.'**
  String get toolsWatermarkIntro;

  /// Heading for the source file section on the Watermark page.
  ///
  /// In en, this message translates to:
  /// **'Source PDF'**
  String get toolsWatermarkSourceSectionTitle;

  /// Empty state copy for the source file picker on the Watermark page.
  ///
  /// In en, this message translates to:
  /// **'Choose a PDF to watermark.'**
  String get toolsWatermarkSourceDescription;

  /// Heading for the watermark type section on the Watermark page.
  ///
  /// In en, this message translates to:
  /// **'Watermark'**
  String get toolsWatermarkTypeSectionTitle;

  /// Option to stamp a text watermark.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get toolsWatermarkTypeText;

  /// Option to stamp an image watermark.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get toolsWatermarkTypeImage;

  /// Label for the watermark text field.
  ///
  /// In en, this message translates to:
  /// **'Watermark text'**
  String get toolsWatermarkTextLabel;

  /// Hint text for the watermark text field.
  ///
  /// In en, this message translates to:
  /// **'e.g. CONFIDENTIAL'**
  String get toolsWatermarkTextHint;

  /// Label for the watermark font dropdown.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get toolsWatermarkFontLabel;

  /// Option that lets the engine pick the default watermark font.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get toolsWatermarkFontDefault;

  /// Label for the watermark font size slider.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get toolsWatermarkFontSizeLabel;

  /// Label for the watermark color picker.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get toolsWatermarkColorLabel;

  /// Hint text for the watermark hexadecimal color field.
  ///
  /// In en, this message translates to:
  /// **'#RRGGBB'**
  String get toolsWatermarkColorHint;

  /// Error text shown when the hexadecimal color is malformed.
  ///
  /// In en, this message translates to:
  /// **'Enter a color like #808080.'**
  String get toolsWatermarkColorInvalid;

  /// Empty state copy for the watermark image picker.
  ///
  /// In en, this message translates to:
  /// **'Choose an image to stamp on the pages.'**
  String get toolsWatermarkImageDescription;

  /// Button label for picking a watermark image.
  ///
  /// In en, this message translates to:
  /// **'Choose image'**
  String get toolsWatermarkImageChoose;

  /// Button label for replacing a chosen watermark image.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get toolsWatermarkImageReplace;

  /// Button label for clearing the chosen watermark image.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get toolsWatermarkImageRemove;

  /// Label for the watermark image width slider.
  ///
  /// In en, this message translates to:
  /// **'Image width'**
  String get toolsWatermarkImageWidthLabel;

  /// Helper text under the watermark image width slider.
  ///
  /// In en, this message translates to:
  /// **'Percentage of the page width the image covers.'**
  String get toolsWatermarkImageWidthHelper;

  /// Heading for the style section on the Watermark page.
  ///
  /// In en, this message translates to:
  /// **'Layout and style'**
  String get toolsWatermarkStyleSectionTitle;

  /// Label for the watermark opacity slider.
  ///
  /// In en, this message translates to:
  /// **'Opacity'**
  String get toolsWatermarkOpacityLabel;

  /// Label for the watermark rotation slider.
  ///
  /// In en, this message translates to:
  /// **'Rotation'**
  String get toolsWatermarkRotationLabel;

  /// Helper text under the watermark rotation slider.
  ///
  /// In en, this message translates to:
  /// **'Degrees. Negative values tilt the watermark upwards.'**
  String get toolsWatermarkRotationHelper;

  /// Label for the watermark position selector.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get toolsWatermarkPositionLabel;

  /// Position option that centers the watermark.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get toolsWatermarkPositionCenter;

  /// Position option that anchors the watermark to the top left.
  ///
  /// In en, this message translates to:
  /// **'Top left'**
  String get toolsWatermarkPositionTopLeft;

  /// Position option that anchors the watermark to the top right.
  ///
  /// In en, this message translates to:
  /// **'Top right'**
  String get toolsWatermarkPositionTopRight;

  /// Position option that anchors the watermark to the bottom left.
  ///
  /// In en, this message translates to:
  /// **'Bottom left'**
  String get toolsWatermarkPositionBottomLeft;

  /// Position option that anchors the watermark to the bottom right.
  ///
  /// In en, this message translates to:
  /// **'Bottom right'**
  String get toolsWatermarkPositionBottomRight;

  /// Label for the horizontal watermark offset slider.
  ///
  /// In en, this message translates to:
  /// **'X offset'**
  String get toolsWatermarkOffsetXLabel;

  /// Label for the vertical watermark offset slider.
  ///
  /// In en, this message translates to:
  /// **'Y offset'**
  String get toolsWatermarkOffsetYLabel;

  /// Helper text under the watermark offset sliders.
  ///
  /// In en, this message translates to:
  /// **'Shift the watermark from its anchor, in PDF points.'**
  String get toolsWatermarkOffsetHelper;

  /// Label for the watermark layer selector.
  ///
  /// In en, this message translates to:
  /// **'Layer'**
  String get toolsWatermarkLayerLabel;

  /// Option to draw the watermark above the page content.
  ///
  /// In en, this message translates to:
  /// **'On top'**
  String get toolsWatermarkLayerForeground;

  /// Option to draw the watermark below the page content.
  ///
  /// In en, this message translates to:
  /// **'Behind'**
  String get toolsWatermarkLayerBackground;

  /// Heading for the page scope selector on the Watermark page.
  ///
  /// In en, this message translates to:
  /// **'Pages to mark'**
  String get toolsWatermarkPagesSectionTitle;

  /// Option to stamp every page of the document.
  ///
  /// In en, this message translates to:
  /// **'All pages'**
  String get toolsWatermarkScopeAll;

  /// Option to stamp only the pages entered in the selection field.
  ///
  /// In en, this message translates to:
  /// **'Selected pages'**
  String get toolsWatermarkScopeSelected;

  /// Hint text for the Watermark page selection field.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1-5, 8, last'**
  String get toolsWatermarkSelectionHint;

  /// Helper text under the Watermark page selection field.
  ///
  /// In en, this message translates to:
  /// **'Switch to selected pages to mark only part of the document.'**
  String get toolsWatermarkSelectionHelper;

  /// Warning shown when no input file has been chosen.
  ///
  /// In en, this message translates to:
  /// **'Choose a pdf file to watermark.'**
  String get toolsWatermarkWarningNoFile;

  /// Warning shown when no output folder has been chosen.
  ///
  /// In en, this message translates to:
  /// **'Choose an output folder.'**
  String get toolsWatermarkWarningNoFolder;

  /// Warning shown when the output file name is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter an output file name.'**
  String get toolsWatermarkWarningNoFileName;

  /// Warning shown when a text watermark has no content.
  ///
  /// In en, this message translates to:
  /// **'Enter the text to stamp.'**
  String get toolsWatermarkWarningNoText;

  /// Warning shown when an image watermark has no image.
  ///
  /// In en, this message translates to:
  /// **'Choose a watermark image.'**
  String get toolsWatermarkWarningNoImage;

  /// Warning shown when the page selection field is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter the pages to mark.'**
  String get toolsWatermarkWarningNoSelection;

  /// Warning shown when the hexadecimal color is malformed.
  ///
  /// In en, this message translates to:
  /// **'Enter a color like #808080.'**
  String get toolsWatermarkWarningInvalidColor;

  /// Warning shown when the page selection cannot be parsed.
  ///
  /// In en, this message translates to:
  /// **'That page selection could not be read.'**
  String get toolsWatermarkSelectionInvalid;

  /// Notification shown when applying a watermark completes successfully.
  ///
  /// In en, this message translates to:
  /// **'Watermark applied successfully.'**
  String get toolsWatermarkSuccess;

  /// Notification shown when applying a watermark fails.
  ///
  /// In en, this message translates to:
  /// **'Could not apply the watermark.'**
  String get toolsWatermarkFailed;

  /// Label for the primary watermark action button.
  ///
  /// In en, this message translates to:
  /// **'Apply watermark'**
  String get toolsWatermarkButton;

  /// Tooltip explaining why the watermark button is disabled.
  ///
  /// In en, this message translates to:
  /// **'Choose a file, a watermark and an output location to continue.'**
  String get toolsWatermarkButtonDisabledHint;

  /// Label shown on the watermark button while the operation is running.
  ///
  /// In en, this message translates to:
  /// **'Applying watermark…'**
  String get toolsWatermarkSubmitting;
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
