part of 'file_picker_bloc.dart';

@immutable
sealed class FilePickerState {
  final List<File> files;

  const FilePickerState({required this.files});
}

final class FilePickerInitial extends FilePickerState {
  FilePickerInitial() : super(files: []);
}

final class FilePickerLoading extends FilePickerState {
  FilePickerLoading() : super(files: []);
}

final class FilePickerLoaded extends FilePickerState {
  const FilePickerLoaded({required super.files});
}

final class FilePickerError extends FilePickerState {
  final String errorMessage;

  const FilePickerError({required this.errorMessage, required super.files});
}