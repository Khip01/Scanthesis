import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scanthesis_app/models/chat.dart';
import 'package:scanthesis_app/provider/theme_provider.dart';
import 'package:scanthesis_app/screens/home/bloc/chats/chats_bloc.dart';
import 'package:scanthesis_app/screens/settings/provider/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyBaseUrl = 'settings_base_url';
  static const String _keyChatHistoryState = 'settings_chat_history_state';
  static const String _keyBrowseDir = 'settings_browse_dir';
  static const String _keyImageDir = 'settings_image_dir';
  static const String _keyConnectionTestUrl = 'settings_connection_test_url';
  static const String _keyChatsHistory = 'drawer_chats_history';

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
    required ChatsBloc chatsBloc,
  }) async {
    final ThemeMode? themeMode = getThemeMode();
    final String? browseDir = getBrowseDirectory();
    final String? imageDir = getImageDirectory();
    final bool? historyState = getChatHistoryState();
    final String? baseUrl = getBaseUrl();
    final String? testUrl = getConnectionTestUrl();
    final List<Chat>? chats = getAllChatHistory();

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

    if (chats != null) {
      chatsBloc.add(LoadChatHistoryEvent(chats: chats));
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
    await prefs.setBool(_keyChatHistoryState, enabled);
  }

  bool? getChatHistoryState() {
    return prefs.getBool(_keyChatHistoryState);
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

  // TODO: CHAT HISTORY
  Future saveChatHistory(Chat chat) async {
    List<Chat> chatsHistory = getAllChatHistory() ?? [];
    chatsHistory.add(chat);
    await _saveChatList(chatsHistory);
  }

  Future removeMultipleChatHistory(List<Chat> chatToRemove) async {
    List<Chat> chatsHistory = getAllChatHistory() ?? [];
    chatsHistory.removeWhere(
      (chat) => chatToRemove.any((removeChat) => _isSameChat(chat, removeChat)),
    );
    await _saveChatList(chatsHistory);
  }

  List<Chat>? getAllChatHistory() {
    List<String>? chatsHistoryStr = prefs.getStringList(_keyChatsHistory);

    if (chatsHistoryStr == null) return null;

    List<Chat>? chatsHistory =
        chatsHistoryStr
            .map((chatStr) => Chat.fromJson(jsonDecode(chatStr)))
            .toList();

    return chatsHistory;
  }

  // chat history: helper function
  Future<void> _saveChatList(List<Chat> chats) async {
    List<String> chatsHistoryStr =
        chats.map((chatStr) => jsonEncode(chatStr.toJson())).toList();
    await prefs.setStringList(_keyChatsHistory, chatsHistoryStr);
  }

  bool _isSameChat(Chat a, Chat b) {
    return jsonEncode(a.toJson()) == jsonEncode(b.toJson());
  }
}
