import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:velin/core/document/document.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/engine/rendering/rendering.dart';

import 'recent_document.dart';
import 'recent_document_repository.dart';
import 'thumbnail_repository.dart';

final _log = Logger('velin.recent');

/// Keeps the recent-documents list and its thumbnails up to date.
///
/// Recents are a convenience: none of these methods throw, and a failure here
/// never stops a document from opening. Problems are logged instead.
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

  Stream<Result<List<RecentDocument>>> watchRecent({int limit = 10}) {
    return _repository.watchRecent(limit: limit);
  }

  Stream<Result<RecentDocument?>> watch(String path) {
    return _repository.watch(path);
  }

  Future<Result<RecentDocument?>> get(String path) {
    return _repository.get(path);
  }

  /// Records that [path] was opened and makes sure it has a thumbnail.
  Future<Result<void>> open({
    required String path,
    required int pageCount,
    required int currentPage,
    required DocumentType documentType,
  }) async {
    final saved = await Result.guard(
      () => _repository.save(
        RecentDocument(
          path: path,
          pageCount: pageCount,
          currentPage: currentPage,
          lastOpenedAt: DateTime.now(),
          documentType: documentType,
        ),
      ),
    );

    if (saved case Failure(:final failure)) {
      _log.warning('Could not save recent document', failure);
      return saved;
    }

    final thumbnail = await _ensureThumbnail(path);

    if (thumbnail case Failure(:final failure)) {
      // A missing thumbnail only affects the home screen; keep going.
      _log.warning('Could not create thumbnail', failure);
    }

    return const Success(null);
  }

  void pageChanged({required String path, required int currentPage}) {
    _pendingPages[path] = currentPage;

    _pageTimers[path]?.cancel();

    _pageTimers[path] = Timer(
      _pageChangeDebounce,
      () => unawaited(_persistPendingPage(path)),
    );
  }

  Future<void> flush(String path) async {
    _pageTimers.remove(path)?.cancel();

    await _persistPendingPage(path);
  }

  Future<void> remove(String path) async {
    _pageTimers.remove(path)?.cancel();
    _pendingPages.remove(path);

    final result = await Result.guard(
      () => Future.wait([
        _repository.remove(path),
        _thumbnailRepository.remove(path),
      ]),
    );

    if (result case Failure(:final failure)) {
      _log.warning('Could not remove recent document', failure);
    }
  }

  Future<void> clear() async {
    for (final timer in _pageTimers.values) {
      timer.cancel();
    }

    _pageTimers.clear();
    _pendingPages.clear();

    final result = await Result.guard(_repository.clear);

    if (result case Failure(:final failure)) {
      _log.warning('Could not clear recent documents', failure);
    }
  }

  Future<void> _persistPendingPage(String path) async {
    final page = _pendingPages.remove(path);

    if (page == null) {
      return;
    }

    _pageTimers.remove(path);

    final result = await Result.guard(
      () => _repository.updateCurrentPage(path, page),
    );

    if (result case Failure(:final failure)) {
      _log.warning('Could not save reading position', failure);
    }
  }

  Future<Result<File?>> _ensureThumbnail(String path) async {
    final cached = await _thumbnailRepository.get(path);
    if (cached case Success(data: final File _)) return cached;

    return Result.guard(() async {
      final temporaryDirectory = await Directory.systemTemp.createTemp(
        'velin-thumbnail-',
      );

      try {
        final rendered = await _pageRenderer.render(
          document: File(path),
          page: 1,
          output: File(p.join(temporaryDirectory.path, 'thumbnail.png')),
          width: _thumbnailWidth,
        );

        switch (rendered) {
          case Failure(:final failure):
            throw failure;
          case Success(:final data):
            await _thumbnailRepository.save(path, data);
        }

        return switch (await _thumbnailRepository.get(path)) {
          Success(:final data) => data,
          Failure(:final failure) => throw failure,
        };
      } finally {
        if (await temporaryDirectory.exists()) {
          await temporaryDirectory.delete(recursive: true);
        }
      }
    });
  }
}
