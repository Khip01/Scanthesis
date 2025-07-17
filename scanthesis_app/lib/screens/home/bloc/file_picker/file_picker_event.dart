part of 'file_picker_bloc.dart';

@immutable
sealed class FilePickerEvent {}

class AddMultipleFileEvent extends FilePickerEvent {
  final List<File> files;

  AddMultipleFileEvent({required this.files});
}

class AddSingleFileEvent extends FilePickerEvent {
  final File file;

  AddSingleFileEvent({required this.file});
}

class RemoveFileEvent extends FilePickerEvent {
  final File file;

  RemoveFileEvent({required this.file});
}

class ClearFilesEvent extends FilePickerEvent {}

class ResetFilePickerErrorEvent extends FilePickerEvent {}