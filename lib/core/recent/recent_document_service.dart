import 'dart:async';
import 'dart:io';

import 'package:velin/engine/rendering/rendering.dart';

import 'recent_document.dart';
import 'recent_document_repository.dart';
import 'thumbnail_repository.dart';

class RecentDocumentService {
  RecentDocumentService({
    required this._repository,
    required this._thumbnailRepository,
    required this._pageRenderer,
  });

  static const _pageChangeDebounce = Duration(milliseconds: 500);
  static const _thumbnailWidth = 320;

  final RecentDocumentRepository _repository;
  final ThumbnailRepository _thumbnailRepository;
  final PdfPageRenderer _pageRenderer;

  final Map<String, Timer> _pageTimers = {};
  final Map<String, int> _pendingPages = {};

  Stream<List<RecentDocument>> watchRecent({int limit = 10}) {
    return _repository.watchRecent(limit: limit);
  }

  Stream<RecentDocument?> watch(String path) {
    return _repository.watch(path);
  }

  Future<RecentDocument?> get(String path) {
    return _repository.get(path);
  }

  Future<void> open({
    required String path,
    required int pageCount,
    required int currentPage,
  }) async {
    await _repository.save(
      RecentDocument(
        path: path,
        pageCount: pageCount,
        currentPage: currentPage,
        lastOpenedAt: DateTime.now(),
      ),
    );

    await _ensureThumbnail(path);
  }

  void pageChanged({required String path, required int currentPage}) {
    _pendingPages[path] = currentPage;

    _pageTimers[path]?.cancel();

    _pageTimers[path] = Timer(
      _pageChangeDebounce,
      () => _persistPendingPage(path),
    );
  }

  Future<void> flush(String path) async {
    _pageTimers.remove(path)?.cancel();

    await _persistPendingPage(path);
  }

  Future<void> remove(String path) async {
    _pageTimers.remove(path)?.cancel();
    _pendingPages.remove(path);

    await Future.wait([
      _repository.remove(path),
      _thumbnailRepository.remove(path),
    ]);
  }

  Future<void> clear() async {
    for (final timer in _pageTimers.values) {
      timer.cancel();
    }

    _pageTimers.clear();
    _pendingPages.clear();

    await _repository.clear();
  }

  Future<void> _persistPendingPage(String path) async {
    final page = _pendingPages.remove(path);

    if (page == null) {
      return;
    }

    _pageTimers.remove(path);

    await _repository.updateCurrentPage(path, page);
  }

  Future<File?> _ensureThumbnail(String path) async {
    final cached = await _thumbnailRepository.get(path);

    if (cached != null) {
      return cached;
    }

    final temporaryDirectory = await Directory.systemTemp.createTemp(
      'velin-thumbnail-',
    );

    final output = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}thumbnail.png',
    );

    try {
      final thumbnail = await _pageRenderer.render(
        document: File(path),
        page: 1,
        output: output,
        width: _thumbnailWidth,
      );

      await _thumbnailRepository.save(path, thumbnail);

      return await _thumbnailRepository.get(path);
    } finally {
      if (await temporaryDirectory.exists()) {
        await temporaryDirectory.delete(recursive: true);
      }
    }
  }
}
