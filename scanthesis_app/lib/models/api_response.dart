/*
  CHANGE YOUR CUSTOM RESPONSE HERE, based on your JSON response structure.
  For example, in this case, the response could be:
  ```json
  {
    "response": "Some AI response text"
  }
  ```

  If you want, you can use your own API to retrieve responses from AI
  by changing the Response structure below:
*/

class MyCustomResponse {
  final String response;
  // ..or you can add more attribute depends on your response structure

  MyCustomResponse({required this.response});

  factory MyCustomResponse.fromJson(Map<String, dynamic> json) {
    return MyCustomResponse(response: json['response']);
  }

  Map<String, dynamic> toJson() => {"response": response};

  @override
  String toString() => response;
}

/*
  However, the response above is only for the AI response (which we took from the API).

  An example of the complete structure of a full one chat (request and response)
  in this case is as follows:
  ```
    {
      "request" : {
        "files" : [ "/path/to/Documents/Scanthesis App - Image Chat History/scanthesis_captured_image.png" ],
        "prompt" : "Perform OCR on each of the separate images... some prompt..."
      },
      "response" : {
        "response" : "
         dart\nclass MyCustomResponse {\nfinal String response;\n//..... some ai response...
        "
      }
    }
  ```

  Where the API is only in the response section, without including the request.
*/


/// --- TO CHANGE THE CUSTOM API RESPONSE, JUST CHANGE THE CLASS ABOVE, NOT THE CLASS CODE BELOW ---
class ApiResponse<T> {
  final String rawBody;
  final int? statusCode;
  final bool isFromHistory;
  final String? errorMessage;
  final T? data; // Your custom response

  bool get isError => errorMessage != null;

  String get text {
    if (data != null) return data.toString();
    if (rawBody.isNotEmpty) return rawBody;
    if (errorMessage != null) return errorMessage!;
    return '';
  }

  ApiResponse.success({
    required this.rawBody,
    required this.data,
    this.statusCode,
    this.isFromHistory = false,
  }) : errorMessage = null;

  ApiResponse.failure({
    required this.errorMessage,
    this.statusCode,
    this.rawBody = '',
    this.data,
    this.isFromHistory = false,
  });

  factory ApiResponse.empty() {
    return ApiResponse.failure(
      errorMessage: "",
      rawBody: "",
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    required T Function(Map<String, dynamic> json) parser,
    int? statusCode,
  }) {
    return ApiResponse.success(
      rawBody: json.toString(),
      data: parser(json),
      statusCode: statusCode,
    );
  }

  factory ApiResponse.fromPlainText(
    String text, {
    required T Function(String jsonStr) parser,
    int? statusCode,
  }) {
    return ApiResponse.success(
      rawBody: text,
      data: parser(text),
      statusCode: statusCode,
    );
  }

//   Map<String, dynamic> toWrappedJson({
//     required Map<String, dynamic> Function(T data) parser,
// }){
//     return {
//       "data": data != null ? parser(data as T) : "",
//       "statusCode": statusCode,
//       "rawBody": rawBody,
//       "isFromHistory": isFromHistory,
//       "errorMessage": errorMessage,
//     };
//   }

  Map<String, dynamic> toRawDataJson({
    required Map<String, dynamic> Function(T data) parser,
  }) {
    if (data == null) return {};
    return parser(data as T);
  }

  ApiResponse<T> copyWith({
    String? rawBody,
    T? data,
    int? statusCode,
    bool? isFromHistory,
    String? errorMessage,
  }) {
    if (this.errorMessage != null) {
      return ApiResponse.failure(
        errorMessage: errorMessage ?? this.errorMessage,
        rawBody: rawBody ?? this.rawBody,
        data: data ?? this.data,
        statusCode: statusCode ?? this.statusCode,
        isFromHistory: isFromHistory ?? this.isFromHistory,
      );
    }
    return ApiResponse.success(
      rawBody: rawBody ?? this.rawBody,
      data: data ?? this.data,
      statusCode: statusCode ?? this.statusCode,
      isFromHistory: isFromHistory ?? this.isFromHistory,
    );
  }
}
