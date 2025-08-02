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

  Map<String, dynamic> toJson() => {
    "files": files.map((file) => file.path).toList(),
    "prompt": prompt,
  };

  factory ApiRequest.fromJson(Map<String, dynamic> json) => ApiRequest(
    files: (json["files"] as List).map((filePath) => File(filePath)).toList(),
    prompt: json["prompt"],
  );
}
