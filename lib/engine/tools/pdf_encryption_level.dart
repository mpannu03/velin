/// The cipher a `/Encrypt` dictionary is written with.
///
/// AES-256 is the default because it is what ISO 32000-2 mandates and what
/// every currently shipping reader supports. The older revisions exist only
/// for documents that must open in software predating AES (and are weak
/// enough that they should not be chosen without reason).
enum PdfEncryptionLevel {
  /// AES-256 (`/AESV3`, ISO 32000-2 Algorithm 2.B). The default.
  aes256(5, 6, 256, 'AESV3'),

  /// AES-128 (`/AESV2`).
  aes128(4, 4, 128, 'AESV2'),

  /// RC4 with a 128-bit key. Legacy readers only.
  rc4(2, 3, 128, 'V2');

  const PdfEncryptionLevel(this.version, this.revision, this.length, this.method);

  /// The `/V` version.
  final int version;

  /// The `/R` revision.
  final int revision;

  /// Key length in bits.
  final int length;

  /// The crypt filter method name (`/CFM`).
  final String method;

  /// Whether this level uses the AES-256 key derivation of ISO 32000-2
  /// Algorithm 2.B rather than the older MD5-based scheme.
  bool get isAes256 => method == 'AESV3';

  /// Whether strings and streams are encrypted with AES rather than RC4.
  bool get isAes => method != 'V2';
}