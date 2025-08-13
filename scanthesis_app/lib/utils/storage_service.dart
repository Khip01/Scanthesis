import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:scanthesis_app/models/api_response.dart';
import 'package:scanthesis_app/models/chat.dart';
import 'package:scanthesis_app/provider/theme_provider.dart';
import 'package:scanthesis_app/screens/home/bloc/chats/chats_bloc.dart';
import 'package:scanthesis_app/screens/home/handler/screen_capture_handler.dart';
import 'package:scanthesis_app/screens/router.dart';
import 'package:scanthesis_app/screens/settings/handler/shortcut_hotkey_handler.dart';
import 'package:scanthesis_app/screens/settings/provider/settings_provider.dart';
import 'package:scanthesis_app/utils/helper_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyCustomPrompt = 'settings_custom_prompt';
  static const String _keyBaseUrl = 'settings_base_url';
  static const String _keyChatHistoryState = 'settings_chat_history_state';
  static const String _keyBrowseDir = 'settings_browse_dir';
  static const String _keyImageDir = 'settings_image_dir';
  static const String _keyConnectionTestUrl = 'settings_connection_test_url';
  static const String _keyChatsHistory = 'drawer_chats_history';
  static const String _keyScreenshotKeybind = 'settings_screenshot_keybind';

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
    final String? customPrompt = getCustomPrompt();
    final bool? historyState = getChatHistoryState();
    final String? imageDir = getImageDirectory();
    final String? baseUrl = getBaseUrl();
    final String? testUrl = getConnectionTestUrl();
    final List<Chat<MyCustomResponse>>? chats = getAllChatHistory();
    final HotKey? screenshotHotkey = await getScreenshotHotkeyFromPrefs();

    if (themeMode != null) {
      themeProvider.setTheme(themeMode);
    }

    if (browseDir != null) {
      settingsProvider.setDefaultBrowseDirectory(Directory(browseDir));
    }

    if (customPrompt != null) {
      settingsProvider.setDefaultCustomPrompt(customPrompt);
    }

    if (historyState != null) {
      settingsProvider.setChatHistoryState(historyState);
    }

    if (imageDir != null) {
      settingsProvider.setDefaultImageStoreDirectory(Directory(imageDir));
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

    if (screenshotHotkey != null) {
      settingsProvider.setScreenshotKeybind(screenshotHotkey);
      await ShortcutHotKeyHandler.registerShortcut(
        screenshotHotkey,
        keyDownHandler: (hotKey) async {
          if (navigatorKey.currentContext == null) return;
          await ScreenCaptureHandler.actionButtonTakeScreenshot(
            context: navigatorKey.currentState!.context,
          );
        },
      ); // register hotkey
    } else if (screenshotHotkey == null && !HelperUtil.isLinuxWayland()) {
      HotKey defaultHotkey = HotKey(
        key: LogicalKeyboardKey.keyS,
        modifiers: [
          Platform.isMacOS ? HotKeyModifier.meta : HotKeyModifier.control,
          HotKeyModifier.alt,
        ],
        scope: HotKeyScope.system,
      );
      settingsProvider.setScreenshotKeybind(
        defaultHotkey,
      ); // set default hotkey to provider
      await saveScreenshotHotkeyToPrefs(
        defaultHotkey,
      ); // save to shared_preferences
      await ShortcutHotKeyHandler.registerShortcut(
        defaultHotkey,
        keyDownHandler: (_) async {
          if (navigatorKey.currentContext == null) return;
          final BuildContext globalContext = navigatorKey.currentState!.context;
          await ScreenCaptureHandler.actionButtonTakeScreenshot(
            context: globalContext,
          );
        },
      ); // register hotkey
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

  // TODO: CUSTOM PROMPT
  Future saveCustomPrompt(String prompt) async {
    await prefs.setString(_keyCustomPrompt, prompt);
  }

  String? getCustomPrompt() {
    return prefs.getString(_keyCustomPrompt);
  }

  // TODO: CHAT HISTORY STATE
  Future saveChatHistoryState(bool enabled) async {
    await prefs.setBool(_keyChatHistoryState, enabled);
  }

  bool? getChatHistoryState() {
    return prefs.getBool(_keyChatHistoryState);
  }

  // TODO: DEFAULT IMAGE HISTORY DIRECTORY
  Future saveImageDirectory(String path) async {
    await prefs.setString(_keyImageDir, path);
  }

  String? getImageDirectory() {
    return prefs.getString(_keyImageDir);
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
  Future saveChatHistory(Chat<MyCustomResponse> chat) async {
    List<Chat<MyCustomResponse>> chatsHistory = getAllChatHistory() ?? [];
    chatsHistory.add(chat);
    await _saveChatList(chatsHistory);
  }

  Future removeMultipleChatHistory(
    List<Chat<MyCustomResponse>> chatToRemove,
  ) async {
    List<Chat<MyCustomResponse>> chatsHistory = getAllChatHistory() ?? [];
    chatsHistory.removeWhere(
      (chat) => chatToRemove.any((removeChat) => _isSameChat(chat, removeChat)),
    );
    await _saveChatList(chatsHistory);
  }

  List<Chat<MyCustomResponse>>? getAllChatHistory() {
    List<String>? chatsHistoryStr = prefs.getStringList(_keyChatsHistory);

    if (chatsHistoryStr == null) return null;

    List<Chat<MyCustomResponse>>? chatsHistory =
        chatsHistoryStr.map((chatStr) {
          return Chat<MyCustomResponse>.fromJson(
            jsonDecode(chatStr),
            parser: (json) => MyCustomResponse.fromJson(json),
          );
        }).toList();

    return chatsHistory;
  }

  // chat history: helper function
  Future<void> _saveChatList(List<Chat<MyCustomResponse>> chats) async {
    List<String> chatsHistoryStr =
        chats.map((chat) {
          return jsonEncode(chat.toJson(parser: (data) => data.toJson()));
        }).toList();

    await prefs.setStringList(_keyChatsHistory, chatsHistoryStr);
  }

  bool _isSameChat(Chat<MyCustomResponse> a, Chat<MyCustomResponse> b) {
    return jsonEncode(a.toJson(parser: (data) => data.toJson())) ==
        jsonEncode(b.toJson(parser: (data) => data.toJson()));
  }

  // TODO: SCREENSHOT KEYBIND
  Future<void> saveScreenshotHotkeyToPrefs(HotKey hotkey) async {
    // HotKey to JSON
    final Map<String, dynamic> hotkeyMap = {
      'keyId':
          hotkey.key is LogicalKeyboardKey
              ? (hotkey.key as LogicalKeyboardKey).keyId
              : null,
      'usageCode':
          hotkey.key is PhysicalKeyboardKey
              ? (hotkey.key as PhysicalKeyboardKey).usbHidUsage
              : null,
      'modifiers': hotkey.modifiers?.map((m) => m.index).toList() ?? [],
      'scope': hotkey.scope.index,
    };

    await prefs.setString(_keyScreenshotKeybind, jsonEncode(hotkeyMap));
    print('Hotkey berhasil disimpan: ${jsonEncode(hotkeyMap)}');
  }

  Future<HotKey?> getScreenshotHotkeyFromPrefs() async {
    final String? savedHotkeyString = prefs.getString(_keyScreenshotKeybind);

    if (savedHotkeyString == null) {
      return null;
    }

    try {
      final Map<String, dynamic> json = jsonDecode(savedHotkeyString);

      // get key
      KeyboardKey? key;
      if (json['keyId'] != null) {
        key = LogicalKeyboardKey.findKeyByKeyId(json['keyId']);
      } else if (json['usageCode'] != null) {
        key = PhysicalKeyboardKey.findKeyByCode(json['usageCode']);
      }

      if (key == null) {
        throw Exception('Key is null. Please check the saved hotkey.');
      }

      // get modifier
      final List<dynamic> modifierIndices = json['modifiers'] ?? [];
      final List<HotKeyModifier> modifiers =
          modifierIndices.map((index) => HotKeyModifier.values[index]).toList();

      // get scope
      final scope = HotKeyScope.values[json['scope'] ?? 0];

      return HotKey(key: key, modifiers: modifiers, scope: scope);
    } catch (e) {
      throw Exception('Failed to load hotkey from prefs: \n$e');
    }
  }
}
