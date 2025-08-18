import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:provider/provider.dart';
import 'package:scanthesis/provider/theme_provider.dart';
import 'package:scanthesis/screens/home/handler/screen_capture_handler.dart';
import 'package:scanthesis/screens/router.dart';
import 'package:scanthesis/screens/settings/handler/shortcut_hotkey_handler.dart';
import 'package:scanthesis/screens/settings/provider/settings_provider.dart';
import 'package:scanthesis/screens/settings/widgets/improved_hotkey_view.dart';
import 'package:scanthesis/screens/settings/widgets/record_hotkey_dialog.dart';
import 'package:scanthesis/utils/helper_util.dart';
import 'package:scanthesis/utils/storage_service.dart';
import 'package:scanthesis/utils/style_util.dart';
import 'package:scanthesis/values/strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ScrollController settingsContentScrollController = ScrollController();
  final ScrollController connectionTestScrollController = ScrollController();
  final TextEditingController defaultBrowseDirectoryController =
      TextEditingController();
  final TextEditingController defaultCustomPromptController =
      TextEditingController();
  final TextEditingController defaultImageStorageDirectoryController =
      TextEditingController();
  final TextEditingController apiEndpointController = TextEditingController();
  final TextEditingController testApiConnectionController =
      TextEditingController();
  late final String _initialCustomPrompt;
  late final String _initialBaseUrl;
  late final StorageService storage;

  @override
  void initState() {
    super.initState();
    final SettingsProvider settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    _initialBaseUrl = settingsProvider.getBaseUrlEndpoint;
    if (apiEndpointController.text.isEmpty) {
      apiEndpointController.text = _initialBaseUrl;
    }

    _initialCustomPrompt = settingsProvider.getDefaultCustomPrompt;
    if (defaultCustomPromptController.text.isEmpty) {
      defaultCustomPromptController.text = _initialCustomPrompt;
    }
    _initStorage();
  }

  @override
  void dispose() {
    apiEndpointController.text = _initialBaseUrl;

    settingsContentScrollController.dispose();
    connectionTestScrollController.dispose();
    defaultBrowseDirectoryController.dispose();
    defaultCustomPromptController.dispose();
    defaultImageStorageDirectoryController.dispose();
    apiEndpointController.dispose();
    testApiConnectionController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      settingsProvider.setDefaultCustomPromptState(false);
      settingsProvider.setBaseUrlState(false);
      settingsProvider.resetConnectionTest();
    });
    super.deactivate();
  }

  Future<void> _initStorage() async {
    storage = await StorageService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 730,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Scrollbar(
            controller: settingsContentScrollController,
            trackVisibility: true,
            thumbVisibility: true,
            interactive: true,
            radius: Radius.circular(2),
            child: SingleChildScrollView(
              controller: settingsContentScrollController,
              padding: EdgeInsets.only(right: 28, top: 8, bottom: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SectionWidget(
                    sectionTitle: "Preferences",
                    children: [
                      SubSectionWidget(
                        subSectionTitle: "Theme Mode",
                        subSectionDescHead:
                            "Set the application's visual appearance.",
                        subSectionDescBody:
                            "Choose between Light, Dark, or follow the system default for a consistent look across platforms.",
                        child: themeModeChild(),
                      ),
                    ],
                  ),
                  SectionWidget(
                    sectionTitle: "Chat Settings",
                    children: [
                      SubSectionWidget(
                        subSectionTitle: "Default Browse Directory",
                        subSectionDescHead:
                            "Initial folder when opening the file picker.",
                        subSectionDescBody:
                            "Specifies the starting directory when users browse files, reducing navigation effort.",
                        child: defaultBrowseDirectoryChild(),
                      ),
                      TooltipVisibility(
                        visible: HelperUtil.isLinuxWayland(),
                        child: Tooltip(
                          message:
                              "This feature is not supported on Linux Wayland.",
                          verticalOffset: 60,
                          child: AbsorbPointer(
                            absorbing: HelperUtil.isLinuxWayland(),
                            child: Opacity(
                              opacity: HelperUtil.isLinuxWayland() ? 0.4 : 1.0,
                              child: SubSectionWidget(
                                subSectionTitle: "Screenshot Shortcut",
                                subSectionDescHead:
                                    "Set a key combination for taking screenshots..",
                                subSectionDescBody:
                                    "Define the keyboard shortcut to instantly capture your screen without manually navigating menus.",
                                child: screenshotShortcutChild(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SubSectionWidget(
                        subSectionTitle: "Default Custom Prompt",
                        subSectionDescHead:
                            "Set a default prompt for AI responses",
                        subSectionDescBody:
                            "Change your default prompt so that AI can generate more accurate and appropriate OCR text responses.",
                        child: customPromptChild(),
                      ),
                      SubSectionWidget(
                        subSectionTitle: "Chat History",
                        subSectionDescHead: "Enable local chat storage.",
                        subSectionDescBody:
                            "Automatically save conversations locally for future reference after app restarts.",
                        trailing: chatHistoryTrailing(),
                        onTap: () async {
                          final settingProvider = Provider.of<SettingsProvider>(
                            context,
                            listen: false,
                          );

                          settingProvider.toggleUseChatHistoryState();
                          await storage.saveChatHistoryState(
                            settingProvider.getIsUseChatHistory,
                          );
                        },
                        child: SizedBox.shrink(),
                      ),
                      Consumer<SettingsProvider>(
                        builder: (context, settings, _) {
                          final isEnabled = settings.getIsUseChatHistory;

                          return TooltipVisibility(
                            visible: !isEnabled,
                            child: Tooltip(
                              message:
                                  "This feature is now disabled and will not affect your settings.",
                              verticalOffset: 80,
                              child: AbsorbPointer(
                                absorbing: !isEnabled,
                                child: Opacity(
                                  opacity: isEnabled ? 1.0 : 0.4,
                                  child: SubSectionWidget(
                                    subSectionTitle: "Image Storage Directory",
                                    subSectionDescHead:
                                        "Organized media management.",
                                    subSectionDescBody:
                                        "Define a folder where all chat-related images are saved to keep media files easily accessible.",
                                    child: defaultImageStorageDirectoryChild(),
                                    // child: SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SectionWidget(
                    sectionTitle: "AI Integration",
                    children: [
                      SubSectionWidget(
                        subSectionTitle: "API Endpoint",
                        subSectionDescHead: "Configure your AI backend.",
                        subSectionDescBody:
                            "Provide the base URL endpoint to connect with the AI service or model used by the app.",
                        child: apiEndpointChild(),
                      ),
                      SubSectionWidget(
                        subSectionTitle: "Connection Test",
                        subSectionDescHead: "Verify your API configuration.",
                        subSectionDescBody:
                            "Run a connectivity check to ensure the AI service is reachable and properly set up.",
                        child: connectionTestChild(),
                      ),
                    ],
                  ),
                  SectionWidget(
                    sectionTitle: "About",
                    children: [
                      SubSectionWidget(
                        subSectionTitle: "About This Application",
                        subSectionDescHead:
                            "Extract code, prompt AI responses.",
                        subSectionDescBody:
                            "Instantly scan code from images and chat with your own AI - beautifully rendered in Markdown and fully customizable with your own prompts and API.",
                        child: SizedBox.shrink(),
                        onTap: () => aboutThisAppOnTap(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget themeModeChild() {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<ThemeMode>(
        dropdownColor: Theme.of(context).colorScheme.surface,
        onChanged: (value) async {
          if (value != null) {
            themeProvider.setTheme(value);
            await storage.saveThemeMode(value);
          }
        },
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        borderRadius: BorderRadius.circular(12),
        isExpanded: true,
        underline: SizedBox.shrink(),
        value: themeProvider.getThemeMode,
        items: [
          for (ThemeMode value in ThemeMode.values)
            DropdownMenuItem(value: value, child: Text(value.name)),
        ],
      ),
    );
  }

  Widget defaultBrowseDirectoryChild() {
    bool isLoadingState = false;
    final SettingsProvider settingsProvider = Provider.of<SettingsProvider>(
      context,
    );
    final String dirPath =
        settingsProvider.getDefaultBrowseDirectory.path.toString();
    final ThemeData themeData = Theme.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (defaultBrowseDirectoryController.text != dirPath) {
        defaultBrowseDirectoryController.text = dirPath;
      }
    });

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          width: double.maxFinite,
          margin: EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: defaultBrowseDirectoryController,
                  enabled: false,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                        topRight: Radius.circular(0),
                        bottomRight: Radius.circular(0),
                      ),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                  ),
                ),
              ),
              FilledButton(
                onPressed:
                    isLoadingState
                        ? null
                        : () async {
                          setState(() => isLoadingState = true);

                          String? path = await FilePicker.platform
                              .getDirectoryPath(
                                dialogTitle: "Pick a folder",
                                initialDirectory:
                                    settingsProvider
                                        .getDefaultBrowseDirectory
                                        .path,
                              );
                          if (path != null) {
                            settingsProvider.setDefaultBrowseDirectory(
                              Directory(path),
                            );
                            await storage.saveBrowseDirectory(path);
                          }
                          setState(() => isLoadingState = false);
                        },
                style: FilledButton.styleFrom(
                  elevation: 0,
                  backgroundColor: themeData.colorScheme.surface,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.only(
                      topLeft: Radius.circular(0),
                      bottomLeft: Radius.circular(0),
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  overlayColor: themeData.colorScheme.onSurface,
                ),
                child: Center(
                  child:
                      isLoadingState
                          ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: themeData.iconTheme.color,
                            ),
                          )
                          : Icon(
                            Icons.folder_open,
                            size: 24,
                            color: themeData.iconTheme.color,
                          ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget screenshotShortcutChild() {
    SettingsProvider settingsProvider = Provider.of<SettingsProvider>(context);
    HotKey? screenshotKeybind = settingsProvider.getScreenshotKeybind;
    ThemeData themeData = Theme.of(context);

    if (HelperUtil.isLinuxWayland()) {
      return Container(
        width: double.maxFinite,
        margin: EdgeInsets.only(top: 8),
        child: Text(
          "Screenshot shortcut is not supported on Linux Wayland.",
          style: TextStyle(color: Colors.red),
        ),
      );
    } else if (screenshotKeybind == null) {
      return Container(
        width: double.maxFinite,
        margin: EdgeInsets.only(top: 8),
        child: Text(
          "No screenshot shortcut set. Try to restart this app.",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    void createNewShortcutDialog() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return RecordHotkeyDialog(
            oldHotkey: screenshotKeybind,
            onHotKeyRecorded: (newHotKey) async {
              await ShortcutHotKeyHandler.unregisterShortcut(screenshotKeybind);
              await ShortcutHotKeyHandler.registerShortcut(
                newHotKey,
                keyDownHandler: (_) async {
                  if (navigatorKey.currentState == null) return;
                  final BuildContext globalContext =
                      navigatorKey.currentState!.context;
                  await ScreenCaptureHandler.actionButtonTakeScreenshot(
                    context: globalContext,
                  );
                },
              );
              settingsProvider.setScreenshotKeybind(newHotKey);
              storage.saveScreenshotHotkeyToPrefs(newHotKey);
            },
          );
        },
      );
    }

    Widget editKeybindButton = Tooltip(
      message: "Edit screenshot shortcut",
      child: SizedBox(
        height: 40,
        width: 40,
        child: IconButton(
          onPressed: () => createNewShortcutDialog(),
          icon: Icon(Icons.edit, size: 20),
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );

    return Container(
      margin: EdgeInsets.only(top: 8),
      child: Row(
        children: [
          ImprovedHotKeyView(
            hotKey: screenshotKeybind,
            keyBackgroundColor: themeData.colorScheme.surface,
            keyTextColor: themeData.colorScheme.onSurface,
            borderColor: themeData.dividerColor.withValues(alpha: 0.5),
          ),
          SizedBox(width: 8),
          editKeybindButton,
        ],
      ),
    );
  }

  Widget customPromptChild() {
    final SettingsProvider settingsProvider = Provider.of<SettingsProvider>(
      context,
    );
    final String customPrompt = settingsProvider.getDefaultCustomPrompt;
    final ThemeData themeData = Theme.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!settingsProvider.getCustomPromptIsUnsaved &&
          defaultCustomPromptController.text != customPrompt) {
        defaultCustomPromptController.text = customPrompt;
      }
    });

    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.only(top: 8),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: defaultCustomPromptController,
                onChanged: (value) {
                  if (settingsProvider.checkIsCustomPromptUnsaved(value)) {
                    settingsProvider.setDefaultCustomPromptState(true);
                  } else {
                    settingsProvider.setDefaultCustomPromptState(false);
                  }
                },
                minLines: 3,
                maxLines: 4,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(
                    left: 16,
                    top: 20,
                    bottom: 20,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      topRight: Radius.circular(
                        settingsProvider.getCustomPromptIsUnsaved ? 0 : 12,
                      ),
                      bottomRight: Radius.circular(
                        settingsProvider.getCustomPromptIsUnsaved ? 0 : 12,
                      ),
                    ),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      topRight: Radius.circular(
                        settingsProvider.getCustomPromptIsUnsaved ? 0 : 12,
                      ),
                      bottomRight: Radius.circular(
                        settingsProvider.getCustomPromptIsUnsaved ? 0 : 12,
                      ),
                    ),
                    // borderSide: BorderSide(color: Colors.transparent),
                    borderSide: BorderSide(
                      color: themeData.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: settingsProvider.getCustomPromptIsUnsaved,
              child: Tooltip(
                message: "Save changes",
                child: FilledButton(
                  onPressed: () async {
                    settingsProvider.setDefaultCustomPrompt(
                      defaultCustomPromptController.text,
                    );
                    settingsProvider.setDefaultCustomPromptState(false);
                    await storage.saveCustomPrompt(
                      defaultCustomPromptController.text,
                    );
                  },
                  style: FilledButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.only(
                        topLeft: Radius.circular(0),
                        bottomLeft: Radius.circular(0),
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    overlayColor: themeData.colorScheme.onSurface,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check,
                      size: 24,
                      color: themeData.iconTheme.color,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatHistoryTrailing() {
    final SettingsProvider settingsProvider = Provider.of<SettingsProvider>(
      context,
    );

    return Switch(
      onChanged: (value) async {
        settingsProvider.setChatHistoryState(value);
        await storage.saveChatHistoryState(value);
      },
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return null;
        } else {
          return Theme.of(context).iconTheme.color;
        }
      }),
      thumbColor: WidgetStatePropertyAll(
        Theme.of(context).colorScheme.secondary,
      ),
      value: settingsProvider.getIsUseChatHistory,
    );
  }

  Widget defaultImageStorageDirectoryChild() {
    bool isLoadingState = false;
    final SettingsProvider settingsProvider = Provider.of<SettingsProvider>(
      context,
    );
    final String dirPath =
        settingsProvider.getDefaultImageDirectory.path.toString();
    final ThemeData themeData = Theme.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (defaultImageStorageDirectoryController.text != dirPath) {
        defaultImageStorageDirectoryController.text = dirPath;
      }
    });

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          width: double.maxFinite,
          margin: EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: defaultImageStorageDirectoryController,
                  enabled: false,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                        topRight: Radius.circular(0),
                        bottomRight: Radius.circular(0),
                      ),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                  ),
                ),
              ),
              FilledButton(
                onPressed:
                    isLoadingState
                        ? null
                        : () async {
                          setState(() => isLoadingState = true);

                          String? path = await FilePicker.platform
                              .getDirectoryPath(
                                dialogTitle: "Pick a folder",
                                initialDirectory:
                                    settingsProvider
                                        .getDefaultImageDirectory
                                        .path,
                              );
                          if (path != null) {
                            settingsProvider.setDefaultImageStoreDirectory(
                              Directory(path),
                            );
                            await storage.saveImageDirectory(path);
                          }

                          setState(() => isLoadingState = false);
                        },
                style: FilledButton.styleFrom(
                  elevation: 0,
                  backgroundColor: themeData.colorScheme.surface,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.only(
                      topLeft: Radius.circular(0),
                      bottomLeft: Radius.circular(0),
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  overlayColor: themeData.colorScheme.onSurface,
                ),
                child: Center(
                  child:
                      isLoadingState
                          ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: themeData.iconTheme.color,
                            ),
                          )
                          : Icon(
                            Icons.folder_open,
                            size: 24,
                            color: themeData.iconTheme.color,
                          ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget apiEndpointChild() {
    final SettingsProvider settingsProvider = Provider.of<SettingsProvider>(
      context,
    );
    final String baseUrl = settingsProvider.getBaseUrlEndpoint;
    final ThemeData themeData = Theme.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!settingsProvider.getBaseUrlIsUnsaved &&
          apiEndpointController.text != baseUrl) {
        apiEndpointController.text = baseUrl;
      }
    });

    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: apiEndpointController,
              onChanged: (value) {
                if (settingsProvider.checkIsBaseUrlUnsaved(value)) {
                  settingsProvider.setBaseUrlState(true);
                } else {
                  settingsProvider.setBaseUrlState(false);
                }
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    topRight: Radius.circular(
                      settingsProvider.getBaseUrlIsUnsaved ? 0 : 12,
                    ),
                    bottomRight: Radius.circular(
                      settingsProvider.getBaseUrlIsUnsaved ? 0 : 12,
                    ),
                  ),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    topRight: Radius.circular(
                      settingsProvider.getBaseUrlIsUnsaved ? 0 : 12,
                    ),
                    bottomRight: Radius.circular(
                      settingsProvider.getBaseUrlIsUnsaved ? 0 : 12,
                    ),
                  ),
                  // borderSide: BorderSide(color: Colors.transparent),
                  borderSide: BorderSide(color: themeData.colorScheme.primary),
                ),
              ),
            ),
          ),
          Visibility(
            visible: settingsProvider.getBaseUrlIsUnsaved,
            child: Tooltip(
              message: "Save changes",
              child: FilledButton(
                onPressed: () async {
                  settingsProvider.setBaseUrlEndpoint(
                    apiEndpointController.text,
                  );
                  settingsProvider.setBaseUrlState(false);
                  await storage.saveBaseUrl(apiEndpointController.text);
                },
                style: FilledButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.only(
                      topLeft: Radius.circular(0),
                      bottomLeft: Radius.circular(0),
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  overlayColor: themeData.colorScheme.onSurface,
                ),
                child: Center(
                  child: Icon(
                    Icons.check,
                    size: 24,
                    color: themeData.iconTheme.color,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget connectionTestChild() {
    final SettingsProvider settingsProvider = Provider.of<SettingsProvider>(
      context,
    );
    final String baseUrl = settingsProvider.getBaseUrlEndpoint;
    final String testUrl = settingsProvider.getConnectionTestUrl;
    final ThemeData themeData = Theme.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!settingsProvider.getBaseUrlIsUnsaved &&
          testApiConnectionController.text != testUrl) {
        testApiConnectionController.text = testUrl;
      }
    });

    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.only(top: 8),
      child: Stack(
        children: [
          Positioned(
            child: Consumer<SettingsProvider>(
              builder: (context, settingsProvider, _) {
                final state = settingsProvider.getConnTestState;

                if (state == ConnectionTestState.init ||
                    state == ConnectionTestState.loading) {
                  return SizedBox.shrink();
                }

                final statusCode = settingsProvider.getLastStatusCode;
                final statusText = Strings.httpStatusDescription(statusCode);
                final responseText =
                    settingsProvider.getLastResponseText ?? "No response.";

                return Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 60,
                    bottom: 16,
                  ),
                  decoration: BoxDecoration(
                    color: themeData.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      SizedBox(
                        height: 40,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              // color: Colors.green,
                              alignment: Alignment.centerLeft,
                              width: 104,
                              height: double.maxFinite,
                              child: Text(
                                "Code",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                height: double.maxFinite,
                                child: Text(
                                  "Description",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(thickness: 0.3),

                      // Body
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 104,
                            child: Text("$statusCode ($statusText)"),
                          ),
                          Expanded(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: 200),
                              child: SelectionArea(
                                child: Scrollbar(
                                  controller: connectionTestScrollController,
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  interactive: true,
                                  radius: Radius.circular(2),
                                  child: SingleChildScrollView(
                                    controller: connectionTestScrollController,
                                    child: Padding(
                                      padding: EdgeInsetsGeometry.only(
                                        right: 20,
                                      ),
                                      child: GptMarkdown(responseText),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                Tooltip(
                  message: baseUrl,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: themeData.colorScheme.surface,
                      // color: Colors.green,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                        topRight: Radius.circular(0),
                        bottomRight: Radius.circular(0),
                      ),
                      // border: Border.all(width: 0.0001, color: Colors.transparent),
                    ),
                    child: Center(
                      child: Text("{BASE URL}", textAlign: TextAlign.center),
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      settingsProvider.setConnectionTestUrl(value);
                    },
                    controller: testApiConnectionController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(0),
                          bottomLeft: Radius.circular(0),
                          topRight: Radius.circular(0),
                          bottomRight: Radius.circular(0),
                        ),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(0),
                          bottomLeft: Radius.circular(0),
                          topRight: Radius.circular(0),
                          bottomRight: Radius.circular(0),
                        ),
                        borderSide: BorderSide(
                          color: themeData.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                Consumer<SettingsProvider>(
                  builder: (context, settingsProvider, _) {
                    final isLoading =
                        settingsProvider.getConnTestState ==
                        ConnectionTestState.loading;

                    return FilledButton(
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                try {
                                  await settingsProvider.getApiTest(
                                    baseUrl:
                                        settingsProvider.getBaseUrlEndpoint,
                                    urlPath:
                                        settingsProvider.getConnectionTestUrl,
                                  );
                                  await storage.saveConnectionTestUrl(
                                    settingsProvider.getConnectionTestUrl,
                                  );
                                } catch (e) {
                                  debugPrint("❌ Failed: $e");
                                }
                              },
                      style: FilledButton.styleFrom(
                        elevation: 0,
                        backgroundColor: themeData.colorScheme.surface,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.only(
                            topLeft: Radius.circular(0),
                            bottomLeft: Radius.circular(0),
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        overlayColor: themeData.colorScheme.onSurface,
                      ),
                      child: Center(
                        child:
                            isLoading
                                ? SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: themeData.iconTheme.color,
                                  ),
                                )
                                : Text(
                                  "GET",
                                  style: TextStyle(
                                    color: themeData.iconTheme.color,
                                  ),
                                ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void aboutThisAppOnTap(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          insetPadding: EdgeInsets.symmetric(vertical: 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 730),
            child: AboutDialog(
              applicationName: 'Scanthesis',
              applicationVersion: '0.0.1',
              applicationIcon: const FlutterLogo(),
              children: [
                SizedBox(
                  width: double.maxFinite,
                  height: MediaQuery.sizeOf(context).height - 260,
                  child: SelectionArea(
                    child: SingleChildScrollView(
                      child: GptMarkdown(
                        Strings.aboutApp,
                        style: GoogleFonts.nunito().copyWith(
                          fontSize: 18,
                          color: colorScheme.onSurface,
                        ),
                        highlightBuilder: (context, text, style) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: StyleUtil.windowButtonGrey.withAlpha(35),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              text,
                              style: GoogleFonts.sourceCodePro(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SectionWidget extends StatelessWidget {
  final String sectionTitle;
  final List<Widget> children;

  const SectionWidget({
    super.key,
    required this.sectionTitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    Color textTitleColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: EdgeInsets.only(bottom: 16),
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            sectionTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textTitleColor,
            ),
          ),
          Divider(thickness: 0.3),
          ...children,
        ],
      ),
    );
  }
}

class SubSectionWidget extends StatelessWidget {
  final String subSectionTitle, subSectionDescHead, subSectionDescBody;
  final Widget child;
  final Widget? trailing;
  final Function()? onTap;

  const SubSectionWidget({
    super.key,
    required this.subSectionTitle,
    required this.subSectionDescHead,
    required this.subSectionDescBody,
    required this.child,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color textTitleColor = Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.maxFinite,
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          subSectionTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textTitleColor,
                          ),
                        ),
                      ),
                      Text(subSectionDescHead),
                      Text(subSectionDescBody),
                    ],
                  ),
                ),
                trailing ?? SizedBox.shrink(),
              ],
            ),
            child,
          ],
        ),
      ),
    );
  }
}
