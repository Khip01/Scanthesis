import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class RecordHotkeyDialog extends StatefulWidget {
  final HotKey oldHotkey;
  final void Function(HotKey oldHotKey) onHotKeyRecorded;

  const RecordHotkeyDialog({super.key, required this.oldHotkey, required this.onHotKeyRecorded});

  @override
  State<RecordHotkeyDialog> createState() => _RecordHotkeyDialogState();
}

class _RecordHotkeyDialogState extends State<RecordHotkeyDialog> {
  HotKey? _newHotKey;

  bool _newHotKeyValidate() {
    if (_newHotKey == null) return true;
    if (_newHotKey!.key.keyLabel != widget.oldHotkey.key.keyLabel ||
        !listEquals(_newHotKey!.modifiers, widget.oldHotkey.modifiers)) {
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        "Screenshot Shortcut",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Change the existing screenshot shortcut",
            style: const TextStyle(fontSize: 15),
          ),
          Container(
            width: 300,
            alignment: Alignment.centerLeft,
            constraints: const BoxConstraints(minHeight: 52),
            margin: const EdgeInsets.only(bottom: 20, top: 12),
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: HotKeyRecorder(
              initalHotKey: widget.oldHotkey,
              onHotKeyRecorded: (hotKey) {
                final hk = HotKey(
                  key: hotKey.key,
                  modifiers: hotKey.modifiers,
                  scope: HotKeyScope.system,
                );
                setState(() {
                  _newHotKey = hk;
                });
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed:
              _newHotKeyValidate()
                  ? () {}
                  : () {
                    widget.onHotKeyRecorded(_newHotKey!);
                    Navigator.pop(context);
                  },
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: Text(
            'Save',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    );
  }
}
