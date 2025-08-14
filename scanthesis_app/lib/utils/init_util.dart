import 'dart:io';
import 'dart:ui';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:scanthesis_app/screens/settings/provider/settings_provider.dart';
import 'package:scanthesis_app/values/strings.dart';
import 'package:scanthesis_app/widgets/system_tray_popup.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class InitUtil {
  static Future<SettingsProvider> initSettingsProvider() async {
    Directory defaultBrowseDirectory =
        await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();

    Directory docDir = await getApplicationDocumentsDirectory();
    Directory defaultImageStoreDirectory = Directory(
      p.join(docDir.path, 'Scanthesis App - Image Chat History'),
    );
    if (!await defaultImageStoreDirectory.exists()) {
      // create if not exist
      await defaultImageStoreDirectory.create(recursive: true);
    }

    return SettingsProvider(
      defaultBrowseDirectory: defaultBrowseDirectory,
      defaultImageStoreDirectory: defaultImageStoreDirectory,
    );
  }

  static Future<void> initAppManager() async {
    // window manager init
    await windowManager.ensureInitialized();
    await windowManager.setPreventClose(true);

    // hotkey manager init
    await hotKeyManager.unregisterAll();

    // tray manager init
    final Menu menu = SystemTrayPopUp.popUpMenu;
    await trayManager.setContextMenu(menu);
    String trayIcon =
        Platform.isWindows
            ? "tray_icon_original.ico"
            : "tray_icon_original.png";
    await trayManager.setIcon("${Strings.pathToTrayIcon}/$trayIcon");
    await trayManager.setToolTip("Scanthesis");

    // setup window when app opened (window manager)
    doWhenWindowReady(() {
      final win = appWindow;
      const initialSize = Size(800, 600);
      win.minSize = initialSize;
      win.size = initialSize;
      win.alignment = Alignment.center;
      win.title = "Scanthesis App";
      win.show();
    });
  }
}
