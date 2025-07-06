import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scanthesis_app/screens/home/handler/clipboard_handler.dart';
import 'package:scanthesis_app/utils/style_util.dart';

import '../bloc/file_picker/file_picker_bloc.dart';

class FloatingInput extends StatefulWidget {
  const FloatingInput({super.key});

  @override
  State<FloatingInput> createState() => _FloatingInputState();
}

class _FloatingInputState extends State<FloatingInput> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(bottom: 30),
        // height: 80,
        width: 736,
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListFileWidget(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: BlocBuilder<FilePickerBloc, FilePickerState>(
                  builder: (filePickerContext, filePickerState) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Drop the file anywhere",
                          style: TextStyle(fontSize: 16),
                        ),
                        Expanded(child: SizedBox()),
                        Tooltip(
                          message: "Open File",
                          child: IconButton(
                            onPressed: () async {
                              await _actionButtonOpenFile(
                                filePickerContext: filePickerContext,
                              );
                            },
                            icon: Icon(Icons.folder_copy, size: 20),
                          ),
                        ),
                        Tooltip(
                          message: "Paste Copied Image",
                          child: IconButton(
                            onPressed: () async {
                              await _actionButtonClipboard(
                                filePickerContext: filePickerContext,
                              );
                            },
                            icon: Icon(Icons.paste, size: 20),
                          ),
                        ),
                        Tooltip(
                          message: "Capture Screen",
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.crop, size: 20),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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

  // Other Functions
  Future<List<File>> _getFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result == null) return [];

    List<File> files = result.paths.map((path) => File(path!)).toList();

    return files;
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
    return BlocBuilder<FilePickerBloc, FilePickerState>(
      builder: (filePickerContext, filePickerState) {
        if (filePickerState is FilePickerLoading) {
          return Container(
            height: 80,
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ListView(children: [CircularProgressIndicator()]),
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
                  final newOffset = _listFileScrollController.offset + event.scrollDelta.dy;
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
              },
              child: Tooltip(
                message: file.path.split('/').last,
                preferBelow: false,
                margin: EdgeInsets.only(bottom: 16),
                constraints: BoxConstraints(
                  maxWidth: 400,
                ),
                waitDuration: Duration(milliseconds: 500),
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
                              onTap: () async {
                                await _actionDeleteFile(
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
              ),
            );
          },
        );
      },
    );
  }

  Widget _customIcon() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8, top: 8, bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 188, 8),
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
  Future _actionDeleteFile({
    required BuildContext filePickerContext,
    required File file,
  }) async {
    filePickerContext.read<FilePickerBloc>().add(RemoveFileEvent(file: file));
  }
}
