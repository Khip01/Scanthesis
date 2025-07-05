part of 'file_picker_bloc.dart';

@immutable
sealed class FilePickerEvent {}

class AddFileEvent extends FilePickerEvent {
  final List<File> files;

  AddFileEvent({required this.files});
}

class UpdateFileEvent extends FilePickerEvent {
  final File file;

  UpdateFileEvent({required this.file});
}

class RemoveFileEvent extends FilePickerEvent {
  final File file;

  RemoveFileEvent({required this.file});
}