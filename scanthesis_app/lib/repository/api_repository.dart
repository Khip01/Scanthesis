import 'package:dio/dio.dart';
import 'package:scanthesis_app/models/api_request.dart';
import 'package:scanthesis_app/models/api_response.dart';
import 'package:scanthesis_app/values/strings.dart';

class ApiRepository {
  late Dio dio;

  ApiRepository() {
    dio = Dio();
    dio.options.baseUrl = Strings.baseUrl;
  }

  Future<ApiResponse> sendRequest(ApiRequest request) async {
    try {
      final formData = FormData.fromMap({
        "images": [
          for (final file in request.files)
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
        ],
        "prompt": request.prompt,
      });

      final Response response = await dio.post("/ocr", data: formData);
      final ApiResponse apiResponse = ApiResponse.fromJson(response.data);

      return apiResponse;
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          throw 'Connection timeout';
        case DioExceptionType.sendTimeout:
          throw 'Send timeout';
        case DioExceptionType.receiveTimeout:
          throw 'Receive timeout';
        case DioExceptionType.badCertificate:
          throw 'Bad certificate';
        case DioExceptionType.badResponse:
          throw e.response?.data["message"] ?? 'Bad response';
        case DioExceptionType.cancel:
          throw 'Request cancelled';
        case DioExceptionType.connectionError:
          throw 'Connection error';
        case DioExceptionType.unknown:
          throw 'Unknown';
      }
    }
  }
}
