import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:scanthesis_app/screens/home/provider/custom_prompt_provider.dart';

part 'file_picker_event.dart';

part 'file_picker_state.dart';

class FilePickerBloc extends Bloc<FilePickerEvent, FilePickerState> {
  final CustomPromptProvider customPromptProvider;

  FilePickerBloc({required this.customPromptProvider})
    : super(FilePickerInitial()) {
    on<AddMultipleFileEvent>(_addMultipleFile);
    on<AddSingleFileEvent>(_addSingleFile);
    on<RemoveFileEvent>(_removeFile);
    on<ResetFilePickerErrorEvent>(_resetFiles);
    on<ClearFilesEvent>(_clearFiles);
  }

  _addMultipleFile(AddMultipleFileEvent event, Emitter<FilePickerState> emit) {
    if (state.files.length + event.files.length > 7){
      emit(FilePickerError(errorMessage: "You can only attach up to 7 images", files: state.files));
    } else {
      state.files.addAll(event.files);
      emit(FilePickerLoaded(files: state.files));
    }
  }

  _addSingleFile(AddSingleFileEvent event, Emitter<FilePickerState> emit) {
    state.files.add(event.file);
    emit(FilePickerLoaded(files: state.files));
  }

  _removeFile(RemoveFileEvent event, Emitter<FilePickerState> emit) {
    state.files.remove(event.file);
    if (state.files.isEmpty) {
      customPromptProvider.resetUsingCustomPrompt();
    }
    emit(FilePickerLoaded(files: state.files));
  }

  _resetFiles(ResetFilePickerErrorEvent event, Emitter<FilePickerState> emit){
    emit(FilePickerLoaded(files: state.files));
  }

  _clearFiles(ClearFilesEvent event, Emitter<FilePickerState> emit) {
    state.files.clear();
    customPromptProvider.resetUsingCustomPrompt();
    emit(FilePickerLoaded(files: state.files));
  }
}
