import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:logging/logging.dart';
import 'package:velin/core/file/safe_file_writer.dart';
import 'package:window_manager/window_manager.dart';

final _log = Logger('velin.window');

/// Where the main window was and whether it was maximized.
class WindowPlacement {
  const WindowPlacement({required this.bounds, required this.isMaximized});

  /// Normal (restored) bounds in logical pixels, also kept while maximized
  /// so un-maximizing goes back to them.
  final Rect bounds;
  final bool isMaximized;

  Map<String, Object> toJson() => {
    'x': bounds.left,
    'y': bounds.top,
    'width': bounds.width,
    'height': bounds.height,
    'maximized': isMaximized,
  };

  /// Returns `null` for missing or malformed data.
  static WindowPlacement? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;

    final x = json['x'];
    final y = json['y'];
    final width = json['width'];
    final height = json['height'];
    final maximized = json['maximized'];

    if (x is! num || y is! num || width is! num || height is! num) {
      return null;
    }
    if (width <= 0 || height <= 0) return null;

    return WindowPlacement(
      bounds: Rect.fromLTWH(
        x.toDouble(),
        y.toDouble(),
        width.toDouble(),
        height.toDouble(),
      ),
      isMaximized: maximized == true,
    );
  }

  /// Whether enough of the window would be on one of [displays] to grab its
  /// title bar. False when, e.g., the monitor it was on is unplugged.
  bool isVisibleOn(List<Rect> displays) {
    const minVisibleWidth = 120.0;
    const minVisibleHeight = 40.0;

    return displays.any((display) {
      final overlap = display.intersect(bounds);
      return overlap.width >= minVisibleWidth &&
          overlap.height >= minVisibleHeight;
    });
  }

  @override
  bool operator ==(Object other) =>
      other is WindowPlacement &&
      other.bounds == bounds &&
      other.isMaximized == isMaximized;

  @override
  int get hashCode => Object.hash(bounds, isMaximized);

  @override
  String toString() => 'WindowPlacement($bounds, maximized: $isMaximized)';
}

/// Reads and writes the [WindowPlacement] in a small JSON file.
class WindowPlacementStore {
  WindowPlacementStore(this.file);

  final File file;

  Future<WindowPlacement?> load() async {
    try {
      if (!await file.exists()) return null;
      return WindowPlacement.fromJson(jsonDecode(await file.readAsString()));
    } catch (error, stackTrace) {
      // A broken file only costs the saved position.
      _log.warning('Could not read ${file.path}', error, stackTrace);
      return null;
    }
  }

  Future<void> save(WindowPlacement placement) async {
    try {
      await writeAtomically(
        file,
        (temp) => temp.writeAsString(jsonEncode(placement.toJson())),
      );
    } catch (error, stackTrace) {
      _log.warning('Could not save ${file.path}', error, stackTrace);
    }
  }
}

/// Restores the window to where the user left it and keeps track of
/// later moves, resizes and maximizing.
class WindowPlacementKeeper with WindowListener {
  WindowPlacementKeeper({
    required this._store,
    required this._windowManager,
    required this._displays,
    this._saveDelay = const Duration(milliseconds: 500),
  });

  final WindowPlacementStore _store;
  final WindowManager _windowManager;

  /// The usable area of every connected display, in logical pixels.
  final Future<List<Rect>> Function() _displays;
  final Duration _saveDelay;

  Rect? _normalBounds;
  bool _isMaximized = false;
  Timer? _saveTimer;

  /// Applies the saved placement, if it still fits on a display. Call
  /// before the window is shown; then starts listening for changes.
  Future<void> restore() async {
    try {
      final saved = await _store.load();

      if (saved != null) {
        if (saved.isVisibleOn(await _displays())) {
          await _windowManager.setBounds(saved.bounds);
          _normalBounds = saved.bounds;

          if (saved.isMaximized) {
            await _windowManager.maximize();
            _isMaximized = true;
          }
        } else {
          _log.info('Saved window position is off-screen; using the default');
        }
      }
    } catch (error, stackTrace) {
      _log.warning('Could not restore the window position', error, stackTrace);
    }

    _windowManager.addListener(this);
  }

  void dispose() {
    _windowManager.removeListener(this);
    _saveTimer?.cancel();
  }

  // Windows reports `moved`/`resized` only when a drag ends, Linux only
  // reports the continuous `move`/`resize`; listen to both (the save is
  // debounced). Blur catches changes that send neither, such as snapping
  // with Win+Arrow, by the time the user switches away.
  @override
  void onWindowMove() => _onChanged();

  @override
  void onWindowMoved() => _onChanged();

  @override
  void onWindowResize() => _onChanged();

  @override
  void onWindowResized() => _onChanged();

  @override
  void onWindowMaximize() => _onChanged();

  @override
  void onWindowUnmaximize() => _onChanged();

  @override
  void onWindowRestore() => _onChanged();

  @override
  void onWindowBlur() => _onChanged();

  void _onChanged() {
    _saveTimer?.cancel();
    _saveTimer = Timer(_saveDelay, _save);
  }

  Future<void> _save() async {
    try {
      _isMaximized = await _windowManager.isMaximized();

      // Full screen and minimized bounds are not worth restoring.
      if (await _windowManager.isFullScreen() ||
          await _windowManager.isMinimized()) {
        return;
      }

      // While maximized keep the last normal bounds, so restoring after a
      // restart un-maximizes to a sensible size.
      if (!_isMaximized) _normalBounds = await _windowManager.getBounds();

      final bounds = _normalBounds;
      if (bounds == null) return;

      await _store.save(
        WindowPlacement(bounds: bounds, isMaximized: _isMaximized),
      );
    } catch (error, stackTrace) {
      _log.warning('Could not save the window position', error, stackTrace);
    }
  }
}
