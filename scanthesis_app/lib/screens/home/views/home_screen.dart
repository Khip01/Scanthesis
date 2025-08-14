import 'dart:io';
import 'dart:ui';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:scanthesis_app/models/chat.dart';
import 'package:scanthesis_app/provider/drawer_provider.dart';
import 'package:scanthesis_app/provider/theme_provider.dart';
import 'package:scanthesis_app/screens/home/bloc/chats/chats_bloc.dart';
import 'package:scanthesis_app/screens/home/bloc/file_picker/file_picker_bloc.dart';
import 'package:scanthesis_app/screens/home/bloc/request/request_bloc.dart';
import 'package:scanthesis_app/screens/home/bloc/response/response_bloc.dart';
import 'package:scanthesis_app/screens/home/provider/preview_image_provider.dart';
import 'package:scanthesis_app/screens/home/widgets/custom_drawer.dart';
import 'package:scanthesis_app/screens/home/widgets/floating_input.dart';
import 'package:scanthesis_app/screens/home/widgets/preview_image.dart';
import 'package:scanthesis_app/screens/home/widgets/request_chat.dart';
import 'package:scanthesis_app/screens/home/widgets/response_chat.dart';
import 'package:scanthesis_app/screens/settings/provider/settings_provider.dart';
import 'package:scanthesis_app/utils/storage_service.dart';
import 'package:scanthesis_app/utils/style_util.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TrayListener, WindowListener {

  @override
  void initState() {
    trayManager.addListener(this);
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.addListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        child: Column(
          children: [
            DropzoneArea(),
          ],
        ),
      ),
    );
  }

  @override
  void onTrayIconMouseDown() {
    super.onTrayIconMouseDown();
    windowManager.show();
  }

  @override
  void onTrayIconRightMouseDown() async {
    super.onTrayIconRightMouseDown();
    await trayManager.popUpContextMenu(bringAppToFront: true);
  }

  @override
  void onWindowClose() async {
    await windowManager.hide();
    super.onWindowClose();
  }
}

class DropzoneArea extends StatefulWidget {
  const DropzoneArea({super.key});

  @override
  State<DropzoneArea> createState() => _DropzoneAreaState();
}

class _DropzoneAreaState extends State<DropzoneArea>
    with TickerProviderStateMixin {
  late AnimationController _blurController, _opacityController;
  late Animation<double> _blurAnimation, _opacityAnimation;
  late FocusNode _sendButtonFocusNode;
  late final StorageService storage;

  @override
  void initState() {
    // TODO: blur animation
    _blurController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _blurAnimation = Tween<double>(begin: 0, end: 5.0).animate(
      CurvedAnimation(parent: _blurController, curve: Curves.easeOutExpo),
    );

    // TODO: opacity animation
    _opacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _opacityController, curve: Curves.linear),
    );

    // TODO: global send button focus node
    _sendButtonFocusNode = FocusNode();

    // TODO: Init shared preferences
    _initStorage();
    super.initState();
  }

  @override
  void dispose() {
    _sendButtonFocusNode.dispose();
    super.dispose();
  }

  (List<File>, bool) _getImageFileFromDropzone({
    required List<DropItem> dropItems,
    required List<String> allowedExtensions,
  }) {
    List<File> files = [];
    bool isWarning = false;

    for (DropItem dropItem in dropItems) {
      File file = File(dropItem.path);
      if (!allowedExtensions.contains(file.path.split('.').last)) {
        isWarning = true;
        continue;
      }

      files.add(file);
    }

    return (files, isWarning);
  }

  void updateFocusBasedOnStates(FilePickerState state, bool isDrawerOpen) {
    if (state.files.isNotEmpty && !isDrawerOpen) {
      _sendButtonFocusNode.requestFocus();
    } else {
      _sendButtonFocusNode.unfocus();
    }
  }

  Future _initStorage() async {
    storage = await StorageService.init();
  }

  @override
  Widget build(BuildContext context) {
    final DrawerProvider drawerProvider = Provider.of<DrawerProvider>(context);
    final Duration drawerDuration = Duration(milliseconds: 400);

    return Expanded(
      child: Stack(
        children: [
          AnimatedContainer(
            transform: Matrix4.translationValues(
              drawerProvider.xAxisTranslateContent,
              0,
              0,
            ),
            curve: Curves.easeOutQuart,
            duration: drawerDuration,
            child: _animatedTranslatedContent(),
          ),
          IgnorePointer(
            ignoring: !drawerProvider.isOpen,
            child: GestureDetector(
              onTap: () {
                drawerProvider.toggleDrawer();
              },
              child: AnimatedContainer(
                duration: drawerDuration,
                color:
                    drawerProvider.isOpen
                        ? Colors.black.withAlpha(160)
                        : Colors.transparent,
                curve: Curves.easeOutQuart,
              ),
            ),
          ),
          CustomDrawer(duration: drawerDuration),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: SizedBox(
              height: 56,
              width: 44,
              child: AppBar(
                scrolledUnderElevation: 0,
                leading: _toggleSideTabIcon(),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _animatedTranslatedContent() {
    final PreviewImageProvider previewImageProvider =
        Provider.of<PreviewImageProvider>(context);
    final DrawerProvider drawerProvider = Provider.of<DrawerProvider>(context);

    return Stack(
      children: [
        ..._dropzoneMainContent(context),
        PreviewImage(),
        BlocBuilder<FilePickerBloc, FilePickerState>(
          builder: (filePickerContext, filePickerState) {
            return IgnorePointer(
              ignoring: true,
              child: DropTarget(
                enable: !drawerProvider.isOpen,
                onDragEntered: (_) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  previewImageProvider.closeIsPreviewModeState();
                  _blurController.forward();
                  _opacityController.forward();
                },
                onDragExited: (_) {
                  _blurController.reverse();
                  _opacityController.reverse();
                },
                onDragDone: (details) {
                  var (listItem, isWarning) = _getImageFileFromDropzone(
                    dropItems: details.files,
                    allowedExtensions: ['jpg', 'jpeg', 'png'],
                  );
                  filePickerContext.read<FilePickerBloc>().add(
                    AddMultipleFileEvent(files: listItem),
                  );

                  if (isWarning) {
                    if (isWarning && listItem.isEmpty) {
                      _showSnackBar(showError: true);
                    } else {
                      _showSnackBar(showError: false);
                    }
                  }
                },
                child: AnimatedBuilder(
                  animation: _opacityAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: child,
                    );
                  },
                  child: AnimatedBuilder(
                    animation: _blurAnimation,
                    builder: (context, child) {
                      return BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: _blurAnimation.value,
                          sigmaY: _blurAnimation.value,
                        ),
                        child: child,
                      );
                    },
                    child: SizedBox(
                      height: double.maxFinite,
                      width: double.maxFinite,
                      child: Center(
                        child: Text(
                          "Drop Image Files Only",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  List<Widget> _dropzoneMainContent(BuildContext context) {
    return [
      Column(
        children: [
          AppBar(
            scrolledUnderElevation: 0,
            actions: [_toggleThemeIcon(), const SizedBox(width: 16)],
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          HomeContent(sendButtonFocusNode: _sendButtonFocusNode),
          HomeFooterSpacer(),
        ],
      ),
      FloatingInput(
        sendButtonFocusNode: _sendButtonFocusNode,
        updateSendButtonFocusBasedOnStates: updateFocusBasedOnStates,
      ),
    ];
  }

  void _showSnackBar({required bool showError}) {
    IconData icon = showError ? Icons.error : Icons.warning;
    String message =
        showError
            ? "No files accepted, please provide the correct image file format!"
            : "Some files were skipped due to invalid format!";
    Color iconColor =
        showError ? StyleUtil.windowCloseRed : StyleUtil.windowWarningYellow;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).dividerColor, width: 0.4),
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 7),
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: Row(
          children: [
            Icon(icon, color: iconColor),
            SizedBox(width: 16),
            Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleSideTabIcon() {
    Color? buttonColor = IconTheme.of(context).color;
    DrawerProvider drawerState = Provider.of<DrawerProvider>(context);

    return IconButton(
      icon: RotatedBox(
        quarterTurns: !drawerState.isOpen ? 0 : 2,
        child: Icon(Icons.keyboard_tab, color: buttonColor),
      ),
      onPressed: () {
        drawerState.toggleDrawer();
      },
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _toggleThemeIcon() {
    Color? buttonColor = IconTheme.of(context).color;
    ThemeProvider theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDarkMode(context);

    return IconButton(
      icon: Icon(isDark ? Icons.sunny : Icons.nights_stay, color: buttonColor),
      onPressed: () async {
        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
        await storage.saveThemeMode(theme.getThemeMode);
      },
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final FocusNode sendButtonFocusNode;

  const HomeContent({super.key, required this.sendButtonFocusNode});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  ScrollController contentScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        width: double.maxFinite,
        child: SelectionArea(
          onSelectionChanged: (value) {
            if (value == null || value.plainText.isEmpty) {
              widget.sendButtonFocusNode.requestFocus();
            }
          },
          child: Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            radius: Radius.circular(2),
            controller: contentScrollController,
            child: SingleChildScrollView(
              controller: contentScrollController,
              padding: EdgeInsets.only(bottom: 28, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BlocBuilder<RequestBloc, RequestState>(
                    builder: (requestBlocContext, requestBlocState) {
                      if (requestBlocState is RequestInitial) {
                        return SizedBox.shrink();
                      } else if (requestBlocState is RequestSuccess &&
                          requestBlocState.request != null) {
                        return RequestChat(request: requestBlocState.request!);
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  ),
                  BlocConsumer<ResponseBloc, ResponseState>(
                    listener: (responseBlocContext, responseBlocState) {
                      if (responseBlocState is ResponseSuccess &&
                          responseBlocState.response.rawBody.isNotEmpty &&
                          !responseBlocState.response.isFromHistory) {
                        final requestBlocState =
                            context.read<RequestBloc>().state;
                        final settingsProvider =
                            responseBlocContext
                                .read<SettingsProvider>();
                        if (requestBlocState is RequestSuccess &&
                            requestBlocState.request != null &&
                            settingsProvider.getIsUseChatHistory) {
                          final req = requestBlocState.request!;
                          final res = responseBlocState.response;

                          context.read<ChatsBloc>().add(
                            AddChatEvent(
                              chat: Chat(request: req, response: res),
                            ),
                          );
                        }
                      }
                    },
                    builder: (responseBlocContext, responseBlocState) {
                      if (responseBlocState is ResponseLoading) {
                        return CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).iconTheme.color,
                        );
                      } else if (responseBlocState is ResponseError) {
                        return Text("Error: ${responseBlocState.errorMessage}");
                      } else if (responseBlocState is ResponseInitial) {
                        return Text("Try to drop and send something");
                      } else if (responseBlocState is ResponseSuccess &&
                          responseBlocState.response.rawBody.isNotEmpty) {
                        return ResponseChat(
                          response: responseBlocState.response,
                        );
                      } else {
                        return Text("Something went wrong");
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeFooterSpacer extends StatelessWidget {
  const HomeFooterSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilePickerBloc, FilePickerState>(
      builder: (filePickerContext, filePickerState) {
        return Container(
          constraints: BoxConstraints(
            maxHeight:
                filePickerState.files.isNotEmpty
                    ? (MediaQuery.sizeOf(context).height * 1 / 2)
                    : 100,
          ),
          width: double.maxFinite,
        );
      },
    );
  }
}
