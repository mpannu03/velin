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

  @override
  String get toolsMergeIntro => 'Combine multiple PDF files into one document.';

  @override
  String get toolsInputSectionTitle => 'Input PDFs';

  @override
  String get toolsAddFiles => 'Add files';

  @override
  String get toolsNoFilesTitle => 'No files added';

  @override
  String get toolsMergeNoFilesDescription =>
      'Add one or more PDF files to combine them.';

  @override
  String get toolsOutputSectionTitle => 'Output';

  @override
  String get toolsOutputFileNameLabel => 'File name';

  @override
  String get toolsChooseFolder => 'Choose folder';

  @override
  String get toolsChooseOutputFolder => 'Choose an output folder';

  @override
  String get toolsOutputPathHint =>
      'Select where the output files should be saved.';

  @override
  String toolsWillSaveAs(String path) {
    return 'Will save as $path';
  }

  @override
  String get toolsMergeButton => 'Merge PDF';

  @override
  String get toolsMergeSubmitting => 'Merging…';

  @override
  String get toolsMergeButtonDisabledHint =>
      'Add files and choose an output location to continue.';

  @override
  String get toolsRemoveFile => 'Remove file';

  @override
  String get toolsPagesLabel => 'Page Selection';

  @override
  String get toolsPagesHint => 'e.g. 1-5, 8, last';

  @override
  String toolsFileCount(int count) {
    return '$count files';
  }

  @override
  String get toolsMergeWarningNoFiles => 'Add at least one PDF file to merge.';

  @override
  String get toolsMergeWarningNoFolder => 'Choose an output folder.';

  @override
  String get toolsMergeWarningNoFileName => 'Enter an output file name.';

  @override
  String get toolsMergeSuccess => 'PDF merged successfully.';

  @override
  String get toolsMergeFailed => 'Could not merge the PDFs.';

  @override
  String toolsMergePageSelectionInvalid(String file) {
    return 'Check the page selection for $file.';
  }

  @override
  String get toolsChooseFile => 'Choose file';

  @override
  String get toolsReplaceFile => 'Replace file';

  @override
  String get toolsNoFileSelected => 'No file selected';

  @override
  String get toolsChooseFileHint => 'Choose a file to get started';

  @override
  String get toolsSplitIntro =>
      'Divide a PDF into multiple separate documents.';

  @override
  String get toolsSplitSourceSectionTitle => 'Source PDF';

  @override
  String get toolsSplitModeSectionTitle => 'Split mode';

  @override
  String get toolsSplitModeByPageCount => 'By page count';

  @override
  String get toolsSplitModeBySelection => 'By selection';

  @override
  String get toolsSplitModeExtractAll => 'Extract all pages';

  @override
  String get toolsSplitPagesPerFileLabel => 'Pages per file';

  @override
  String get toolsSplitPagesPerFileHint => 'e.g. 5';

  @override
  String get toolsSplitSelectionAdd => 'Add pages';

  @override
  String get toolsSplitSelectionHint =>
      'Add groups of pages — each group becomes its own PDF.';

  @override
  String get toolsSplitSelectionRemove => 'Remove pages';

  @override
  String get toolsSplitExtractAllInfo =>
      'Every page will be saved as its own separate PDF file.';

  @override
  String get toolsSplitButton => 'Split PDF';

  @override
  String get toolsSplitSubmitting => 'Splitting…';

  @override
  String get toolsSplitButtonDisabledHint =>
      'Choose a file, a split option and an output location to continue.';

  @override
  String get toolsSplitWarningNoFile => 'Choose a PDF file to split.';

  @override
  String get toolsSplitWarningNoFolder => 'Choose an output folder.';

  @override
  String get toolsSplitWarningPagesPerFile =>
      'Enter a page count greater than zero.';

  @override
  String get toolsSplitWarningNoSelection => 'Add at least one page selection.';

  @override
  String toolsSplitSuccess(int count) {
    return 'PDF split into $count files.';
  }

  @override
  String get toolsSplitFailed => 'Could not split the PDF.';

  @override
  String get toolsSplitSelectionInvalid => 'Check your page selections.';

  @override
  String get toolsExtractWarningNoFile => 'Choose a pdf file to extract.';

  @override
  String get toolsExtractWarningNoFolder => 'Choose an output folder.';

  @override
  String get toolsExtractWarningNoFileName => 'Enter an output file name.';

  @override
  String get toolsExtractSuccess => 'PDF extracted successfully.';

  @override
  String get toolsExtractFailed => 'Could not extract from the PDF.';

  @override
  String get toolsExtractButton => 'Extract PDF';

  @override
  String get toolsExtractIntro => 'Pull selected pages out into a new PDF.';

  @override
  String get toolsExtractSourceSectionTitle => 'Source PDF';

  @override
  String get toolsExtractSelectionSectionTitle => 'Pages to extract';

  @override
  String get toolsExtractSelectionHint => 'e.g. 1-5, 8, last';

  @override
  String get toolsExtractSubmitting => 'Extracting…';

  @override
  String get toolsExtractButtonDisabledHint =>
      'Choose a file, pages and an output location to continue.';

  @override
  String get toolsExtractSelectionInvalid =>
      'Check the pages you want to extract.';

  @override
  String get toolsRotateIntro =>
      'Turn pages a quarter, half or three quarters of the way around.';

  @override
  String get toolsRotateSourceSectionTitle => 'Source PDF';

  @override
  String get toolsRotateDirectionSectionTitle => 'Rotation';

  @override
  String get toolsRotateDirection90 => '90° clockwise';

  @override
  String get toolsRotateDirection180 => '180°';

  @override
  String get toolsRotateDirection270 => '90° counter-clockwise';

  @override
  String get toolsRotatePagesSectionTitle => 'Pages to rotate';

  @override
  String get toolsRotateScopeAll => 'All pages';

  @override
  String get toolsRotateScopeSelected => 'Selected pages';

  @override
  String get toolsRotateSelectionHint => 'e.g. 1-5, 8, last';

  @override
  String get toolsRotateSelectionHelper =>
      'Only the pages you pick are turned. Everything else stays as it is.';

  @override
  String get toolsRotateSelectionInvalid =>
      'Check the pages you want to rotate.';

  @override
  String get toolsRotateWarningNoFile => 'Choose a pdf file to rotate.';

  @override
  String get toolsRotateWarningNoFolder => 'Choose an output folder.';

  @override
  String get toolsRotateWarningNoFileName => 'Enter an output file name.';

  @override
  String get toolsRotateWarningNoSelection =>
      'Enter the pages you want to rotate.';

  @override
  String get toolsRotateSuccess => 'PDF rotated successfully.';

  @override
  String get toolsRotateFailed => 'Could not rotate the PDF.';

  @override
  String get toolsRotateButton => 'Rotate PDF';

  @override
  String get toolsRotateSubmitting => 'Rotating…';

  @override
  String get toolsRotateButtonDisabledHint =>
      'Choose a file, a rotation and an output location to continue.';

  @override
  String get toolsPdfToImageIntro =>
      'Convert the pages of a PDF into image files.';

  @override
  String get toolsPdfToImageSourceSectionTitle => 'Source PDF';

  @override
  String get toolsPdfToImageFormatSectionTitle => 'Image format';

  @override
  String get toolsPdfToImageFormatPng => 'PNG';

  @override
  String get toolsPdfToImageFormatJpeg => 'JPEG';

  @override
  String get toolsPdfToImageFormatWebp => 'WebP';

  @override
  String get toolsPdfToImageFormatHelper =>
      'PNG keeps every detail but produces larger files. JPEG and WebP are smaller thanks to the quality setting.';

  @override
  String get toolsPdfToImageColorSectionTitle => 'Colour mode';

  @override
  String get toolsPdfToImageColorModeColor => 'Colour';

  @override
  String get toolsPdfToImageColorModeGreyscale => 'Greyscale';

  @override
  String get toolsPdfToImageResolutionSectionTitle => 'Resolution';

  @override
  String get toolsPdfToImageDpiLabel => 'Resolution (DPI)';

  @override
  String get toolsPdfToImageDpiHelper =>
      'Higher resolutions look sharper but take longer and use more disk space.';

  @override
  String get toolsPdfToImageQualityLabel => 'Quality';

  @override
  String get toolsPdfToImageQualityHelper =>
      'Applies to JPEG and WebP only. PNG is always lossless.';

  @override
  String get toolsPdfToImagePagesSectionTitle => 'Pages to convert';

  @override
  String get toolsPdfToImageScopeAll => 'All pages';

  @override
  String get toolsPdfToImageScopeSelected => 'Selected pages';

  @override
  String get toolsPdfToImageSelectionHint => 'e.g. 1-5, 8, last';

  @override
  String get toolsPdfToImageSelectionHelper =>
      'Each selected page is written as its own image file.';

  @override
  String get toolsPdfToImageSelectionInvalid =>
      'Check the pages you want to convert.';

  @override
  String get toolsPdfToImageWarningNoFile => 'Choose a pdf file to convert.';

  @override
  String get toolsPdfToImageWarningNoFolder => 'Choose an output folder.';

  @override
  String get toolsPdfToImageWarningNoSelection =>
      'Enter the pages you want to convert.';

  @override
  String toolsPdfToImageSuccess(int count) {
    return 'Created $count image files.';
  }

  @override
  String get toolsPdfToImageFailed => 'Could not convert the PDF to images.';

  @override
  String get toolsPdfToImageButton => 'Convert to Images';

  @override
  String get toolsPdfToImageSubmitting => 'Converting…';

  @override
  String get toolsPdfToImageButtonDisabledHint =>
      'Choose a file and an output location to continue.';
}
