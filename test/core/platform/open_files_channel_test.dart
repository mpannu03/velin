import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:velin/core/platform/open_files_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('filePathsFromArguments', () {
    test('keeps paths, made absolute, and skips flags and blanks', () {
      final paths = filePathsFromArguments([
        '--verbose',
        'relative.pdf',
        '  ',
        p.absolute('already', 'absolute.pdf'),
      ]);

      expect(paths, [
        p.absolute('relative.pdf'),
        p.absolute('already', 'absolute.pdf'),
      ]);
    });

    test('is empty without arguments', () {
      expect(filePathsFromArguments(const []), isEmpty);
    });
  });

  group('OpenFilesChannel', () {
    const channel = MethodChannel('test/open_files');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    Future<void> sendFromNative(MethodCall call) async {
      await messenger.handlePlatformMessage(
        channel.name,
        const StandardMethodCodec().encodeMethodCall(call),
        (_) {},
      );
    }

    test('tells the native side it is ready, then delivers files', () async {
      final nativeCalls = <String>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        nativeCalls.add(call.method);
        return null;
      });

      final received = <List<String>>[];
      await OpenFilesChannel(channel: channel).listen(received.add);

      expect(nativeCalls, ['ready']);

      await sendFromNative(
        const MethodCall('openFiles', ['/docs/a.pdf', '/docs/b.pdf']),
      );

      expect(received, [
        ['/docs/a.pdf', '/docs/b.pdf'],
      ]);
    });

    test('works on platforms without the native side', () async {
      // No mock handler: invoking "ready" throws MissingPluginException.
      final received = <List<String>>[];

      await expectLater(
        OpenFilesChannel(channel: channel).listen(received.add),
        completes,
      );
    });
  });
}
