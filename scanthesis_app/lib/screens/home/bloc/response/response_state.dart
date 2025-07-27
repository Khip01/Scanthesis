part of 'response_bloc.dart';

@immutable
sealed class ResponseState {
  final ApiResponse response;

  const ResponseState({required this.response});
}

final class ResponseInitial extends ResponseState {
  ResponseInitial() : super(response: ApiResponse.success(body: ""));
}

final class ResponseLoading extends ResponseState {
  ResponseLoading() : super(response: ApiResponse.success(body: ""));
}

final class ResponseSuccess extends ResponseState {
  const ResponseSuccess({required super.response});
}

final class ResponseError extends ResponseState {
  final String errorMessage;

  const ResponseError({required this.errorMessage, required super.response});
}
