import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class ImprovedHotKeyView extends StatelessWidget {
  final HotKey hotKey;
  final Color keyBackgroundColor;
  final Color keyTextColor;
  final Color borderColor;

  const ImprovedHotKeyView({
    super.key,
    required this.hotKey,
    required this.keyBackgroundColor,
    required this.keyTextColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        // modifier keys
        ...(hotKey.modifiers ?? []).map(
          (modifier) => _buildKeyView(_getSimpleModifierName(modifier)),
        ),
        // main key
        _buildKeyView(hotKey.key.keyLabel),
      ],
    );
  }

  Widget _buildKeyView(String label) {
    return Container(
      height: 36,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: keyBackgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: keyTextColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getSimpleModifierName(HotKeyModifier modifier) {
    switch (modifier) {
      case HotKeyModifier.alt:
        return 'Alt';
      case HotKeyModifier.control:
        return 'Ctrl';
      case HotKeyModifier.shift:
        return 'Shift';
      case HotKeyModifier.meta:
        return 'Meta';
      case HotKeyModifier.capsLock:
        return 'Caps';
      case HotKeyModifier.fn:
        return 'Fn';
      }
  }
}
