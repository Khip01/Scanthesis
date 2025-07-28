import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class HelperUtil {
  // TODO: byte -> file helper
  static Future<File> bytesToFile({
    required Uint8List imageBytes,
    required String fileName,
    required Directory directory,
  }) async {
    // creating file with path
    final filePath = path.join(directory.path, fileName);

    // creating file to directory path
    final file = File(filePath);
    await file.writeAsBytes(imageBytes);
    return file;
  }

  static Future<List<File>> moveFileToDirectory({
    required List<File> files,
    required String targetDirectoryPath,
  }) async {
    final tempDir = await getTemporaryDirectory();

    return Future.wait(
      files.map((sourceFile) async {
        String fileName = path.basename(sourceFile.path);
        String newFilePath = path.join(targetDirectoryPath, fileName);

        final isTemporaryFile = sourceFile.path.startsWith(tempDir.path);

        try {
          // use manual method (copy then delete) because to avoid this error:
          /*
          FileSystemException: Cannot rename file to
          '/home/khip/Documents/Scanthesis App - Image Chat History/file_image.png',
          path = '/tmp/file_image.png'
          (OS Error: Invalid cross-device link, errno = 18)
        */
          if (isTemporaryFile) {
            final copiedFile = await sourceFile.copy(newFilePath);
            await sourceFile.delete();
            return copiedFile;
          } else {
            return await sourceFile.copy(newFilePath);
          }
        } catch (_) {
          return await sourceFile.copy(newFilePath);
        }
      }),
    );
  }

  static Future deleteFiles(List<File> files) async {
    for (var file in files) {
      if (!(await file.exists())) continue;
      await file.delete();
    }
  }

  static String formatedFileName(String fileName) {
    // TODO: add timestamp to file name with {timestamp} format, etc
    Map<String, dynamic> formatTemplate = {
      "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
      "app_name": "scanthesis",

      ///  ..other format here
    };

    String result = fileName;
    formatTemplate.forEach((key, value) {
      result = result.replaceAll("{$key}", value);
    });

    return result;
  }

  static void showErrorDialog({
    required String title,
    required String message,
    required BuildContext context,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(message, style: const TextStyle(fontSize: 15)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
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
}
