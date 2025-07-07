import 'dart:io';

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
        color: Theme.of(context).scaffoldBackgroundColor,
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

class _WindowButtonsState extends State<WindowButtons> {

  @override
  Widget build(BuildContext context) {
    final buttonColors = WindowButtonColors(
      iconNormal: Theme.of(context).colorScheme.onSurface,
      mouseOver: StyleUtil.windowButtonGrey,
      mouseDown: StyleUtil.windowButtonGreyHover,
      iconMouseOver: Theme.of(context).colorScheme.onSurface,
      iconMouseDown: Theme.of(context).colorScheme.onSurface,
    );

    final buttonColorsClose = WindowButtonColors(
      iconNormal: Theme.of(context).colorScheme.onSurface,
      mouseOver: StyleUtil.windowCloseRed,
      mouseDown: StyleUtil.windowCloseRedPressed,
      iconMouseOver: Theme.of(context).colorScheme.onSurface,
      iconMouseDown: Theme.of(context).colorScheme.onSurface,
    );

    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: buttonColorsClose),
      ],
    );
  }
}
