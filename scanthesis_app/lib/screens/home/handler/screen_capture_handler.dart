import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:scanthesis_app/provider/drawer_provider.dart';
import 'package:scanthesis_app/screens/home/bloc/file_picker/file_picker_bloc.dart';
import 'package:scanthesis_app/screens/home/provider/preview_image_provider.dart';
import 'package:scanthesis_app/screens/home/provider/screen_capture_provider.dart';
import 'package:scanthesis_app/screens/router.dart';
import 'package:scanthesis_app/utils/helper_util.dart';
import 'package:screen_capturer/screen_capturer.dart';
import 'package:window_manager/window_manager.dart';

class ScreenCaptureHandler {

  static Future actionButtonTakeScreenshot({
    required BuildContext context,
  }) async {
    if (!HelperUtil.isLinuxWayland()) {
      // hide window before capture
      await windowManager.minimize();
    }
    File? file = await ScreenCaptureHandler.handleClickCapture(context);
    if (!HelperUtil.isLinuxWayland()) {
      // show window before get clipboard image
      await windowManager.show();
    }
    if (Platform.isLinux) windowManager.focus();
    if (file == null) return;

    if (!context.mounted) return;
    context.read<FilePickerBloc>().add(
      AddSingleFileEvent(file: file),
    );

    // perform navigation
    context.read<PreviewImageProvider>().closeIsPreviewModeState();
    context.read<DrawerProvider>().setDrawerState(false);
    context.goNamed(RouterEnum.home.name);
  }

  static Future<File?> handleClickCapture(BuildContext context) async {
    // ask permission in macOS
    if (Platform.isMacOS) {
      bool isAllowed = await screenCapturer.isAccessAllowed();
      if (!isAllowed) await screenCapturer.requestAccess();

      isAllowed = await screenCapturer.isAccessAllowed();
      if (!isAllowed) {
        if (context.mounted) {
          HelperUtil.showErrorDialog(
            title: "Permission Denied",
            message:
                "Screenshot capture is canceled. You did not give permission to capture the screen",
            context: context,
          );
        }
        return null;
      }
    }

    // change state to loading
    if (context.mounted) {
      Provider.of<ScreenCaptureProvider>(
        context,
        listen: false,
      ).setLoadingState(true);
    }

    try {
      Directory tempDir = await getTemporaryDirectory();
      String fileName = HelperUtil.formatedFileName(
        "{app_name}_captured_image_{timestamp}.png",
      );
      String imagePath = "${tempDir.path}/scanthesis_app/$fileName";

      if (Platform.isLinux && HelperUtil.isLinuxWayland()) {
        // hide window before capture
        await windowManager.hide();
      }

      // capture the screen
      await screenCapturer.capture(
        mode: CaptureMode.region,
        copyToClipboard: true,
        imagePath: imagePath,
        silent: true,
      );

      if (Platform.isLinux && HelperUtil.isLinuxWayland()) {
        // show window before get clipboard image
        await windowManager.show();
      }

      final imageBytes = await _getImageBytesFromClipboardWithTimeout();

      if (imageBytes == null || imageBytes.isEmpty) {
        if (context.mounted) {
          HelperUtil.showErrorDialog(
            title: "Screenshot Failed",
            message:
                "Unable to retrieve images from the clipboard after waiting for a while.",
            context: context,
          );
        }
        return null;
      }

      final tempFile = HelperUtil.bytesToFile(
        imageBytes: imageBytes,
        fileName: fileName,
        directory: tempDir,
      );

      return tempFile;
    } catch (e) {
      if (context.mounted) {
        String delayMessageWindows =
            Platform.isWindows ? "Please keep trying again." : "";
        HelperUtil.showErrorDialog(
          title: "Unexpected Error",
          message:
              "We encountered an error while accessing your screen capture: ${e.toString().split('\n')[0]}\n\n$delayMessageWindows",
          context: context,
        );
      }
    } finally {
      // change loading state to false
      if (context.mounted) {
        Provider.of<ScreenCaptureProvider>(
          context,
          listen: false,
        ).setLoadingState(false);
      }
    }
    return null;
  }

  static Future<Uint8List?> _getImageBytesFromClipboardWithTimeout() async {
    final stopwatch = Stopwatch()..start();
    double maxWaitTimeMs =
        (Platform.isWindows ? 10 : 3) * 1000; // 3 or 10 second timeout limit
    const checkIntervalMs = 200; // 200ms delay interval

    while (stopwatch.elapsedMilliseconds < maxWaitTimeMs) {
      final imageBytes = await screenCapturer.readImageFromClipboard();

      if (imageBytes != null && imageBytes.isNotEmpty) {
        // print("Got clipboard data after ${stopwatch.elapsedMilliseconds}ms");
        return imageBytes;
      }

      print(
        "Waiting for clipboard data... ${stopwatch.elapsedMilliseconds}ms elapsed",
      );
      await Future.delayed(Duration(milliseconds: checkIntervalMs));
    }

    // print(
    //   "Timed out after ${stopwatch.elapsedMilliseconds}ms waiting for clipboard data",
    // );
    return null;
  }
}
