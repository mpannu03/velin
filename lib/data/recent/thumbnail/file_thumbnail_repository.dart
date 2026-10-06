import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:velin/core/recent/thumbnail_repository.dart';

class FileThumbnailRepository implements ThumbnailRepository {
  Directory? _directory;

  Future<Directory> _getDirectory() async {
    return _directory ??= Directory(
      p.join((await getApplicationSupportDirectory()).path, 'thumbnails'),
    )..createSync(recursive: true);
  }

  @override
  Future<File?> get(String path) async {
    final file = await _fileFor(path);

    return await file.exists() ? file : null;
  }

  @override
  Future<void> save(String path, File thumbnail) async {
    final destination = await _fileFor(path);

    if (thumbnail.path == destination.path) {
      return;
    }

    await thumbnail.copy(destination.path);
  }

  @override
  Future<void> remove(String path) async {
    final file = await _fileFor(path);

    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File> _fileFor(String path) async {
    final directory = await _getDirectory();
    final hash = sha256.convert(utf8.encode(path)).toString();

    return File(p.join(directory.path, '$hash.png'));
  }
}
