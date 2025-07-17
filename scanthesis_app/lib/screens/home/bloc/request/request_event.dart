part of 'request_bloc.dart';

@immutable
sealed class RequestEvent {}

class AddRequestEvent extends RequestEvent {
  final ApiRequest request;

  AddRequestEvent({required this.request});
}

class ClearRequestEvent extends RequestEvent {
  ClearRequestEvent();
}