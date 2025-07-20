import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scanthesis_app/provider/drawer_provider.dart';
import 'package:scanthesis_app/utils/style_util.dart';

class CustomDrawer extends StatefulWidget {
  final Duration duration;

  const CustomDrawer({super.key, required this.duration});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final DrawerProvider drawerProvider = Provider.of<DrawerProvider>(context);

    return AnimatedContainer(
      transform: Matrix4.translationValues(
        drawerProvider.xAxisTranslateDrawer,
        0,
        0,
      ),
      duration: widget.duration,
      curve: Curves.easeOutQuart,
      width: 300,
      color: themeData.scaffoldBackgroundColor,
      child: drawerContent(),
    );
  }

  Widget drawerContent() {
    // Warning: Nested Function
    Widget drawerHeader() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12, bottom: 12, right: 16),
            child: drawerCustomListTile(
              title: "New Chat",
              icon: Icons.add_card_rounded,
              onPressed: () {
                // TODO: Create New Chat
              },
              useDeleteAction: false,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              "History",
              style: GoogleFonts.nunito().copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w100,
              ),
            ),
          ),
        ],
      );
    }

    // Warning: Nested Function
    Widget drawerHistory() {
      return Expanded(
        child: Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          child: ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(right: 16),
            itemCount: 100,
            itemBuilder: (_, index) {
              return drawerCustomListTile(
                title:
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua $index",
                onPressed: () {
                  // TODO: Open Chat
                },
                useDeleteAction: true,
                deleteActionOnPressed: () {
                  // TODO: Do Other Action
                },
              );
            },
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 56, left: 8, right: 8),
      child: Column(children: [drawerHeader(), drawerHistory()]),
    );
  }

  Widget drawerCustomListTile({
    required String title,
    IconData? icon,
    required Function() onPressed,
    required bool useDeleteAction,
    Function()? deleteActionOnPressed,
  }) {
    Color? buttonColor = IconTheme.of(context).color;
    ThemeData themeData = Theme.of(context);
    bool isHovered = false;

    // Warning: Nested Function
    Widget fadeText({
      required String text,
      double fadeFraction = 0.2, // 20% of the text is faded
      required TextStyle? style,
    }) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.black, Colors.transparent],
                stops: [1 - fadeFraction, 1.0],
              ).createShader(Rect.fromLTRB(0, 0, bounds.width, bounds.height));
            },
            blendMode: BlendMode.dstIn,
            child: SizedBox(
              width: constraints.maxWidth,
              child: Text(
                text,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.clip,
                style: style,
              ),
            ),
          );
        },
      );
    }

    // Warning: Nested Function
    Widget customDeleteButton([Function()? onTap]){
      return InkWell(
        onTap: onTap,
        splashColor: StyleUtil.windowCloseRed.withAlpha(80),
        hoverColor: StyleUtil.windowCloseRed.withAlpha(40),
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: 42,
          width: 42,
          child: Center(child: Icon(Icons.delete_rounded, color: StyleUtil.windowCloseRed,)),
        ),
      );
    }

    return SizedBox(
      width: double.maxFinite,
      child: StatefulBuilder(
        builder: (context, setState) {
          return FilledButton.icon(
            onPressed: onPressed,
            onHover: (value) {
              if (useDeleteAction) {
                setState(() {
                  isHovered = value;
                });
              }
            },
            style: FilledButton.styleFrom(
              padding: EdgeInsets.zero,
              elevation: 0,
              alignment: Alignment.centerLeft,
              overlayColor: themeData.dividerColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: Colors.transparent,
            ),
            icon:
                icon != null
                    ? Padding(
                      padding: EdgeInsets.only(top: 12, bottom: 12, left: 16),
                      child: Icon(icon, size: 16, color: buttonColor),
                    )
                    : null,
            label: Padding(
              padding: EdgeInsets.only(left: icon != null ? 4 : 0),
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 12,
                      bottom: 12,
                      right: 16,
                      left: icon == null ? 16 : 0,
                    ),
                    child: fadeText(
                      text: title,
                      fadeFraction: 0.2,
                      style: GoogleFonts.nunito().copyWith(
                        color: themeData.colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isHovered,
                    child: customDeleteButton(
                      useDeleteAction ? deleteActionOnPressed : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
