import 'dart:io';

class ApiRequest {
  final List<File> files;
  final String prompt;

  ApiRequest({required this.files, required this.prompt});

  ApiRequest copyWith({List<File>? files, String? prompt}) {
    return ApiRequest(
      files: files ?? this.files,
      prompt: prompt ?? this.prompt,
    );
  }
}