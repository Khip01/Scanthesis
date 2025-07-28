import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:scanthesis_app/models/api_request.dart';
import 'package:scanthesis_app/provider/drawer_provider.dart';
import 'package:scanthesis_app/provider/theme_provider.dart';
import 'package:scanthesis_app/screens/home/bloc/request/request_bloc.dart';
import 'package:scanthesis_app/screens/home/bloc/response/response_bloc.dart';
import 'package:scanthesis_app/screens/home/handler/clipboard_handler.dart';
import 'package:scanthesis_app/screens/home/handler/screen_capture_handler.dart';
import 'package:scanthesis_app/screens/home/provider/clipboard_provider.dart';
import 'package:scanthesis_app/screens/home/provider/custom_prompt_provider.dart';
import 'package:scanthesis_app/screens/home/provider/open_file_provider.dart';
import 'package:scanthesis_app/screens/home/provider/preview_image_provider.dart';
import 'package:scanthesis_app/screens/home/provider/screen_capture_provider.dart';
import 'package:scanthesis_app/screens/home/widgets/custom_prompt_field.dart';
import 'package:scanthesis_app/screens/home/widgets/send_button_shortcut.dart';
import 'package:scanthesis_app/screens/settings/provider/SettingsProvider.dart';
import 'package:scanthesis_app/utils/helper_util.dart';
import 'package:scanthesis_app/utils/style_util.dart';
import 'package:scanthesis_app/values/strings.dart';

import '../bloc/file_picker/file_picker_bloc.dart';

class FloatingInput extends StatefulWidget {
  final FocusNode sendButtonFocusNode;
  final Function(FilePickerState state, bool isDrawerOpen)
  updateSendButtonFocusBasedOnStates;

  const FloatingInput({
    super.key,
    required this.sendButtonFocusNode,
    required this.updateSendButtonFocusBasedOnStates,
  });

  @override
  State<FloatingInput> createState() => _FloatingInputState();
}

class _FloatingInputState extends State<FloatingInput> {
  final TextEditingController promptController = TextEditingController();

  // @override
  // void initState() {
  //   super.initState();
  //   _sendButtonFocusNode = FocusNode();
  // }
  //
  // @override
  // void dispose() {
  //   _sendButtonFocusNode.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final openFileProvider = Provider.of<OpenFileProvider>(context);
    final clipboardImageProvider = Provider.of<ClipboardImageProvider>(context);
    final screenCaptureProvider = Provider.of<ScreenCaptureProvider>(context);
    final drawerProvider = context.watch<DrawerProvider>();

    final ColorScheme themeColorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.bottomCenter,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            margin: EdgeInsets.only(bottom: 30),
            width: 736,
            constraints: BoxConstraints(
              maxHeight: constraints.maxHeight * 1 / 2,
            ),
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListFileWidget(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: BlocBuilder<FilePickerBloc, FilePickerState>(
                        builder: (filePickerContext, filePickerState) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Drop the image file anywhere",
                                style: TextStyle(fontSize: 16),
                              ),
                              Expanded(child: SizedBox()),
                              Tooltip(
                                message: "Open File",
                                child: IconButton(
                                  onPressed:
                                      openFileProvider.isLoading
                                          ? () {}
                                          : () async {
                                            await _actionButtonOpenFile(
                                              filePickerContext:
                                                  filePickerContext,
                                            );
                                          },
                                  icon:
                                      openFileProvider.isLoading
                                          ? CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).iconTheme.color,
                                            constraints: BoxConstraints(
                                              maxHeight: 20,
                                              maxWidth: 20,
                                              minHeight: 20,
                                              minWidth: 20,
                                            ),
                                          )
                                          : Icon(Icons.folder_copy, size: 20),
                                  style: IconButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              Tooltip(
                                message: "Paste Copied Image",
                                child: IconButton(
                                  onPressed:
                                      clipboardImageProvider.isLoading
                                          ? () {}
                                          : () async {
                                            await _actionButtonClipboard(
                                              filePickerContext:
                                                  filePickerContext,
                                            );
                                          },
                                  icon:
                                      clipboardImageProvider.isLoading
                                          ? CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).iconTheme.color,
                                            constraints: BoxConstraints(
                                              maxHeight: 20,
                                              maxWidth: 20,
                                              minHeight: 20,
                                              minWidth: 20,
                                            ),
                                          )
                                          : Icon(Icons.paste, size: 20),
                                  style: IconButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              Tooltip(
                                message: "Capture Screen",
                                child: IconButton(
                                  onPressed:
                                      screenCaptureProvider.isLoading
                                          ? () {}
                                          : () async {
                                            await _actionButtonTakeScreenshot(
                                              filePickerContext:
                                                  filePickerContext,
                                            );
                                          },
                                  icon:
                                      screenCaptureProvider.isLoading
                                          ? CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).iconTheme.color,
                                            constraints: BoxConstraints(
                                              maxHeight: 20,
                                              maxWidth: 20,
                                              minHeight: 20,
                                              minWidth: 20,
                                            ),
                                          )
                                          : Icon(Icons.crop, size: 20),
                                  style: IconButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              _sendButton(
                                filePickerContext: filePickerContext,
                                filePickerState: filePickerState,
                                themeProvider: themeProvider,
                                themeColorScheme: themeColorScheme,
                                drawerProvider: drawerProvider,
                                updateFocusBasedOnStates:
                                    widget.updateSendButtonFocusBasedOnStates,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    CustomPromptField(
                      sendButtonFocusNode: widget.sendButtonFocusNode,
                      promptController: promptController,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // TODO: Button Actions
  Future _actionButtonOpenFile({
    required BuildContext filePickerContext,
  }) async {
    List<File> files = await _getFiles();

    if (!filePickerContext.mounted) return;
    filePickerContext.read<FilePickerBloc>().add(
      AddMultipleFileEvent(files: files),
    );
  }

  Future _actionButtonClipboard({
    required BuildContext filePickerContext,
  }) async {
    File? file = await ClipboardHandler.getImageFromClipboard(context);
    if (file == null) return;

    if (!filePickerContext.mounted) return;
    filePickerContext.read<FilePickerBloc>().add(
      AddSingleFileEvent(file: file),
    );
  }

  Future _actionButtonTakeScreenshot({
    required BuildContext filePickerContext,
  }) async {
    File? file = await ScreenCaptureHandler.handleClickCapture(context);
    if (file == null) return;

    if (!filePickerContext.mounted) return;
    filePickerContext.read<FilePickerBloc>().add(
      AddSingleFileEvent(file: file),
    );
  }

  // TODO: WIDGET
  Widget _sendButton({
    required BuildContext filePickerContext,
    required FilePickerState filePickerState,
    required ThemeProvider themeProvider,
    required ColorScheme themeColorScheme,
    required DrawerProvider drawerProvider,
    required Function(FilePickerState state, bool isDrawerOpen)
    updateFocusBasedOnStates,
  }) {
    // This Function Moved to HomeScreen
    // void updateFocusBasedOnStates(FilePickerState state, bool isDrawerOpen) {
    //   if (state.files.isNotEmpty && !isDrawerOpen) {
    //     widget.sendButtonFocusNode.requestFocus();
    //   } else {
    //     widget.sendButtonFocusNode.unfocus();
    //   }
    // }

    return IgnorePointer(
      ignoring: filePickerState.files.isEmpty,
      child: Tooltip(
        message: "or press `Enter` key to send",
        child: BlocBuilder<ResponseBloc, ResponseState>(
          builder: (responseContext, responseState) {
            return BlocBuilder<RequestBloc, RequestState>(
              builder: (requestContext, requestState) {
                return ElevatedButton(
                  onPressed:
                      drawerProvider.isOpen || filePickerState.files.isEmpty
                          ? null
                          : () {
                            _actionSendButton(
                              requestContext: requestContext,
                              filePickerContext: filePickerContext,
                              responseContext: responseContext,
                              files: filePickerState.files,
                              prompt: promptController.text,
                            );
                          },
                  style: ElevatedButton.styleFrom(
                    enableFeedback: false,
                    padding: EdgeInsets.zero,
                    backgroundColor:
                        themeProvider.isDarkMode(context)
                            ? themeColorScheme.primary
                            : themeColorScheme.secondary,
                  ),
                  child: ListenableBuilder(
                    listenable: drawerProvider,
                    builder: (context, child) {
                      updateFocusBasedOnStates(
                        filePickerState,
                        drawerProvider.isOpen,
                      );
                      return BlocListener<FilePickerBloc, FilePickerState>(
                        listener: (
                          filePickerListenerContext,
                          filePickerListenerState,
                        ) {
                          updateFocusBasedOnStates(
                            filePickerListenerState,
                            drawerProvider.isOpen,
                          );
                        },
                        child: SendButtonShortcut(
                          action: () {
                            _actionSendButton(
                              requestContext: requestContext,
                              filePickerContext: filePickerContext,
                              responseContext: responseContext,
                              files: filePickerState.files,
                              prompt: promptController.text,
                            );
                          },
                          focusNode: widget.sendButtonFocusNode,
                          child: SizedBox(
                            height: 52,
                            width: 52,
                            child: Icon(Icons.send_rounded),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // TODO: Button actions
  _actionSendButton({
    required BuildContext requestContext,
    required BuildContext filePickerContext,
    required BuildContext responseContext,
    required List<File> files,
    required String prompt,
  }) {
    final isCustom =
        Provider.of<CustomPromptProvider>(
          context,
          listen: false,
        ).isUsingCustomPrompt;

    final ApiRequest request = ApiRequest(
      files: List<File>.from(files),
      prompt: isCustom ? prompt : Strings.defaultPrompt,
    );
    filePickerContext.read<FilePickerBloc>().add(ClearFilesEvent());

    // Bloc Request
    requestContext.read<RequestBloc>().add(AddRequestEvent(request: request));
    // Bloc Response
    responseContext.read<ResponseBloc>().add(
      AddResponseEvent(request: request),
    );
  }

  // Other Functions
  Future<List<File>> _getFiles() async {
    // change state to loading
    Provider.of<OpenFileProvider>(context, listen: false).setLoadingState(true);
    Directory defaultBrowseDir =
        Provider.of<SettingsProvider>(
          context,
          listen: false,
        ).getDefaultBrowseDirectory;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        initialDirectory: defaultBrowseDir.path,
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (result == null) return [];

      List<File> files = result.paths.map((path) => File(path!)).toList();

      return files;
    } catch (e) {
      if (context.mounted) {
        HelperUtil.showErrorDialog(
          title: "Unexpected Error",
          message:
              "We encountered an error while accessing your clipboard: ${e.toString().split('\n')[0]}",
          context: context,
        );
      }
    } finally {
      // change loading state to false
      if (context.mounted) {
        Provider.of<OpenFileProvider>(
          context,
          listen: false,
        ).setLoadingState(false);
      }
    }
    return [];
  }
}

class ListFileWidget extends StatefulWidget {
  const ListFileWidget({super.key});

  @override
  State<ListFileWidget> createState() => _ListFileWidgetState();
}

class _ListFileWidgetState extends State<ListFileWidget> {
  final ScrollController _listFileScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FilePickerBloc, FilePickerState>(
      listener: (filePickerContext, filePickerState) {
        if (filePickerState is FilePickerError) {
          HelperUtil.showErrorDialog(
            title: "Maximum file limit reached",
            message: filePickerState.errorMessage,
            context: context,
          );

          // Reset to FilePickerLoaded
          context.read<FilePickerBloc>().add(ResetFilePickerErrorEvent());
        }
      },
      builder: (filePickerContext, filePickerState) {
        if (filePickerState is FilePickerLoading) {
          return Container(
            height: 80,
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ListView(
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).iconTheme.color,
                ),
              ],
            ),
          );
        } else if (filePickerState is FilePickerLoaded &&
            filePickerState.files.isNotEmpty) {
          final List<File> files = filePickerState.files;
          return Container(
            // color: Colors.green,
            height: 80 + 16,
            width: double.maxFinite,
            padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
            child: Listener(
              onPointerSignal: (PointerSignalEvent event) {
                if (event is PointerScrollEvent) {
                  final newOffset =
                      _listFileScrollController.offset + event.scrollDelta.dy;
                  _listFileScrollController.jumpTo(
                    newOffset.clamp(
                      _listFileScrollController.position.minScrollExtent,
                      _listFileScrollController.position.maxScrollExtent,
                    ),
                  );
                }
              },
              child: Scrollbar(
                controller: _listFileScrollController,
                child: ListView.separated(
                  padding: EdgeInsets.only(bottom: 16),
                  controller: _listFileScrollController,
                  separatorBuilder: (context, index) => SizedBox(width: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    return _fileItem(files[index]);
                  },
                ),
              ),
            ),
          );
        } else {
          return SizedBox();
        }
      },
    );
  }

  Widget _fileItem(File file) {
    PreviewImageProvider previewImageProvider =
        Provider.of<PreviewImageProvider>(context);
    bool isHover = false;

    return BlocBuilder<FilePickerBloc, FilePickerState>(
      builder: (filePickerContext, filePickerState) {
        return StatefulBuilder(
          builder: (context, setState) {
            return InkWell(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              onHover: (value) {
                setState(() {
                  isHover = value;
                });
              },
              onTap: () {
                // TODO: ACTION DIALOG PREVIEW FILE
                previewImageProvider.setIsPreviewModeState(file);
              },
              child: Container(
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 0.3,
                  ),
                ),
                child: Stack(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [_customIcon(), _customTitle(file)],
                    ),
                    Visibility(
                      visible: isHover,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: InkWell(
                            onTap: () {
                              _actionDeleteFile(
                                filePickerContext: filePickerContext,
                                file: file,
                              );
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Ink(
                              decoration: BoxDecoration(
                                color: StyleUtil.windowCloseRedPressed,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.close,
                                size: 12,
                                color: StyleUtil.iconLight,
                              ),
                            ),
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
      },
    );
  }

  Widget _customIcon() {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    ColorScheme themeColorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8, top: 8, bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color:
              themeProvider.isDarkMode(context)
                  ? themeColorScheme.primary
                  : themeColorScheme.secondary,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        child: SizedBox(
          height: 40,
          width: 40,
          child: Icon(Icons.image, color: StyleUtil.lightScaffoldBackground),
        ),
      ),
    );
  }

  Widget _customTitle(File file) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          // mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              file.path.split('/').last,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(file.path.split('.').last.toUpperCase()),
          ],
        ),
      ),
    );
  }

  // TODO: Button actions
  _actionDeleteFile({
    required BuildContext filePickerContext,
    required File file,
  }) {
    filePickerContext.read<FilePickerBloc>().add(RemoveFileEvent(file: file));
  }
}
