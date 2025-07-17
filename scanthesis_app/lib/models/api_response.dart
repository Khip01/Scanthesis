class ApiResponse {
  String? _response;

  bool get isCreated => _response != null;

  String get text {
    if (isCreated) {
      return _response!;
    }
    throw Exception("Response is not yet created");
  }

  void setValue(String text){
    _response = text;
  }

  ApiResponse([this._response]);

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(json["response"]);
  }
}
