import 'package:flutter/widgets.dart';
import 'package:scanthesis_app/screens/home/handler/screen_capture_handler.dart';
import 'package:scanthesis_app/screens/router.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class SystemTrayPopUp {
  static Menu popUpMenu = Menu(
    items: [
      MenuItem(
        label: 'Open Scanthesis',
        onClick: (_) async {
          await windowManager.show();
        },
      ),
      MenuItem(
        label: 'Take Screenshot',
        onClick: (_) async {
          if (navigatorKey.currentState == null) return;
          BuildContext context = navigatorKey.currentState!.context;
          await ScreenCaptureHandler.actionButtonTakeScreenshot(
            context: context,
          );
        },
      ),
      MenuItem.separator(),
      MenuItem(
        label: 'Quit Scanthesis',
        onClick: (_) async {
          await windowManager.setPreventClose(false);
          await windowManager.close();
        },
      ),
    ],
  );
}
