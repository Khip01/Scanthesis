import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:scanthesis_app/screens/home/provider/screen_capture_provider.dart';
import 'package:scanthesis_app/utils/helper_util.dart';
import 'package:screen_capturer/screen_capturer.dart';

class ScreenCaptureHandler {
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

      // capture the screen
      await screenCapturer.capture(
        mode: CaptureMode.region,
        copyToClipboard: true,
        imagePath: imagePath,
        silent: true,
      );

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
        HelperUtil.showErrorDialog(
          title: "Unexpected Error",
          message:
              "We encountered an error while accessing your screen capture: ${e.toString().split('\n')[0]}",
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
    const maxWaitTimeMs = 3000; // 3-second timeout limit
    const checkIntervalMs = 200; // 200ms delay interval

    while (stopwatch.elapsedMilliseconds < maxWaitTimeMs) {
      final imageBytes = await screenCapturer.readImageFromClipboard();

      if (imageBytes != null && imageBytes.isNotEmpty) {
        // print("Got clipboard data after ${stopwatch.elapsedMilliseconds}ms");
        return imageBytes;
      }

      // print(
      //   "Waiting for clipboard data... ${stopwatch.elapsedMilliseconds}ms elapsed",
      // );
      await Future.delayed(Duration(milliseconds: checkIntervalMs));
    }

    // print(
    //   "Timed out after ${stopwatch.elapsedMilliseconds}ms waiting for clipboard data",
    // );
    return null;
  }
}
