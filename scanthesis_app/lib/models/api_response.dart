/*
  Different between body and json. For Example,
  ------------------------
  This is "body"/plaintext response:
  ```
  You good to go!
  ```

  ------------------------
  This is "json" response:
  ```
  {
    "response": "This is key value response!"
  }
  ```

  So, it's will automatically detect the response type, with the default value being “body”,
  json exists if you call the correct key value (i.e "response" key)
 */


class ApiResponse {
  final String body;                  // body is the plaintext version from response without map
  final Map<String, dynamic>? json;   // json is the Map version from response
  final int? statusCode;
  final bool isFromHistory;
  final String? errorMessage;

  bool get isError => errorMessage != null;
  String? get parsedText => json?["response"];
  String get text {
    if (parsedText != null) return parsedText!;
    if (body.isNotEmpty) return body;
    if (errorMessage != null) return errorMessage!;
    return '';
  }
  bool get isCreated => body.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {"response": text};
  }

  factory ApiResponse.fromJson(Map<String, dynamic> json, {int? statusCode}) {
    return ApiResponse.success(
      body: json.toString(),
      json: json,
      statusCode: statusCode,
    );
  }

  ApiResponse.success({
    required this.body,
    this.json,
    this.statusCode,
    this.isFromHistory = false,
  }) : errorMessage = null;

  ApiResponse.failure({
    required this.errorMessage,
    this.statusCode,
    this.body = '',
    this.json,
    this.isFromHistory = false,
  });

  factory ApiResponse.fromPlainText(String text, {int? statusCode}) {
    return ApiResponse.success(
      body: text,
      statusCode: statusCode,
    );
  }

  ApiResponse copyWith({
    String? body,
    Map<String, dynamic>? json,
    int? statusCode,
    bool? isFromHistory,
    String? errorMessage,
  }) {
    if (isError) {
      return ApiResponse.failure(
        errorMessage: errorMessage ?? this.errorMessage!,
        body: body ?? this.body,
        json: json ?? this.json,
        statusCode: statusCode ?? this.statusCode,
        isFromHistory: isFromHistory ?? this.isFromHistory,
      );
    }
    return ApiResponse.success(
      body: body ?? this.body,
      json: json ?? this.json,
      statusCode: statusCode ?? this.statusCode,
      isFromHistory: isFromHistory ?? this.isFromHistory,
    );
  }

}
