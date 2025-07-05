import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scanthesis_app/provider/theme_provider.dart';
import 'package:scanthesis_app/screens/home/widgets/floating_input.dart';
import 'package:scanthesis_app/widgets/custom_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              if (Platform.isWindows)
                const CustomAppBar()
              else
                const SizedBox.shrink(),
              AppBar(
                scrolledUnderElevation: 0,
                actions: [
                  _toggleThemeIcon(context: context),
                  const SizedBox(width: 16),
                ],
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              HomeContent(),
              HomeFooterSpacer(),
            ],
          ),
          FloatingInput(),
        ],
      ),
    );
  }

  Widget _toggleThemeIcon({required BuildContext context}) {
    Color? buttonColor = IconTheme.of(context).color;
    ThemeProvider theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDarkMode(context);

    return IconButton(
      icon: Icon(isDark ? Icons.sunny : Icons.nights_stay, color: buttonColor),
      onPressed: () {
        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
      },
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 28, top: 16),
          child: Center(
            child: Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 0.3,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                constraints: BoxConstraints(maxWidth: 680),
                child: Column(
                  children: [_codeCardHeader(), _codeCardContent()],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _codeCardHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      width: double.maxFinite,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text("dart"),
          ),
          Tooltip(message: "Copy Code", child: IconButton(onPressed: () {}, icon: Icon(Icons.copy, size: 16))),
        ],
      ),
    );
  }

  Widget _codeCardContent() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      // height: 900,
      width: double.maxFinite,
      color: Theme.of(context).colorScheme.onSecondary,
      child: Text(
        "Hello World!",
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}

class HomeFooterSpacer extends StatelessWidget {
  const HomeFooterSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 100, width: double.maxFinite);
  }
}


