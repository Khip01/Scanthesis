import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scanthesis_app/provider/theme_provider.dart';
import 'package:scanthesis_app/screens/settings/provider/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyBaseUrl = 'settings_base_url';
  static const String _keyChatHistory = 'settings_chat_history';
  static const String _keyBrowseDir = 'settings_browse_dir';
  static const String _keyImageDir = 'settings_image_dir';
  static const String _keyConnectionTestUrl = 'settings_connection_test_url';

  final SharedPreferences prefs;

  StorageService._({required this.prefs});

  static Future<StorageService> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs: prefs);
  }

  // TODO: GET ALL VALUE
  loadSettingsState({
    required SettingsProvider settingsProvider,
    required ThemeProvider themeProvider,
  }) async {
    final ThemeMode? themeMode = getThemeMode();
    final String? browseDir = getBrowseDirectory();
    final String? imageDir = getImageDirectory();
    final bool? historyState = getChatHistoryState();
    final String? baseUrl = getBaseUrl();
    final String? testUrl = getConnectionTestUrl();

    if (themeMode != null) {
      themeProvider.setTheme(themeMode);
    }

    if (browseDir != null) {
      settingsProvider.setDefaultBrowseDirectory(Directory(browseDir));
    }

    if (imageDir != null) {
      settingsProvider.setDefaultImageStoreDirectory(Directory(imageDir));
    }

    if (historyState != null) {
      settingsProvider.setChatHistoryState(historyState);
    }

    if (baseUrl != null) {
      settingsProvider.setBaseUrlEndpoint(baseUrl);
    }

    if (testUrl != null) {
      settingsProvider.setConnectionTestUrl(testUrl);
    }
  }

  // TODO: DEFAULT THEME MODE
  Future saveThemeMode(ThemeMode themeMode) async {
    await prefs.setInt('theme_mode', themeMode.index);
  }

  ThemeMode? getThemeMode() {
    int? themeModeIndex = prefs.getInt('theme_mode');
    switch (themeModeIndex) {
      case 0:
        return ThemeMode.system;
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return null;
    }
  }

  // TODO: DEFAULT BROWSE DIRECTORY
  Future saveBrowseDirectory(String path) async {
    await prefs.setString(_keyBrowseDir, path);
  }

  String? getBrowseDirectory() {
    return prefs.getString(_keyBrowseDir);
  }

  // TODO: DEFAULT IMAGE HISTORY DIRECTORY
  Future saveImageDirectory(String path) async {
    await prefs.setString(_keyImageDir, path);
  }

  String? getImageDirectory() {
    return prefs.getString(_keyImageDir);
  }

  // TODO: CHAT HISTORY STATE
  Future saveChatHistoryState(bool enabled) async {
    await prefs.setBool(_keyChatHistory, enabled);
  }

  bool? getChatHistoryState() {
    return prefs.getBool(_keyChatHistory);
  }

  // TODO: BASE URL ENDPOINT
  Future saveBaseUrl(String url) async {
    await prefs.setString(_keyBaseUrl, url);
  }

  String? getBaseUrl() {
    return prefs.getString(_keyBaseUrl);
  }

  // TODO: CONNECTION TEST ENDPOINT
  Future saveConnectionTestUrl(String url) async {
    await prefs.setString(_keyConnectionTestUrl, url);
  }

  String? getConnectionTestUrl() {
    return prefs.getString(_keyConnectionTestUrl);
  }
}
