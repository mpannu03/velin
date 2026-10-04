/// The set of things a reader is allowed to do with a document, mapped onto
/// the `/P` bit field of the standard security handler (ISO 32000-1
/// Table 22).
///
/// The field is advisory: it is enforced by conforming viewers, not by the
/// file format itself. Anyone holding the owner password is unaffected.
class PdfPermissions {
  const PdfPermissions({
    this.canPrint = true,
    this.canModify = true,
    this.canCopy = true,
    this.canAnnotate = true,
    this.canFillForms = true,
    this.canExtractForAccessibility = true,
    this.canAssemble = true,
    this.canPrintHighResolution = true,
  });

  /// Allows printing at reduced resolution.
  static const int printBit = 1 << 2;

  /// Allows editing page content.
  static const int modifyBit = 1 << 3;

  /// Allows copying text and graphics.
  static const int copyBit = 1 << 4;

  /// Allows adding and editing annotations and form fields.
  static const int annotateBit = 1 << 5;

  /// Allows filling in existing form fields.
  static const int fillFormsBit = 1 << 8;

  /// Allows extracting content for a screen reader.
  static const int extractForAccessibilityBit = 1 << 9;

  /// Allows inserting, rotating and deleting pages.
  static const int assembleBit = 1 << 10;

  /// Allows printing without a resolution reduction.
  static const int printHighResolutionBit = 1 << 11;

  /// Everything the format can grant.
  static const PdfPermissions all = PdfPermissions();

  /// Nothing at all: viewing only.
  static const PdfPermissions none = PdfPermissions(
    canPrint: false,
    canModify: false,
    canCopy: false,
    canAnnotate: false,
    canFillForms: false,
    canExtractForAccessibility: false,
    canAssemble: false,
    canPrintHighResolution: false,
  );

  /// Viewing and printing, but no editing - the common "read-only" case.
  static const PdfPermissions readOnly = PdfPermissions(
    canModify: false,
    canCopy: false,
    canAnnotate: false,
    canAssemble: false,
  );

  final bool canPrint;
  final bool canModify;
  final bool canCopy;
  final bool canAnnotate;
  final bool canFillForms;
  final bool canExtractForAccessibility;
  final bool canAssemble;
  final bool canPrintHighResolution;

  /// Packs the flags into the `/P` integer.
  ///
  /// Bits 1-2 are reserved and must be zero, bits 7-8 and 13-32 are reserved
  /// and must be one (ISO 32000-1 Table 22). A file that gets this wrong is
  /// rejected by strict readers, so the reserved positions are set here rather
  /// than left to the caller.
  int toInt() {
    var value = 0xFFFFF0C0;

    if (canPrint) value |= printBit;
    if (canModify) value |= modifyBit;
    if (canCopy) value |= copyBit;
    if (canAnnotate) value |= annotateBit;
    if (canFillForms) value |= fillFormsBit;
    if (canExtractForAccessibility) value |= extractForAccessibilityBit;
    if (canAssemble) value |= assembleBit;
    if (canPrintHighResolution) value |= printHighResolutionBit;

    // Bits 1-2 are reserved and must stay clear.
    return value & ~0x3;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PdfPermissions &&
        other.canPrint == canPrint &&
        other.canModify == canModify &&
        other.canCopy == canCopy &&
        other.canAnnotate == canAnnotate &&
        other.canFillForms == canFillForms &&
        other.canExtractForAccessibility == canExtractForAccessibility &&
        other.canAssemble == canAssemble &&
        other.canPrintHighResolution == canPrintHighResolution;
  }

  @override
  int get hashCode => Object.hash(
        canPrint,
        canModify,
        canCopy,
        canAnnotate,
        canFillForms,
        canExtractForAccessibility,
        canAssemble,
        canPrintHighResolution,
      );

  @override
  String toString() => 'PdfPermissions(${toInt()})';
}