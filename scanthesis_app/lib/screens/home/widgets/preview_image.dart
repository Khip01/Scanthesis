import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scanthesis_app/screens/home/provider/preview_image_provider.dart';
import 'package:scanthesis_app/utils/helper_util.dart';

class PreviewImage extends StatelessWidget {
  const PreviewImage({super.key});

  @override
  Widget build(BuildContext context) {
    PreviewImageProvider previewImageProvider =
        Provider.of<PreviewImageProvider>(context);

    double windowHeight = MediaQuery.sizeOf(context).height;
    double windowWidth = MediaQuery.sizeOf(context).width;

    if (previewImageProvider.isPreviewMode &&
        previewImageProvider.file != null) {
      String fileName = HelperUtil.getFileName(previewImageProvider.file!);

      return GestureDetector(
        onTap: () {
          previewImageProvider.closeIsPreviewModeState();
        },
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            alignment: Alignment.center,
            height: windowHeight,
            width: windowWidth,
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: windowWidth * 2 / 3,
                    maxHeight: windowHeight * 2 / 3,
                  ),
                  child: Image.file(previewImageProvider.file!),
                ),
                SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: windowWidth * 3 / 4),
                  child: SelectableText(
                    fileName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
