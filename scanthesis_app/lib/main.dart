import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:scanthesis/provider/drawer_provider.dart';
import 'package:scanthesis/provider/theme_provider.dart';
import 'package:scanthesis/screens/home/bloc/chats/chats_bloc.dart';
import 'package:scanthesis/screens/home/bloc/file_picker/file_picker_bloc.dart';
import 'package:scanthesis/screens/home/bloc/request/request_bloc.dart';
import 'package:scanthesis/screens/home/bloc/response/response_bloc.dart';
import 'package:scanthesis/screens/home/provider/clipboard_provider.dart';
import 'package:scanthesis/screens/home/provider/custom_prompt_provider.dart';
import 'package:scanthesis/screens/home/provider/open_file_provider.dart';
import 'package:scanthesis/screens/home/provider/preview_image_provider.dart';
import 'package:scanthesis/screens/home/provider/screen_capture_provider.dart';
import 'package:scanthesis/screens/router.dart';
import 'package:scanthesis/screens/settings/provider/settings_provider.dart';
import 'package:scanthesis/utils/init_util.dart';
import 'package:scanthesis/utils/storage_service.dart';
import 'package:scanthesis/utils/theme_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await InitUtil.initAppManager();

  final SettingsProvider settingsProvider =
      await InitUtil.initSettingsProvider();
  final ThemeProvider themeProvider = ThemeProvider();
  final ChatsBloc chatsBloc = ChatsBloc(settingsProvider: settingsProvider);

  final StorageService storageService = await StorageService.init();
  storageService.loadSettingsState(
    chatsBloc: chatsBloc,
    settingsProvider: settingsProvider,
    themeProvider: themeProvider,
  );

  runApp(
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
}

class MyApp extends StatelessWidget {
  final ChatsBloc initedChatsBloc;

  MyApp({super.key, required this.initedChatsBloc});

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
        BlocProvider(create: (context) => initedChatsBloc),
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
