import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scanthesis/models/api_request.dart';
import 'package:scanthesis/screens/home/provider/preview_image_provider.dart';

class RequestChat extends StatefulWidget {
  final ApiRequest request;

  const RequestChat({super.key, required this.request});

  @override
  State<RequestChat> createState() => _RequestChatState();
}

class _RequestChatState extends State<RequestChat> {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 730, minWidth: 0, minHeight: 0),
      child: Align(
        alignment: Alignment.centerRight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _imageFilePreview(),
                _chatBubble(themeData: themeData, constraints: constraints),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _imageFilePreview() {
    const double maxWidth = 730 * 2 / 3;
    const double spacing = 10;
    const double rightPadding = 16;

    int totalFiles = widget.request.files.length;
    int maxRows = 2;

    // calculate itemSize based on the number of files
    int columns = (totalFiles / maxRows).ceil();
    double availableWidth = maxWidth - rightPadding;
    double dynamicItemSize =
        (availableWidth - (spacing * (columns - 1))) / columns;

    // calculate maxSize of itemSize based on the number of files
    // (in this case size of 3 columns)
    // prevent the item size from becoming larger,
    // so I limited it to a maximum of like 3 columns in size
    int maxColumnsSize = 3;
    double maxItemSizeLike3Columns =
        (availableWidth - (spacing * (maxColumnsSize - 1))) / maxColumnsSize;

    double itemSize =
        dynamicItemSize > maxItemSizeLike3Columns
            ? maxItemSizeLike3Columns
            : dynamicItemSize;

    return Container(
      width: maxWidth,
      padding: const EdgeInsets.only(right: rightPadding, bottom: spacing),
      alignment: Alignment.centerRight,
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: spacing,
        runSpacing: spacing,
        children:
            widget.request.files.map((file) {
              return _itemFile(itemSize: itemSize, file: file);
            }).toList(),
      ),
    );
  }

  Widget _itemFile({required double itemSize, required File file}) {
    PreviewImageProvider previewImageProvider =
        Provider.of<PreviewImageProvider>(context);

    return Stack(
      children: [
        Container(
          width: itemSize,
          height: itemSize,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          clipBehavior: Clip.antiAlias,
          child: Image.file(file, fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              onTap: () {
                // TODO: ACTION DIALOG PREVIEW FILE
                previewImageProvider.setIsPreviewModeState(file);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _chatBubble({
    required ThemeData themeData,
    required BoxConstraints constraints,
  }) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: BoxConstraints(maxWidth: constraints.maxWidth * 2 / 3),
      decoration: BoxDecoration(
        color: themeData.inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      ),
      margin: EdgeInsets.only(bottom: 16, right: 16),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Text(
        widget.request.prompt,
        style: GoogleFonts.nunito().copyWith(
          fontSize: 18,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  // TODO: other functions
  int calculateColumns(int count) {
    if (count <= 3) return count;
    if (count <= 6) return (count / 2).ceil();
    return 4; // for 7 item
  }
}
