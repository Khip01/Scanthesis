part of 'chats_bloc.dart';

@immutable
sealed class ChatsState {
  final List<Chat<MyCustomResponse>> chats;
  final List<Chat<MyCustomResponse>> selectedChats;

  const ChatsState({required this.chats, required this.selectedChats});
}

final class ChatsInitial extends ChatsState {
  ChatsInitial() : super(chats: [], selectedChats: []);
}

final class ChatsLoading extends ChatsState {
  ChatsLoading() : super(chats: [], selectedChats: []);
}

final class ChatsLoaded extends ChatsState {
  const ChatsLoaded({required super.chats, required super.selectedChats});
}