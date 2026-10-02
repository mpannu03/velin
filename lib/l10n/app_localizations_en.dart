// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Velin';

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationReader => 'Reader';

  @override
  String get navigationEdit => 'Edit';

  @override
  String get navigationTools => 'Tools';

  @override
  String get commonOpenDocument => 'Open Document';

  @override
  String get commonClose => 'Close';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get readerNoDocumentOpen => 'No document open';

  @override
  String get readerNoDocumentOpenDescription => 'Open a file to start reading.';

  @override
  String get menuFile => 'File';

  @override
  String get menuEdit => 'Edit';

  @override
  String get menuView => 'View';

  @override
  String get toolSelect => 'Select';

  @override
  String get toolDictionary => 'Dictionary';

  @override
  String get panelComments => 'Comments';

  @override
  String get panelBookmarks => 'Bookmarks';

  @override
  String get panelSearch => 'Search';

  @override
  String get panelDictionary => 'Dictionary';

  @override
  String get toolZoomIn => 'Zoom In';

  @override
  String get toolZoomOut => 'Zoom Out';

  @override
  String toolPageOf(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get panelSearchInDocument => 'Search in Document...';

  @override
  String get panelSearchClear => 'Clear Search';

  @override
  String get panelSearchToggleCaseSensitivity => 'Toggle Case Sensitivity';

  @override
  String get panelSearchEnterText => 'Enter text to search';

  @override
  String get panelSearchNoMatchFound => 'No match found';

  @override
  String panelSearchResultCount(int count) {
    return '$count results found';
  }

  @override
  String get panelBookmarkEmpty => 'No bookmarks';

  @override
  String get toolsMergePdf => 'Merge PDF';

  @override
  String get toolsSplitPdf => 'Split PDF';

  @override
  String get toolsExtractPdf => 'Extract Pages';

  @override
  String get toolsCompressPdf => 'Compress PDF';

  @override
  String get toolsPdfToImage => 'PDF to Image';

  @override
  String get toolsImageToPdf => 'Image to PDF';

  @override
  String get toolsRotatePdf => 'Rotate PDF';

  @override
  String get toolsProtectPdf => 'Protect PDF';

  @override
  String get toolsUnlockPdf => 'Unlock PDF';

  @override
  String get toolsWatermark => 'Watermark';

  @override
  String get toolsCategoryEdit => 'Edit';

  @override
  String get toolsCategoryConvert => 'Convert';

  @override
  String get toolsCategoryOptimize => 'Optimize';

  @override
  String get toolsCategorySecurity => 'Security';

  @override
  String get toolsCategoryAll => 'All';

  @override
  String get toolsIntro =>
      'Combine, split, convert, optimize and secure your PDFs — all processed locally on your device.';

  @override
  String get toolsMergePdfDescription =>
      'Combine multiple PDF files into one document.';

  @override
  String get toolsSplitPdfDescription =>
      'Divide a PDF into multiple separate documents.';

  @override
  String get toolsExtractPdfDescription =>
      'Pull selected pages out into a new PDF.';

  @override
  String get toolsCompressPdfDescription =>
      'Reduce file size while keeping quality.';

  @override
  String get toolsPdfToImageDescription =>
      'Convert each PDF page into an image file.';

  @override
  String get toolsImageToPdfDescription =>
      'Turn one or more images into a PDF.';

  @override
  String get toolsRotatePdfDescription =>
      'Rotate individual pages or a whole document.';

  @override
  String get toolsProtectPdfDescription =>
      'Add a password so only intended viewers can open it.';

  @override
  String get toolsUnlockPdfDescription =>
      'Remove a password from a protected PDF.';

  @override
  String get toolsWatermarkDescription =>
      'Stamp your pages with text or an image mark.';
}
