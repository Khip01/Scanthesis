import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scanthesis_app/models/api_response.dart';
import 'package:scanthesis_app/repository/api_repository.dart';

class SettingsProvider extends ChangeNotifier {
  // Default Browse Directory
  Directory defaultBrowseDirectory, defaultImageStoreDirectory;

  // Custom Prompt
  String _defaultCustomPrompt =
      "Perform OCR on this image. Extract only the code and comments exactly as seen, without any explanation or additional content. Ensure the code is cleanly formatted and properly indented.";
  bool _defaultCustomPromptIsUnsaved = false;

  // Chat History
  bool _isUseChatHistory = true;

  // Base URL Endpoint
  String _baseUrlEndpoint = "http://127.0.0.1:8080/api";
  bool _baseUrlIsUnsaved = false;

  // Connection Test
  String _connectionTestUrl = "/check";
  ConnectionTestState _connectionTestState = ConnectionTestState.init;
  int? _lastStatusCode;
  String? _lastResponseText;

  SettingsProvider({
    required this.defaultBrowseDirectory,
    required this.defaultImageStoreDirectory,
  });

  // GETTER
  // Default Browse Directory
  Directory get getDefaultBrowseDirectory => defaultBrowseDirectory;

  // Custom Prompt
  String get getDefaultCustomPrompt => _defaultCustomPrompt;

  bool get getCustomPromptIsUnsaved => _defaultCustomPromptIsUnsaved;

  bool checkIsCustomPromptUnsaved(String input) {
    return _defaultCustomPrompt != input;
  }

  // Chat History
  bool get getIsUseChatHistory => _isUseChatHistory;

  // Default Image Store Directory
  Directory get getDefaultImageDirectory => defaultImageStoreDirectory;

  // Base URL Endpoint
  String get getBaseUrlEndpoint => _baseUrlEndpoint;

  bool get getBaseUrlIsUnsaved => _baseUrlIsUnsaved;

  bool checkIsBaseUrlUnsaved(String input) {
    return _baseUrlEndpoint != input;
  }

  // Connection Test URL
  String get getConnectionTestUrl => _connectionTestUrl;

  ConnectionTestState get getConnTestState => _connectionTestState;

  int? get getLastStatusCode => _lastStatusCode;

  String? get getLastResponseText => _lastResponseText;

  // TODO: SETTER
  // Default Browse Directory
  setDefaultBrowseDirectory(Directory directory) {
    defaultBrowseDirectory = directory;
    notifyListeners();
  }

  // Custom Prompt
  setDefaultCustomPrompt(String prompt) {
    _defaultCustomPrompt = prompt;
    notifyListeners();
  }

  bool setIsCustomPromptUnsaved(String prompt) {
    return _defaultCustomPrompt != prompt;
  }

  setDefaultCustomPromptState(bool unsaved) {
    _defaultCustomPromptIsUnsaved = unsaved;
    notifyListeners();
  }

  // Chat History
  setChatHistoryState(bool state) {
    _isUseChatHistory = state;
    notifyListeners();
  }

  toggleUseChatHistoryState() {
    _isUseChatHistory = !_isUseChatHistory;
    notifyListeners();
  }

  // Default Image Directory
  setDefaultImageStoreDirectory(Directory directory) {
    defaultImageStoreDirectory = directory;
    notifyListeners();
  }

  // BASE URL Endpoint
  setBaseUrlEndpoint(String url) {
    _baseUrlEndpoint = url;
    notifyListeners();
  }

  setBaseUrlState(bool unsaved) {
    _baseUrlIsUnsaved = unsaved;
    notifyListeners();
  }

  // Connection Test URL
  setConnectionTestUrl(String url) {
    _connectionTestUrl = url;
    notifyListeners();
  }

  void resetConnectionTest() {
    _connectionTestState = ConnectionTestState.init;
    _lastStatusCode = null;
    _lastResponseText = null;
    notifyListeners();
  }

  // TODO: Other Function
  Future<ApiResponse> getApiTest({
    required String baseUrl,
    required String urlPath,
  }) async {
    _connectionTestState = ConnectionTestState.loading;
    notifyListeners();

    try {
      ApiRepository apiRepository = ApiRepository(baseUrl: baseUrl);
      ApiResponse apiResponse = await apiRepository.checkConnection(urlPath);

      _lastStatusCode = apiResponse.statusCode;
      _lastResponseText = apiResponse.text;
      if (apiResponse.isError) {
        _connectionTestState = ConnectionTestState.failure;
      } else {
        _connectionTestState = ConnectionTestState.success;
      }

      notifyListeners();
      return apiResponse;
    } catch (e) {
      _lastStatusCode = null;
      _lastResponseText = e.toString();
      _connectionTestState = ConnectionTestState.failure;

      notifyListeners();
      rethrow;
    }
  }
}

enum ConnectionTestState { init, loading, success, failure }
