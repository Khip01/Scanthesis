import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:scanthesis_app/provider/theme_provider.dart';
import 'package:scanthesis_app/screens/home/bloc/file_picker/file_picker_bloc.dart';
import 'package:scanthesis_app/screens/home_screen.dart';
import 'package:scanthesis_app/utils/theme_util.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => FilePickerBloc()),
      ],
      child: MaterialApp(
        theme: ThemeUtil.globalLightTheme,
        darkTheme: ThemeUtil.globalDarkTheme,
        themeMode: themeProvider.getThemeMode,
        title: "Scanthesis App",
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
