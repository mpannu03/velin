import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pdf_cos/pdf_cos.dart';

import '../pdf_encryption_level.dart';

/// Builds the `/Encrypt` dictionary for a document and encrypts the strings
/// and streams it holds.
///
/// One handler owns one freshly generated file key. Every password is
/// validated *into* that key (Algorithm 2.A) rather than the key being
/// derived *from* a password, which is what makes AES-256 non-circular and
/// what lets a document keep working when a password is later changed.
class PdfSecurityHandler {
  PdfSecurityHandler({
    required this.userPassword,
    required this.ownerPassword,
    required this.permissions,
    required this.fileId,
    this.level = PdfEncryptionLevel.aes256,
    this.encryptMetadata = true,
  }) {
    _create();
  }

  /// Password required to open the document. May be empty, which still leaves
  /// the permission restrictions in force.
  final String userPassword;

  /// Password that bypasses every restriction. Never recoverable.
  final String ownerPassword;

  /// The `/P` bit field.
  final int permissions;

  /// First element of the trailer's `/ID` array.
  final Uint8List fileId;

  final PdfEncryptionLevel level;

  /// When false the `/Metadata` stream is left readable, so text stays
  /// searchable and accessible to assistive technology.
  final bool encryptMetadata;

  late final Uint8List fileKey;
  late final CosDictionary encryptDictionary;

  /// True when a password is required to open the document.
  bool get requiresPassword => userPassword.isNotEmpty;

  late final Uint8List _u;
  late final Uint8List _o;
  late final Uint8List _ue;
  late final Uint8List _oe;

  void _create() {
    fileKey = _randomBytes(32);

    final userPasswordBytes = _passwordBytes(userPassword);
    final ownerPasswordBytes = _passwordBytes(ownerPassword);

    final userValidationSalt = _randomBytes(8);
    final userKeySalt = _randomBytes(8);
    final ownerValidationSalt = _randomBytes(8);
    final ownerKeySalt = _randomBytes(8);

    // Algorithm 2.A: /U and /O are each an independent 32-byte hash, and the
    // file key is handed over separately under /UE and /OE.
    _u = Uint8List.fromList([
      ..._hash2B(userPasswordBytes, userValidationSalt, const []),
      ...userValidationSalt,
      ...userKeySalt,
    ]);

    // The owner hash covers the first 48 bytes of /U so the two halves stay
    // cryptographically bound.
    final u48 = Uint8List.sublistView(_u, 0, 48);

    _o = Uint8List.fromList([
      ..._hash2B(ownerPasswordBytes, ownerValidationSalt, u48),
      ...ownerValidationSalt,
      ...ownerKeySalt,
    ]);

    // /UE and /OE are the file key CBC-encrypted under a key derived from the
    // respective password, with an all-zero IV and no padding.
    _ue = Aes(
      _hash2B(userPasswordBytes, userKeySalt, const []),
    ).cbcEncrypt(Uint8List(16), fileKey);

    _oe = Aes(
      _hash2B(ownerPasswordBytes, ownerKeySalt, u48),
    ).cbcEncrypt(Uint8List(16), fileKey);

    encryptDictionary = _buildEncryptDictionary();
  }

  CosDictionary _buildEncryptDictionary() {
    return CosDictionary({
      'Filter': const CosName('Standard'),
      'V': CosInteger(level.version),
      'R': CosInteger(level.revision),
      'Length': CosInteger(level.length),
      'O': CosString(_o, isHex: true),
      'U': CosString(_u, isHex: true),
      'P': CosInteger(permissions),
      'EncryptMetadata': CosBoolean(encryptMetadata),
      'OE': CosString(_oe, isHex: true),
      'UE': CosString(_ue, isHex: true),
      'Perms': CosString(_createPerms(), isHex: true),
      'CF': CosDictionary({
        'StdCF': CosDictionary({
          'Type': const CosName('CryptFilter'),
          'CFM': CosName(level.method),
          'Length': CosInteger(32),
          'AuthEvent': const CosName('DocOpen'),
        }),
      }),
      'StmF': const CosName('StdCF'),
      'StrF': const CosName('StdCF'),
    });
  }

  /// Encrypts a string or stream payload under a fresh random IV.
  ///
  /// AES-256 uses the file key directly - there is no per-object key
  /// derivation, which is the defining simplification of `/AESV3` over the
  /// older RC4 revisions.
  Uint8List encryptBytes(Uint8List bytes) {
    return Aes.encryptContent(fileKey, bytes, _randomBytes(16));
  }

  /// The `/Perms` value of ISO 32000-2 Algorithm 9: the permission bits,
  /// fixed reserved bytes, the metadata flag, and four random bytes,
  /// encrypted as a single AES block.
  Uint8List _createPerms() {
    final data = Uint8List(16);

    data[0] = permissions & 0xFF;
    data[1] = (permissions >> 8) & 0xFF;
    data[2] = (permissions >> 16) & 0xFF;
    data[3] = (permissions >> 24) & 0xFF;

    // Bits 4-7 of the permission word are reserved and must be set.
    data[4] = 0xFF;
    data[5] = 0xFF;
    data[6] = 0xFF;
    data[7] = 0xFF;

    // The literal "adb" followed by the metadata flag in ASCII: 'T' for true
    // and 'F' for false.
    data[8] = 0x61;
    data[9] = 0x64;
    data[10] = 0x62;
    data[11] = encryptMetadata ? 0x54 : 0x46;

    data.setRange(12, 16, _randomBytes(4));

    // A single-block CBC encryption with a zero IV is the AES-ECB case.
    return Aes(fileKey).cbcEncrypt(Uint8List(16), data);
  }

  /// UTF-8 encodes a password and truncates it to the 127 bytes the standard
  /// allows.
  static Uint8List _passwordBytes(String password) {
    final bytes = utf8.encode(password);

    if (bytes.length <= 127) {
      return Uint8List.fromList(bytes);
    }

    return Uint8List.fromList(bytes.sublist(0, 127));
  }

  /// ISO 32000-2 Algorithm 2.B: a deliberately slow SHA-2 based hash.
  ///
  /// The loop cannot be short-circuited - the exit condition reads the output
  /// of the previous iteration - so it runs at least 64 rounds and then keeps
  /// going while the last byte of the last block exceeds the round counter.
  /// That cost is the point of the algorithm, not an oversight.
  static Uint8List _hash2B(
    List<int> password,
    List<int> salt,
    List<int> extra,
  ) {
    var key = Uint8List.fromList(
      sha256.convert([...password, ...salt, ...extra]).bytes,
    );

    var e = <int>[];

    for (var round = 0; round < 64 || e.last > round - 32; round++) {
      final block = [...password, ...key, ...extra];

      final repeated = Uint8List(block.length * 64);

      for (var i = 0; i < 64; i++) {
        repeated.setRange(i * block.length, (i + 1) * block.length, block);
      }

      e = Aes(key.sublist(0, 16)).cbcEncrypt(
        Uint8List.sublistView(key, 16, 32),
        repeated,
      );

      var sum = 0;

      for (var i = 0; i < 16; i++) {
        sum += e[i];
      }

      key = Uint8List.fromList(
        switch (sum % 3) {
          0 => sha256.convert(e).bytes,
          1 => sha384.convert(e).bytes,
          _ => sha512.convert(e).bytes,
        },
      );
    }

    return Uint8List.fromList(key.sublist(0, 32));
  }

  static Uint8List _randomBytes(int length) {
    final random = math.Random.secure();

    return Uint8List.fromList([
      for (var i = 0; i < length; i++) random.nextInt(256),
    ]);
  }
}
