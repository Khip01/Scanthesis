import 'package:scanthesis_app/models/api_request.dart';
import 'package:scanthesis_app/models/api_response.dart';

class Chat {
  final ApiRequest request;
  final ApiResponse response;

  Chat({required this.request, required this.response});

  Chat copyWith({ApiRequest? request, ApiResponse? response}) {
    return Chat(
      request: request ?? this.request,
      response: response ?? this.response,
    );
  }

  Map<String, dynamic> toJson () => {
    "request": request.toJson(),
    "response": response.toJson(),
  };

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
    request: ApiRequest.fromJson(json["request"]),
    response: ApiResponse.fromJson(json["response"]),
  );
}
