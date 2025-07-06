import 'package:flutter/material.dart';

class ClipboardImageProvider with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoadingState(bool isLoadingState) {
    _isLoading = isLoadingState;
    notifyListeners();
  }
}