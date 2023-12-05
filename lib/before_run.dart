import 'package:flutter/material.dart';
import 'package:flutter_persistent_value_notifier/flutter_persistent_value_notifier.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:window_manager/window_manager.dart';

Future<void> beforeRun() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(600, 800),
    minimumSize: Size(600, 800),
    center: true,
    skipTaskbar: true,
    alwaysOnTop: true,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // if (kDebugMode) {
  //   await hotKeyManager.unregisterAll();
  // }
  HotKey hotKey = HotKey(
    KeyCode.keyQ,
    modifiers: [KeyModifier.alt],
    scope: HotKeyScope.system,
  );
  await hotKeyManager.register(
    hotKey,
    keyDownHandler: (hotKey) async {
      if (!await windowManager.isVisible()) {
        await windowManager.show();
      } else if (!await windowManager.isFocused()) {
        await windowManager.focus();
      } else {
        await windowManager.minimize();
      }
    },
  );

  await WindowManipulator.initialize();
  WindowManipulator.makeTitlebarTransparent();
  WindowManipulator.enableFullSizeContentView();
  WindowManipulator.disableCloseButton();
  WindowManipulator.hideZoomButton();

  await initPersistentValueNotifier(prefix: 'io.github.chrono-time-keeper');
}
