import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:scanthesis_app/screens/home/bloc/file_picker/file_picker_bloc.dart';
import 'package:scanthesis_app/screens/home/provider/custom_prompt_provider.dart';
import 'package:scanthesis_app/utils/style_util.dart';
import 'package:scanthesis_app/values/strings.dart';

class CustomPromptField extends StatefulWidget {
  final FocusNode sendButtonFocusNode;
  final TextEditingController promptController;

  const CustomPromptField({
    super.key,
    required this.sendButtonFocusNode,
    required this.promptController,
  });

  @override
  State<CustomPromptField> createState() => _CustomPromptFieldState();
}

class _CustomPromptFieldState extends State<CustomPromptField> {
  late ColorScheme themeColorScheme;
  late CustomPromptProvider customPromptProvider;

  late final String defaultPlaceholder =
      "Default prompt: ${Strings.defaultPrompt}";

  @override
  Widget build(BuildContext context) {
    themeColorScheme = Theme.of(context).colorScheme;
    customPromptProvider = Provider.of<CustomPromptProvider>(context);

    return ListenableBuilder(
      listenable: customPromptProvider,
      builder: (context, child) {
        if (customPromptProvider.isUsingCustomPrompt &&
            widget.promptController.text == defaultPlaceholder) {
          widget.promptController.text = Strings.defaultPrompt;
        } else if (!customPromptProvider.isUsingCustomPrompt) {
          widget.promptController.text = defaultPlaceholder;
        }
        return child!;
      },
      child: BlocBuilder<FilePickerBloc, FilePickerState>(
        builder: (filePickerContext, filePickerState) {
          return Visibility(
            visible: filePickerState.files.isNotEmpty,
            child: Container(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Prompt", style: TextStyle(fontSize: 12)),
                  SizedBox(height: 12),
                  _promptField(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [_customPromptButtonToggle()],
                        ),
                      ),
                      SizedBox(
                        width: 400,
                        child: Text(
                          "*you can include your own custom prompts to help us analyze the images you have provided.",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _promptField() {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          widget.sendButtonFocusNode.requestFocus();
        } else {
          widget.sendButtonFocusNode.unfocus();
        }
      },
      child: TextField(
        controller: widget.promptController,
        style: TextStyle(fontSize: 14),
        enabled: customPromptProvider.isUsingCustomPrompt,
        decoration: InputDecoration(
          fillColor: themeColorScheme.surface,
          hintText: defaultPlaceholder,
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: themeColorScheme.primary, width: 0.8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: themeColorScheme.primary, width: 0.8),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey, width: 0.4),
          ),
        ),
        keyboardType: TextInputType.multiline,
        minLines: 1,
        maxLines: 4,
      ),
    );
  }

  Widget _customPromptButtonToggle() {
    String buttonText =
        customPromptProvider.isUsingCustomPrompt
            ? "Cancel using custom prompts"
            : "Create your custom prompt";
    Color buttonThemeColor =
        customPromptProvider.isUsingCustomPrompt
            ? StyleUtil.windowCloseRed
            : themeColorScheme.primary;

    IconData buttonIcon =
        customPromptProvider.isUsingCustomPrompt ? Icons.close : Icons.add;

    return OutlinedButton(
      onPressed: () {
        customPromptProvider.toggleUsingCustomPrompt();
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: buttonThemeColor, width: 0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        overlayColor: buttonThemeColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 4),
          Text(
            buttonText,
            style: TextStyle(fontSize: 12, color: buttonThemeColor),
          ),
          SizedBox(width: 4, height: 36),
          Icon(buttonIcon, size: 16, color: buttonThemeColor),
        ],
      ),
    );
  }
}
