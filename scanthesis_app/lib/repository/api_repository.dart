import 'package:dio/dio.dart';
import 'package:scanthesis_app/models/api_request.dart';
import 'package:scanthesis_app/models/api_response.dart';

class ApiRepository {
  late Dio dio;

  ApiRepository({required String baseUrl}) {
    dio = Dio();
    dio.options.baseUrl = baseUrl;
  }

  Future<ApiResponse<T>> sendRequest<T>(
    ApiRequest request, {
    required T Function(Map<String, dynamic> json) jsonParser,
    required T Function(String plainText) textParser,
  }) async {
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
      final data = response.data;
      final statusCode = response.statusCode;

      if (data is Map<String, dynamic>) {
        return ApiResponse<T>.fromJson(
          data,
          parser: jsonParser,
          statusCode: statusCode,
        );
      } else if (data is String) {
        return ApiResponse<T>.fromPlainText(
          data,
          parser: textParser,
          statusCode: statusCode,
        );
      } else {
        return ApiResponse<T>.fromPlainText(
          data.toString(),
          parser: textParser,
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;

      late final String errorMessage;

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = 'Connection timeout';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = 'Send timeout';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Receive timeout';
          break;
        case DioExceptionType.badCertificate:
          errorMessage = 'Bad certificate';
          break;
        case DioExceptionType.badResponse:
          final data = e.response?.data;
          if (data is Map<String, dynamic>) {
            errorMessage = data["message"] ?? 'Bad response';
          } else if (data is String) {
            errorMessage = data;
          } else {
            errorMessage = 'Bad response';
          }
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'Connection error';
          break;
        case DioExceptionType.unknown:
          errorMessage = 'Unknown error';
          break;
      }

      return ApiResponse<T>.failure(
        errorMessage: errorMessage,
        statusCode: statusCode,
      );
    }
  }

  Future<ApiResponse<T>> checkConnection<T>(
    String urlPath, {
    required T Function(Map<String, dynamic> json) jsonParser,
    required T Function(String plainText) textParser,
  }) async {
    try {
      final Response response = await dio.get(urlPath);

      final data = response.data;
      final statusCode = response.statusCode;

      if (data is Map<String, dynamic>) {
        return ApiResponse<T>.fromJson(
          data,
          parser: jsonParser,
          statusCode: statusCode,
        );
      } else if (data is String) {
        return ApiResponse<T>.fromPlainText(
          data,
          parser: textParser,
          statusCode: statusCode,
        );
      } else {
        return ApiResponse<T>.fromPlainText(
          data.toString(),
          parser: textParser,
          statusCode: statusCode,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;

      late final String errorMessage;

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = 'Connection timeout';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = 'Send timeout';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Receive timeout';
          break;
        case DioExceptionType.badCertificate:
          errorMessage = 'Bad certificate';
          break;
        case DioExceptionType.badResponse:
          final data = e.response?.data;
          if (data is Map<String, dynamic>) {
            errorMessage = data["message"] ?? 'Bad response';
          } else if (data is String) {
            errorMessage = data;
          } else {
            errorMessage = 'Bad response';
          }
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'Connection error';
          break;
        case DioExceptionType.unknown:
          errorMessage = 'Unknown error';
          break;
      }

      return ApiResponse<T>.failure(
        errorMessage: errorMessage,
        statusCode: statusCode,
      );
    }
  }
}
