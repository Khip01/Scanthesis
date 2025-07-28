import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scanthesis_app/models/chat.dart';
import 'package:scanthesis_app/provider/drawer_provider.dart';
import 'package:scanthesis_app/screens/home/bloc/chats/chats_bloc.dart';
import 'package:scanthesis_app/screens/home/bloc/request/request_bloc.dart';
import 'package:scanthesis_app/screens/home/bloc/response/response_bloc.dart';
import 'package:scanthesis_app/screens/router.dart';
import 'package:scanthesis_app/utils/style_util.dart';
import 'package:scanthesis_app/values/chats_dummy.dart';

class CustomDrawer extends StatefulWidget {
  final Duration duration;

  const CustomDrawer({super.key, required this.duration});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final ScrollController scrollController = ScrollController();

  //TODO: load chats history
  loadChatHistory(BuildContext context) {
    context.read<ChatsBloc>().add(
      LoadChatHistoryEvent(chats: ChatsDummy.chats),
    );
  }

  @override
  void initState() {
    loadChatHistory(context);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  void didChangeDependencies() {
    if (!Provider.of<DrawerProvider>(context).isOpen &&
        context.read<ChatsBloc>().state.selectedChats.isNotEmpty) {
      // to cancel selection when drawer is closed
      context.read<ChatsBloc>().add(ClearSelectedChatsEvent());
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final DrawerProvider drawerProvider = Provider.of<DrawerProvider>(context);

    return AnimatedOpacity(
      opacity: drawerProvider.isOpen ? 1 : 0,
      duration: widget.duration,
      curve: Curves.easeOutQuart,
      child: AnimatedContainer(
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
      ),
    );
  }

  Widget drawerContent() {
    // Warning: Nested Function
    Widget drawerSettingTop() {
      Color? buttonColor = IconTheme.of(context).color;

      return Container(
        height: 56,
        width: double.maxFinite,
        padding: EdgeInsets.only(right: 10),
        alignment: Alignment.centerRight,
        child: IconButton(
          icon: Icon(Icons.settings),
          color: buttonColor,
          onPressed: () {
            // TODO: Open setting screen
            context.read<DrawerProvider>().setDrawerState(false);
            context.goNamed(RouterEnum.settings.name);
          },
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    // Warning: Nested Function
    Widget drawerHeader() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: EdgeInsets.only(top: 12, bottom: 12, right: 16),
                child: drawerCustomListTile(
                  isSelected: false,
                  constraints: constraints,
                  title: "New Chat",
                  icon: Icons.add_card_rounded,
                  onPressed: () {
                    // TODO: Create New Chat
                    context.read<RequestBloc>().add(ClearRequestEvent());
                    context.read<ResponseBloc>().add(ClearResponseEvent());
                    context.read<DrawerProvider>().toggleDrawer();
                  },
                  useDeleteAction: false,
                ),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "History",
                    style: GoogleFonts.nunito().copyWith(fontSize: 12),
                  ),
                ),
                BlocBuilder<ChatsBloc, ChatsState>(
                  builder: (chatsContext, chatsState) {
                    return Visibility(
                      visible: chatsState.selectedChats.isNotEmpty,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          chatsContext.read<ChatsBloc>().add(
                            SelectAllChatEvent(),
                          );
                        },
                        child: Text(
                          "Select all (${chatsState.chats.length})",
                          style: GoogleFonts.nunito().copyWith(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Warning: Nested Function
    Widget drawerHistory(List<Chat> chatsHistory) {
      return BlocBuilder<ChatsBloc, ChatsState>(
        builder: (chatsContext, chatsState) {
          List<Chat> selectedChats = chatsState.selectedChats;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Expanded(
                    child: Scrollbar(
                      controller: scrollController,
                      thumbVisibility: true,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return ListView.builder(
                            controller: scrollController,
                            padding: EdgeInsets.only(right: 16),
                            itemCount: chatsHistory.length,
                            itemBuilder: (_, index) {
                              bool isSelected = chatsState.selectedChats
                                  .contains(chatsHistory[index]);

                              return drawerCustomListTile(
                                isSelected: isSelected,
                                constraints: constraints,
                                chat: chatsHistory[index],
                                onPressed: () {
                                  // TODO: Open Chat
                                  Chat chat = chatsHistory[index];
                                  context.read<RequestBloc>().add(
                                    AddRequestEvent(request: chat.request),
                                  );
                                  context.read<ResponseBloc>().add(
                                    AddResponseSuccessEvent(
                                      response: chat.response,
                                    ),
                                  );
                                },
                                useDeleteAction: true,
                                deleteActionOnPressed: () {
                                  if (isSelected) {
                                    context.read<ChatsBloc>().add(
                                      UnselectChatEvent(
                                        chat: chatsHistory[index],
                                      ),
                                    );
                                  } else {
                                    context.read<ChatsBloc>().add(
                                      SelectChatEvent(
                                        chat: chatsHistory[index],
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  Visibility(
                    visible: selectedChats.isNotEmpty,
                    child: Container(
                      padding: EdgeInsets.only(right: 12),
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: () {
                              chatsContext.read<ChatsBloc>().add(
                                ClearSelectedChatsEvent(),
                              );
                            },
                            child: Text(
                              "Cancel selection",
                              style: GoogleFonts.nunito().copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              overlayColor: StyleUtil.windowCloseRed,
                            ),
                            onPressed: () {
                              chatsContext.read<ChatsBloc>().add(
                                RemoveMultipleChatEvent(chats: selectedChats),
                              );
                            },
                            child: Text(
                              "Delete (${selectedChats.length})",
                              style: GoogleFonts.nunito().copyWith(
                                fontSize: 12,
                                color: StyleUtil.windowCloseRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    Widget drawerHistoryBloc() {
      return BlocBuilder<ChatsBloc, ChatsState>(
        builder: (chatsContext, chatsState) {
          if (chatsState is ChatsLoading) {
            return CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).iconTheme.color,
            );
          } else if (chatsState is ChatsInitial) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                "No history has been made...",
                style: GoogleFonts.nunito().copyWith(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          } else if (chatsState is ChatsLoaded && chatsState.chats.isNotEmpty) {
            return drawerHistory(chatsState.chats);
          } else {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                "Wow you found this! \nSorry, but... \nSomething is wrong with your history :)",
                style: GoogleFonts.nunito().copyWith(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }
        },
      );
    }

    return Padding(
      // padding: const EdgeInsets.only(top: 56, left: 8, right: 8),
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [drawerSettingTop(), drawerHeader(), drawerHistoryBloc()],
      ),
    );
  }

  Widget drawerCustomListTile({
    String? title,
    Chat? chat,
    required bool isSelected,
    IconData? icon,
    required Function() onPressed,
    required bool useDeleteAction,
    Function()? deleteActionOnPressed,
    required BoxConstraints constraints,
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
    }

    // Warning: Nested Function
    Widget customDeleteButton(bool isSelected, [Function()? onTap]) {
      Color? splashColor, hoverColor, iconColor;
      IconData? icon;

      if (isSelected) {
        Color color = Theme.of(context).colorScheme.secondary;
        splashColor = color.withAlpha(80);
        hoverColor = color.withAlpha(40);
        iconColor = color;
        icon = Icons.close;
      } else {
        Color color = StyleUtil.windowCloseRed;
        splashColor = color.withAlpha(80);
        hoverColor = color.withAlpha(40);
        iconColor = color;
        icon = Icons.delete_rounded;
      }

      return InkWell(
        onTap: onTap,
        splashColor: splashColor,
        hoverColor: hoverColor,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: 42,
          width: 42,
          child: Center(child: Icon(icon, color: iconColor)),
        ),
      );
    }

    Widget iconListTile(Icon icon) {
      return Padding(
        padding: EdgeInsets.only(top: 12, bottom: 12, left: 16),
        child: icon,
      );
    }

    return StatefulBuilder(
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
              (icon != null)
                  ? iconListTile(Icon(icon, size: 16, color: buttonColor))
                  : (isSelected)
                  ? iconListTile(
                    Icon(Icons.check, color: StyleUtil.windowCloseRed),
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
                    left: icon == null && !isSelected ? 16 : 0,
                  ),
                  child: fadeText(
                    text: chat != null ? chat.request.prompt : title!,
                    fadeFraction: 0.2,
                    style: GoogleFonts.nunito().copyWith(
                      color: themeData.colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ),
                Visibility(
                  visible: isHovered,
                  child: customDeleteButton(
                    isSelected,
                    useDeleteAction ? deleteActionOnPressed : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
