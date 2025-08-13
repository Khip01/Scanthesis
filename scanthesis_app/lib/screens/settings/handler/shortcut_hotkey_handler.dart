import 'package:flutter/cupertino.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class ShortcutHotKeyHandler {
  static Future registerShortcut(
    HotKey hotKey, {
    required Function(HotKey hotKey) keyDownHandler,
  }) async {
    await hotKeyManager.register(hotKey, keyDownHandler: keyDownHandler);
    debugPrint(
      'Registered hotkey: ${hotKey.key.keyLabel} with modifiers: ${hotKey.modifiers?.map((e) => e.name).join(', ')}',
    );
  }

  static Future unregisterShortcut(HotKey hotKey) async {
    await hotKeyManager.unregister(hotKey);
    debugPrint(
      'Unregistered hotkey: ${hotKey.key.keyLabel} with modifiers: ${hotKey.modifiers?.map((e) => e.name).join(', ')}',
    );
  }
}
