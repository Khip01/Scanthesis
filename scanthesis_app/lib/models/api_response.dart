class ApiResponse {
  final String body;
  final Map<String, dynamic>? json;
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

  factory ApiResponse.fromJson(Map<String, dynamic> json, {int? statusCode}) {
    return ApiResponse.success(
      body: json.toString(),
      json: json,
      statusCode: statusCode,
    );
  }

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
