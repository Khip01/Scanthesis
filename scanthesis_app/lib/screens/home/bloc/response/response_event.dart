part of 'response_bloc.dart';

@immutable
sealed class ResponseEvent {}

class AddResponseEvent extends ResponseEvent {
  final ApiRequest request;

  AddResponseEvent({required this.request});
}

class ClearResponseEvent extends ResponseEvent {
  ClearResponseEvent();
}

class AddResponseSuccessEvent extends ResponseEvent {
  final ApiResponse response;

  AddResponseSuccessEvent({required this.response});
}