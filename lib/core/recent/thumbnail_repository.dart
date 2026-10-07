import 'dart:io';

import 'package:velin/core/result/result.dart';

abstract interface class ThumbnailRepository {
  Future<Result<File>> get(String path);

  Future<void> save(String path, File thumbnail);

  Future<void> remove(String path);
}
