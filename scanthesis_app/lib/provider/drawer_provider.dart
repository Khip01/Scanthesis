import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:scanthesis_app/screens/home/provider/preview_image_provider.dart';

class DrawerProvider with ChangeNotifier {
  bool _isDrawerOpen = false;
  double _xAxisTranslateContentInitial = 0;
  double _xAxisTranslateDrawerInitial = -300;

  bool get isOpen => _isDrawerOpen;
  double get xAxisTranslateContent => _xAxisTranslateContentInitial;
  double get xAxisTranslateDrawer => _xAxisTranslateDrawerInitial;

  final double _contentBodyTranslateTo = 100;
  final double _drawerTranslateTo = 0;

  void toggleDrawer() {
    if (!_isDrawerOpen) {
      // drawer closed
      _isDrawerOpen = !_isDrawerOpen;
      _xAxisTranslateContentInitial = _contentBodyTranslateTo;
      _xAxisTranslateDrawerInitial = _drawerTranslateTo;
      PreviewImageProvider().closeIsPreviewModeState();
    } else {
      // drawer opened
      _isDrawerOpen = !_isDrawerOpen;
      _xAxisTranslateContentInitial = 0;
      _xAxisTranslateDrawerInitial = -300;
    }
    notifyListeners();
  }
}