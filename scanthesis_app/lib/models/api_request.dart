import 'dart:io';

class ApiRequest {
  final List<File> files;
  final String prompt;

  ApiRequest({required this.files, required this.prompt});
}