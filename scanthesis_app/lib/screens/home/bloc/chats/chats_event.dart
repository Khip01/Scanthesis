part of 'chats_bloc.dart';

@immutable
sealed class ChatsEvent {}

class AddChatEvent extends ChatsEvent {
  final Chat chat;

  AddChatEvent({required this.chat});
}

class RemoveMultipleChatEvent extends ChatsEvent {
  final List<Chat> chats;

  RemoveMultipleChatEvent({required this.chats});
}

class LoadChatHistoryEvent extends ChatsEvent {
  final List<Chat> chats;

  LoadChatHistoryEvent({required this.chats});
}

class ClearSelectedChatsEvent extends ChatsEvent {
  ClearSelectedChatsEvent();
}

class SelectChatEvent extends ChatsEvent {
  final Chat chat;

  SelectChatEvent({required this.chat});
}

class UnselectChatEvent extends ChatsEvent {
  final Chat chat;

  UnselectChatEvent({required this.chat});
}

class SelectAllChatEvent extends ChatsEvent {
  SelectAllChatEvent();
}