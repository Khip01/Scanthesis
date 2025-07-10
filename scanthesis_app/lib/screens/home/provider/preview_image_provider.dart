import 'dart:io';

import 'package:flutter/cupertino.dart';

class PreviewImageProvider with ChangeNotifier {
  bool _isPreviewMode = false;
  File? _file;

  bool get isPreviewMode => _isPreviewMode;
  File? get file => _file;

  void setIsPreviewModeState(File fileState){
    _isPreviewMode = true;
    _file = fileState;
    notifyListeners();
  }

  void closeIsPreviewModeState(){
    _isPreviewMode = false;
    _file = null;
    notifyListeners();
  }
}