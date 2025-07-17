part of 'request_bloc.dart';

@immutable
sealed class RequestState {
  final ApiRequest? request;

  const RequestState({required this.request});
}

final class RequestInitial extends RequestState {
  const RequestInitial() : super(request: null);
}

final class RequestSuccess extends RequestState {
  const RequestSuccess({required super.request});
}