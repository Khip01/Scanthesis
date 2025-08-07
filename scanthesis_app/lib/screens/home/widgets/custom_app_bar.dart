import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:scanthesis_app/utils/style_util.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTap: () => _showRightClickMenu(context),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 0.15,
            ),
          ),
        ),
        child: WindowTitleBarBox(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: const Text(
                  "Scanthesis App",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(child: MoveWindow()),
              const WindowButtons(),
            ],
          ),
        ),
      ),
    );
  }

  void _showRightClickMenu(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(200.0, 50.0, 0.0, 0.0),
      items: [
        PopupMenuItem(
          child: Text('Minimize'),
          onTap: () => appWindow.minimize(),
        ),
        PopupMenuItem(
          enabled: !appWindow.isMaximized,
          child: Text('Maximize'),
          onTap: () => appWindow.maximize(),
        ),
        PopupMenuItem(
          enabled: appWindow.isMaximized,
          child: Text('Restore'),
          onTap: () => appWindow.restore(),
        ),
        PopupMenuItem(child: Text('Close'), onTap: () => appWindow.close()),
      ],
    );
  }
}

class WindowButtons extends StatefulWidget {
  const WindowButtons({super.key});

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> with WidgetsBindingObserver{
  late WindowButtonColors buttonColors, buttonColorsClose;
  late Widget maximizeOrRestoreButton, maximizeButton, restoreButton;

  void _loadButtonColors() {
    buttonColors = WindowButtonColors(
      iconNormal: Theme.of(context).colorScheme.onSurface,
      mouseOver: StyleUtil.windowButtonGrey,
      mouseDown: StyleUtil.windowButtonGreyHover,
      iconMouseOver: Theme.of(context).colorScheme.onSurface,
      iconMouseDown: Theme.of(context).colorScheme.onSurface,
    );

    buttonColorsClose = WindowButtonColors(
      iconNormal: Theme.of(context).colorScheme.onSurface,
      mouseOver: StyleUtil.windowCloseRed,
      mouseDown: StyleUtil.windowCloseRedPressed,
      iconMouseOver: Theme.of(context).colorScheme.onSurface,
      iconMouseDown: Theme.of(context).colorScheme.onSurface,
    );
  }

  void _initButtonResizer() {
    void onPressAction(){
      setState(() {
        appWindow.maximizeOrRestore();
      });
    }

    restoreButton = RestoreWindowButton(
      colors: buttonColors,
      onPressed: onPressAction,
    );

    maximizeButton = MaximizeWindowButton(
      colors: buttonColors,
      onPressed: onPressAction,
    );

    _changeIconButtonResizer();
  }

  void _changeIconButtonResizer(){
    if (appWindow.isMaximized) {
      maximizeOrRestoreButton = restoreButton;
    } else {
      maximizeOrRestoreButton = maximizeButton;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // _changeIconButtonResizer();
    appWindow.maximizeOrRestore();
    debugPrint("WTF IS THIS CALLED ALREADY!");
  }

  @override
  Widget build(BuildContext context) {
    _loadButtonColors();
    _initButtonResizer();

    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        maximizeOrRestoreButton,
        CloseWindowButton(colors: buttonColorsClose),
      ],
    );
  }
}
