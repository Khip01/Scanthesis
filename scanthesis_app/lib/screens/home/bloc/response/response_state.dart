part of 'response_bloc.dart';

@immutable
sealed class ResponseState {
  final ApiResponse<MyCustomResponse> response;

  const ResponseState({required this.response});
}

final class ResponseInitial extends ResponseState {
  ResponseInitial() : super(response: ApiResponse<MyCustomResponse>.empty());
}

final class ResponseLoading extends ResponseState {
  ResponseLoading() : super(response: ApiResponse<MyCustomResponse>.empty());
}

final class ResponseSuccess extends ResponseState {
  const ResponseSuccess({required super.response});
}

final class ResponseError extends ResponseState {
  final String errorMessage;

  const ResponseError({required this.errorMessage, required super.response});
}
