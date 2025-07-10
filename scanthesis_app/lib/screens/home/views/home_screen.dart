import 'dart:io';
import 'dart:ui';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:scanthesis_app/provider/theme_provider.dart';
import 'package:scanthesis_app/screens/home/bloc/file_picker/file_picker_bloc.dart';
import 'package:scanthesis_app/screens/home/widgets/floating_input.dart';
import 'package:scanthesis_app/screens/home/widgets/custom_app_bar.dart';
import 'package:scanthesis_app/utils/style_util.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        child: Column(
          children: [
            if (Platform.isWindows)
              const CustomAppBar()
            else
              const SizedBox.shrink(),
            DropzoneArea(),
          ],
        ),
      ),
    );
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
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilePickerBloc, FilePickerState>(
      builder: (filePickerContext, filePickerState) {
        return Expanded(
          child: Stack(
            children: [
              ..._dropzoneMainContent(context),
              IgnorePointer(
                ignoring: true,
                child: DropTarget(
                  onDragEntered: (_) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _dropzoneMainContent(BuildContext context) {
    return [
      Column(
        children: [
          AppBar(
            scrolledUnderElevation: 0,
            actions: [
              _toggleThemeIcon(context: context),
              const SizedBox(width: 16),
            ],
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          HomeContent(),
          HomeFooterSpacer(),
        ],
      ),
      FloatingInput(),
    ];
  }

  void _showSnackBar({required bool showError}) {
    IconData icon = showError ? Icons.error : Icons.warning;
    String message =
        showError
            ? "No files accepted, please provide the correct image file format!"
            : "Some files were skipped due to invalid format!";
    Color iconColor = showError ? StyleUtil.windowCloseRed : StyleUtil.windowWarningYellow;

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

  Widget _toggleThemeIcon({required BuildContext context}) {
    Color? buttonColor = IconTheme.of(context).color;
    ThemeProvider theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDarkMode(context);

    return IconButton(
      icon: Icon(isDark ? Icons.sunny : Icons.nights_stay, color: buttonColor),
      onPressed: () {
        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
      },
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 28, top: 16),
          child: Center(
            child: Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 0.3,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                constraints: BoxConstraints(maxWidth: 680),
                child: Column(
                  children: [_codeCardHeader(), _codeCardContent()],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _codeCardHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      width: double.maxFinite,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text("dart"),
          ),
          Tooltip(
            message: "Copy Code",
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.copy, size: 16),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _codeCardContent() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      // height: 900,
      width: double.maxFinite,
      color: Theme.of(context).colorScheme.onSecondary,
      child: Text(
        "Hello World!",
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}

class HomeFooterSpacer extends StatelessWidget {
  const HomeFooterSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 100, width: double.maxFinite);
  }
}
