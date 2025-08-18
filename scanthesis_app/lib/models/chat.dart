import 'package:scanthesis/models/api_request.dart';
import 'package:scanthesis/models/api_response.dart';

class Chat<T> {
  final ApiRequest request;
  final ApiResponse<T> response;

  Chat({required this.request, required this.response});

  Chat<T> copyWith({ApiRequest? request, ApiResponse<T>? response}) {
    return Chat<T>(
      request: request ?? this.request,
      response: response ?? this.response,
    );
  }

  Map<String, dynamic> toJson({
    required Map<String, dynamic> Function(T data) parser,
  }) => {
    "request": request.toJson(),
    "response": response.toRawDataJson(parser: parser),
  };

  factory Chat.fromJson(
    Map<String, dynamic> json, {
    required T Function(Map<String, dynamic> json) parser,
  }) => Chat<T>(
    request: ApiRequest.fromJson(json["request"]),
    response: ApiResponse<T>.fromJson(json["response"], parser: parser),
  );
}
