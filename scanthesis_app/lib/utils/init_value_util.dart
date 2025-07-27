import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:scanthesis_app/screens/settings/provider/SettingsProvider.dart';

class InitValueUtil {
  static Future<SettingsProvider> initSettingsProvider() async {
    Directory defaultBrowseDirectory =
        await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();

    Directory docDir = await getApplicationDocumentsDirectory();
    Directory defaultImageStoreDirectory = Directory(
        p.join(docDir.path, 'Scanthesis App - Image Chat History'),
    );
    if (!await defaultImageStoreDirectory.exists()) {
      // create if not exist
      await defaultImageStoreDirectory.create(recursive: true);
    }

    return SettingsProvider(
      defaultBrowseDirectory: defaultBrowseDirectory,
      defaultImageStoreDirectory: defaultImageStoreDirectory,
    );
  }
}
