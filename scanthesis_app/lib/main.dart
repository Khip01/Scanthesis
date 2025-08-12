import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:scanthesis_app/provider/drawer_provider.dart';
import 'package:scanthesis_app/provider/theme_provider.dart';
import 'package:scanthesis_app/screens/home/bloc/chats/chats_bloc.dart';
import 'package:scanthesis_app/screens/home/bloc/file_picker/file_picker_bloc.dart';
import 'package:scanthesis_app/screens/home/bloc/request/request_bloc.dart';
import 'package:scanthesis_app/screens/home/bloc/response/response_bloc.dart';
import 'package:scanthesis_app/screens/home/provider/clipboard_provider.dart';
import 'package:scanthesis_app/screens/home/provider/custom_prompt_provider.dart';
import 'package:scanthesis_app/screens/home/provider/open_file_provider.dart';
import 'package:scanthesis_app/screens/home/provider/preview_image_provider.dart';
import 'package:scanthesis_app/screens/home/provider/screen_capture_provider.dart';
import 'package:scanthesis_app/screens/router.dart';
import 'package:scanthesis_app/screens/settings/provider/settings_provider.dart';
import 'package:scanthesis_app/utils/init_value_util.dart';
import 'package:scanthesis_app/utils/storage_service.dart';
import 'package:scanthesis_app/utils/theme_util.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  final SettingsProvider settingsProvider =
      await InitValueUtil.initSettingsProvider();
  final ThemeProvider themeProvider = ThemeProvider();
  final ChatsBloc chatsBloc = ChatsBloc(settingsProvider: settingsProvider);

  final StorageService storageService = await StorageService.init();
  storageService.loadSettingsState(
    chatsBloc: chatsBloc,
    settingsProvider: settingsProvider,
    themeProvider: themeProvider,
  );

  runApp(
    // ChangeNotifierProvider(
    //   create: (_) => ThemeProvider(),
    //   child: MyApp(),
    // ),
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => ClipboardImageProvider()),
        ChangeNotifierProvider(create: (_) => ScreenCaptureProvider()),
        ChangeNotifierProvider(create: (_) => OpenFileProvider()),
        ChangeNotifierProvider(create: (_) => PreviewImageProvider()),
        ChangeNotifierProvider(create: (_) => CustomPromptProvider()),
        ChangeNotifierProvider(create: (_) => DrawerProvider()),
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: MyApp(initedChatsBloc: chatsBloc),
    ),
  );

  // For Windows: set window when app opened
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(800, 600);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "Scanthesis App";
    win.show();
  });
}

class MyApp extends StatelessWidget {
  final ChatsBloc initedChatsBloc;

  const MyApp({super.key, required this.initedChatsBloc});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final CustomPromptProvider customPromptProvider =
                Provider.of<CustomPromptProvider>(context, listen: false);
            return FilePickerBloc(customPromptProvider: customPromptProvider);
          },
        ),
        BlocProvider(
          create: (context) {
            final SettingsProvider settingsProvider =
                Provider.of<SettingsProvider>(context, listen: false);
            return ResponseBloc(settingsProvider: settingsProvider);
          },
        ),
        BlocProvider(create: (_) => RequestBloc()),
        BlocProvider(
          create: (context) {
            final SettingsProvider settingsProvider =
                Provider.of<SettingsProvider>(context, listen: false);
            return initedChatsBloc;
          },
        ),
      ],
      child: MaterialApp.router(
        theme: ThemeUtil.globalLightTheme,
        darkTheme: ThemeUtil.globalDarkTheme,
        themeMode: themeProvider.getThemeMode,
        title: "Scanthesis App",
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
