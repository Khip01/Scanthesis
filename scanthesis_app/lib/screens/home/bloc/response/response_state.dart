part of 'response_bloc.dart';

@immutable
sealed class ResponseState {}

final class ResponseInitial extends ResponseState {}

final class ResponseLoading extends ResponseState {}

final class ResponseSuccess extends ResponseState {}

final class ResponseError extends ResponseState {}
