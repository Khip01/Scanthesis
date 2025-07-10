import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SendDataIntent extends Intent {
  const SendDataIntent();
}

class SendButtonShortcut extends StatefulWidget {
  final Widget child;
  final Function() action;
  final FocusNode focusNode;

  const SendButtonShortcut({
    super.key,
    required this.child,
    required this.action,
    required this.focusNode,
  });

  @override
  State<SendButtonShortcut> createState() => _SendButtonShortcutState();
}

class _SendButtonShortcutState extends State<SendButtonShortcut> {
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): SendDataIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          SendDataIntent: CallbackAction<SendDataIntent>(
            onInvoke: (SendDataIntent intent) => widget.action(),
          ),
        },
        child: Focus(focusNode: widget.focusNode, child: widget.child),
      ),
    );
  }
}
