import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'file_picker_event.dart';
part 'file_picker_state.dart';

class FilePickerBloc extends Bloc<FilePickerEvent, FilePickerState> {
  FilePickerBloc() : super(FilePickerInitial()) {
    on<AddFileEvent>(_addFile);
    on<RemoveFileEvent>(_removeFile);
  }

  _addFile(AddFileEvent event, Emitter<FilePickerState> emit) {
    state.files.addAll(event.files);
    emit(FilePickerLoaded(files: state.files));
  }

  _removeFile(RemoveFileEvent event, Emitter<FilePickerState> emit){
    state.files.remove(event.file);
    emit(FilePickerLoaded(files: state.files));
  }
}
