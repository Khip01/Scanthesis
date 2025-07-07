import 'package:flutter/material.dart';

class OpenFileProvider with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoadingState(bool isLoadingState) {
    _isLoading = isLoadingState;
    notifyListeners();
  }
}
