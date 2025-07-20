class ApiResponse {
  String? _response;
  bool _isFromHistory;

  bool get isCreated => _response != null;
  bool get isFromHistory => _isFromHistory;

  String get text {
    if (isCreated) {
      return _response!;
    }
    throw Exception("Response is not yet created");
  }

  void setValue(String text){
    _response = text;
  }

  void setFromHistory(bool isFromHistory){
    _isFromHistory = isFromHistory;
  }

  ApiResponse([this._response, this._isFromHistory = false]);

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(json["response"]);
  }
}
