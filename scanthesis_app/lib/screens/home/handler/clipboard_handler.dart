import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:scanthesis_app/screens/home/provider/clipboard_provider.dart';
import 'package:path/path.dart' as path;
import 'package:super_clipboard/super_clipboard.dart';

class ClipboardHandler {
  static Future<File?> getImageFromClipboard(BuildContext context) async {
    // change state to loading
    Provider.of<ClipboardImageProvider>(context, listen: false).setLoadingState(true);

    try {
      final clipboard = SystemClipboard.instance;
      if (clipboard == null) {
        if (!context.mounted) return null;
        _showErrorDialog(
            title: "Clipboard Not Available",
            message: "Your device doesn't support clipboard operations.",
            context: context
        );
        return null;
      }

      // get clipboard reader
      final reader = await clipboard.read();

      // check if clipboard is empty
      if (reader.items.isEmpty) {
        if (!context.mounted) return null;
        _showErrorDialog(
            title: "Empty Clipboard",
            message: "Nothing found in your clipboard. Please copy an image first.",
            context: context
        );
        return null;
      }

      // try to match specific format
      FileFormat? foundFormat;
      if (reader.canProvide(Formats.png)) {
        foundFormat = Formats.png;
      } else if (reader.canProvide(Formats.jpeg)) {
        foundFormat = Formats.jpeg;
      } else if (reader.canProvide(Formats.webp)) {
        foundFormat = Formats.webp;
      } else if (reader.canProvide(Formats.gif)) {
        foundFormat = Formats.gif;
      } else if (reader.canProvide(Formats.tiff)) {
        foundFormat = Formats.tiff;
      }

      // get image file from clipboard with found format
      if (foundFormat != null) {
        final file = await _readImageFile(reader, foundFormat);
        if (file != null) {
          if (!context.mounted) return file;
          Provider.of<ClipboardImageProvider>(context, listen: false).setLoadingState(false);
          return file;
        }
      }

      // if no image found in clipboard
      if (!context.mounted) return null;
      _showErrorDialog(
          title: "No Image Found",
          message: "Your clipboard doesn't contain an image. Try copying an image again.",
          context: context
      );
      return null;
    } catch (e) {
      _showErrorDialog(
          title: "Unexpected Error",
          message: "We encountered an error while accessing your clipboard: ${e.toString().split('\n')[0]}",
          context: context
      );
    } finally {
      // change loading state to false
      if (context.mounted) {
        Provider.of<ClipboardImageProvider>(context, listen: false).setLoadingState(false);
      }
    }
    return null;
  }

  // helper method to read image file data using a specific format
  static Future<File?> _readImageFile(ClipboardReader reader, FileFormat format) async {
    final completer = Completer<File?>();

    reader.getFile(format, (file) async {
      try {
        final allData = await file.readAll();
        if (allData.isNotEmpty) {
          final tempFile = await _bytesToFile(allData);
          completer.complete(tempFile);
          return;
        }
        completer.complete(null);
      } catch (_) {
        completer.complete(null);
        rethrow;
      }
    });

    return completer.future;
  }

  static void _showErrorDialog({
    required String title,
    required String message,
    required BuildContext context
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  static Future<File> _bytesToFile(Uint8List bytes) async {
    // creating tempfile path
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = path.join(tempDir.path, 'clipboard_image_$timestamp.png');

    // creating temporary file
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return file;
  }
}