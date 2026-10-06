import 'dart:io';

abstract interface class ThumbnailRepository {
  Future<File?> get(String path);

  Future<void> save(String path, File thumbnail);

  Future<void> remove(String path);
}
