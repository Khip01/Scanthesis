import 'package:flutter/cupertino.dart';

class CustomPromptProvider with ChangeNotifier {
  bool _isUsingCustomPrompt = false;

  bool get isUsingCustomPrompt => _isUsingCustomPrompt;

  void toggleUsingCustomPrompt() {
    _isUsingCustomPrompt = !_isUsingCustomPrompt;
    notifyListeners();
  }

  void resetUsingCustomPrompt() {
    _isUsingCustomPrompt = false;
    notifyListeners();
  }
}
