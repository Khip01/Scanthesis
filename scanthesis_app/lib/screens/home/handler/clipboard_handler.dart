import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:scanthesis_app/screens/home/provider/clipboard_provider.dart';
import 'package:scanthesis_app/utils/helper_util.dart';

class ClipboardHandler {
  static Future<File?> getImageFromClipboard(BuildContext context) async {
    // change state to loading
    Provider.of<ClipboardImageProvider>(
      context,
      listen: false,
    ).setLoadingState(true);

    try {
      final Uint8List? image = await Pasteboard.image;

      if (image == null) {
        if (!context.mounted) return null;
        HelperUtil.showErrorDialog(
          title: "No Image Found",
          message:
              "Your clipboard doesn't contain an image. Try copying an image again.",
          context: context,
        );
        return null;
      }

      File file = await HelperUtil.bytesToFile(
        imageBytes: image,
        fileName: HelperUtil.formatedFileName(
          "{app_name}_clipboard_image_{timestamp}.png",
        ),
        directory: await getTemporaryDirectory(),
      );

      return file;
    } catch (e) {
      HelperUtil.showErrorDialog(
        title: "Unexpected Error",
        message:
            "We encountered an error while accessing your clipboard: \n${e.toString().split('\n')[0]}",
        context: context,
      );
    } finally {
      // change loading state to false
      if (context.mounted) {
        Provider.of<ClipboardImageProvider>(
          context,
          listen: false,
        ).setLoadingState(false);
      }
    }
    return null;
  }
}
